
ColumnDescription = namedtuple(
    'ColumnDescription',
    ['name', 'type_code', 'display_size', 'internal_size', 'precision', 'scale', 'null_ok'],
    rename=True)

cdef class _Description:
    cdef list column_descriptions

    def __init__(self):
        self.column_descriptions = []


    def _add(self, column_desc):
        self.column_descriptions.append(column_desc)
    
    def __repr__(self):
        return 'Description({}, {}, {})'.format(
            self.name, repr(self.type_name), repr(self.type_value))


cdef class Cursor:
    cdef unique_ptr[nanodbc.result] c_result_ptr
    cdef unique_ptr[nanodbc.statement] c_stmt_ptr
    cdef dict _datatype_get_map

    cdef Connection _connection
    cdef _Description c_description

    cdef int _arraysize
    cdef int _timeout

    @property
    def timeout(self):
        return self._timeout

    @timeout.setter
    def timeout(self, value):
        self._timeout = value

    @property
    def arraysize(self):
        return self._arraysize

    @arraysize.setter
    def arraysize(self, int value):
        self._arraysize = value

    @staticmethod
    def setinputsizes(sizes):
        return

    @staticmethod
    def setoutputsize(size, column=0):
        return

    def _binary_to_py(self, short i):
        cdef vector[nanodbc.uint8_t] c_res = deref(self.c_result_ptr).get[vector[nanodbc.uint8_t]](i)
        cdef nanodbc.charP c_res_char = nanodbc.reinterpret_cast[nanodbc.charP](c_res.data())
        return <object>nanodbc.PyBytes_FromStringAndSize(c_res_char, c_res.size())

    def _chartype_to_py(self, short i):
        # cdef const_wchar_t *ptr = deref(self.c_result_ptr).get[nanodbc.wide_string](i).c_str()
        # return <object>nanodbc.PyUnicode_FromWideChar(ptr, -1)
        return deref(self.c_result_ptr).get[string](i).decode()

    def _numeric_to_py(self, short i):
        # cdef const_wchar_t *ptr = deref(self.c_result_ptr).get[nanodbc.wide_string](i).c_str()
        # return <object>nanodbc.PyUnicode_FromWideChar(ptr, -1)
        with decimal.localcontext() as ctx:
            ctx.prec = deref(self.c_result_ptr).column_decimal_digits(i)   # Perform a high precision calculation
            # There is a bug/limitation in ODBC drivers for SQL Server
            # (and possibly others) which causes SQLBindCol() to never
            # write SQL_NOT_NULL to the length/indicator buffer unless you
            # also bind the data column. nanodbc's is_null() will return
            # correct values for these columns if you ensure that
            # SQLGetData() has been called for that column (i.e. *after* get()
            # or get_ref() is called).
            res = deref(self.c_result_ptr).get[string](i).decode()
            if deref(self.c_result_ptr).is_null(i):
                return None
            return decimal.Decimal(res)

    def _float_to_py(self, short i):
        return deref(self.c_result_ptr).get[double](i) # python float == C double
    
    def _integral_to_py(self, short i):
        return deref(self.c_result_ptr).get[nanodbc.ULong](i)

    def _datetime_to_py(self, short i):
        cdef nanodbc.timestamp c_timestamp
        c_timestamp = deref(self.c_result_ptr).get[nanodbc.timestamp](i)
        if deref(self.c_result_ptr).is_null(i):
            return None
        # Maybe if Time component is Zero return Date, else Datetime? - But what about TZ?
        return cpython.datetime.datetime_new(c_timestamp.year,c_timestamp.month,
            c_timestamp.day, c_timestamp.hour, c_timestamp.min,
            c_timestamp.sec, <int>(c_timestamp.fract/1E3), None)

    def _time_to_py(self, short i):
        cdef nanodbc.time c_time
        c_time = deref(self.c_result_ptr).get[nanodbc.time](i)
        if deref(self.c_result_ptr).is_null(i):
            return None
        return cpython.datetime.time_new(c_time.hour, c_time.min, c_time.sec, 0, None)

    def _unbind_if_needed(self):
        found_unbound = False
        try:
            if not self.c_result_ptr or self._connection.get_data_any_order:
                return
            for i in range(deref(self.c_result_ptr).columns()):
                is_bound = deref(self.c_result_ptr).is_bound(i)
                if found_unbound and is_bound:
                    deref(self.c_result_ptr).unbind(i)
                found_unbound = found_unbound or (not is_bound)
        except RuntimeError as e:
            raise DatabaseError("Error while unbinding: " + str(e)) from e

    def __cinit__(self):
        self._arraysize = 1
        self._timeout = 0

    def __init__(self, Connection connection not None):
        self._connection = connection
        self._datatype_get_map = {
            _SQL_WLONGVARCHAR : (self._chartype_to_py, STRING),
            _SQL_LONGVARCHAR : (self._chartype_to_py, STRING),
            _SQL_CHAR : (self._chartype_to_py, STRING),
            _SQL_VARCHAR : (self._chartype_to_py, STRING),
            _SQL_WCHAR : (self._chartype_to_py, STRING),
            _SQL_WVARCHAR : (self._chartype_to_py, STRING),
            _SQL_GUID : (self._chartype_to_py, STRING),
            _SQL_SS_XML : (self._chartype_to_py, STRING),

            _SQL_DOUBLE : (self._float_to_py,NUMBER),
            _SQL_FLOAT : (self._float_to_py,NUMBER),
            _SQL_REAL : (self._float_to_py,NUMBER),

            _SQL_DECIMAL : (self._numeric_to_py,NUMBER),
            _SQL_NUMERIC : (self._numeric_to_py,NUMBER),

            _SQL_BIT : (self._integral_to_py, NUMBER),
            _SQL_TINYINT : (self._integral_to_py, NUMBER),
            _SQL_SMALLINT : (self._integral_to_py, NUMBER),
            _SQL_INTEGER : (self._integral_to_py, NUMBER),
            _SQL_BIGINT : (self._integral_to_py, NUMBER),

            _SQL_DATE : (self._datetime_to_py, DATETIME),
            _SQL_TYPE_DATE : (self._datetime_to_py, DATETIME),

            _SQL_TIMESTAMP : (self._datetime_to_py, DATETIME),
            _SQL_TYPE_TIMESTAMP : (self._datetime_to_py, DATETIME),
            #_SQL_SS_TIMESTAMPOFFSET : self._datetime_to_py,

            _SQL_TIME : (self._time_to_py,DATETIME),
            _SQL_TYPE_TIME : (self._time_to_py,DATETIME),
            #_SQL_SS_TIME2 : self._time_to_py,

            _SQL_BINARY : (self._binary_to_py, BINARY),
            _SQL_VARBINARY : (self._binary_to_py, BINARY),
            _SQL_LONGVARBINARY : (self._binary_to_py, BINARY),
            _SQL_SS_UDT : (self._binary_to_py, BINARY),

        }
        connection._register_cursor(self)
        self.c_description = None

    @property
    def rowcount(self):
        res = -1
        if self.c_result_ptr:
            res = deref(self.c_result_ptr).affected_rows()
        return res or -1

    @property
    def has_affected_rows(self):
        return deref(self.c_result_ptr).has_affected_rows()

    

    def executemany(self, query, seq_of_parameters):
        cdef vector[string] values
        cdef vector[char] nulls

        if not self._connection.connected():
            raise DatabaseError("Connection Disconnected.")

        try:
            self.close()
            self.c_stmt_ptr.reset(new nanodbc.statement(self._connection.c_cnxn))
            deref(self.c_stmt_ptr).prepare(query.encode(), self.timeout)
        except RuntimeError as e:
            raise DatabaseError("Error in Preparing: " + str(e)) from e

        transpose = zip(*seq_of_parameters)
        
        for col, idx in zip(transpose, itertools.count()):
            # values = vector[string](len(col))
            # print(idx, list(col))

            [values.push_back(str(i).encode()) for i in col]

            [nulls.push_back(True) if i is None else nulls.push_back(False) for i in col ]

            deref(self.c_stmt_ptr).bind_strings(idx, values, <bool_*>nulls.data(), nanodbc.param_direction.PARAM_IN)
        try:
            self.c_result_ptr.reset(new nanodbc.result(deref(self.c_stmt_ptr).execute(max(1, len(seq_of_parameters)), self.timeout)))

        except RuntimeError as e:
            raise DatabaseError("Error in Executing: " + str(e)) from e
        

    def execute(self, query, parameters=None):
        if parameters is None:
            parameters = []
        self.executemany(query, [parameters])
        # cdef nanodbc.statement  stmt = nanodbc.statement(self._connection.c_cnxn)
        # stmt.prepare(query.encode(), self.timeout)
        # self.c_result = stmt.execute(self.arraysize, self.timeout)

        # cdef nanodbc.connection conn = self._connection.c_cnxn
        # try:
        #     self.c_result = nanodbc.execute(conn, query.encode(), self.arraysize, self.timeout)
        # except RuntimeError as e:
        #     raise DatabaseError("Error in Executing") from e

    @property
    def description(self):
        cdef int i

        # If we have a result, populate the description field if None
        if self.c_description is None and self.c_result_ptr:
            self.c_description = _Description()
            for i in range(deref(self.c_result_ptr).columns()):
                # TODO: Revisit the None's below
                col_desc = ColumnDescription(
                    deref(self.c_result_ptr).column_name(i).decode(),
                    self._datatype_get_map[deref(self.c_result_ptr).column_datatype(i)][1],

                    deref(self.c_result_ptr).column_size(i),
                    None,
                    deref(self.c_result_ptr).column_decimal_digits(i),
		    None,
                    None)
                self.c_description._add(col_desc)


        if self.c_description and self.c_description.column_descriptions:
            return tuple(self.c_description.column_descriptions)
        else:
            return None


    def _get(short i):
        """Return python object corresponding to given column number"""
        pass

    def rows(self):
        cdef short i
        Row = None
        _ = self.description # Initialise self.c_description
        self._unbind_if_needed()
        try:
            while deref(self.c_result_ptr).next():
                if Row is None:
                    
                    Row = namedtuple(
                        'Row',
                        [deref(self.c_result_ptr).column_name(i).decode() \
			for i in range(deref(self.c_result_ptr).columns())],
                        rename=True)
                row_values = []
                for i in range(deref(self.c_result_ptr).columns()):
                    sql_datatype = deref(self.c_result_ptr).column_datatype(i)
                    # print("Datatype: %s", sql_datatype)
                    if deref(self.c_result_ptr).is_null(i):
                        row_values.append(None)
                    else:    
                        row_values.append(self._datatype_get_map[sql_datatype][0](i))
                yield Row(*row_values)
        except RuntimeError as e:
            raise DatabaseError("Error in Fetching: " + str(e)) from e

    def fetchall(self):
        if self.description is None:
            raise DatabaseError("Query not executed or did not return results.")
        return [list(i) for i in self.rows()]

    def fetchone(self):
        if self.description is None:
            raise DatabaseError("Query not executed or did not return results.")
        try:
            return list(next(self.rows()))
        except StopIteration:
            return
        
    def fetchmany(self, size=None):
        if self.description is None:
            raise DatabaseError("Query not executed or did not return results.")
        if size is None:
            size = self.arraysize
        return [list(i) for i in itertools.islice(self.rows(), size)]

    def close(self):
        self.c_stmt_ptr.reset()
        self.c_result_ptr.reset()
        self.c_description = None
