

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
    cdef nanodbc.result c_result
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


    def _chartype_to_py(self, short i):
        # cdef const_wchar_t *ptr = self.c_result.get[nanodbc.wide_string](i).c_str()
        # return <object>nanodbc.PyUnicode_FromWideChar(ptr, -1)
        return self.c_result.get[string](i).decode()

    def _numeric_to_py(self, short i):
        # cdef const_wchar_t *ptr = self.c_result.get[nanodbc.wide_string](i).c_str()
        # return <object>nanodbc.PyUnicode_FromWideChar(ptr, -1)
        with decimal.localcontext() as ctx:
            ctx.prec = self.c_result.column_decimal_digits(i)   # Perform a high precision calculation
            return decimal.Decimal(self.c_result.get[string](i).decode())

    def _float_to_py(self, short i):
        return self.c_result.get[double](i) # python float == C double
    
    def _integral_to_py(self, short i):
        return self.c_result.get[nanodbc.ULong](i)

    def _datetime_to_py(self, short i):
        cdef nanodbc.timestamp c_timestamp
        c_timestamp = self.c_result.get[nanodbc.timestamp](i)
        # Maybe if Time component is Zero return Date, else Datetime? - But what about TZ?
        return cpython.datetime.datetime_new(c_timestamp.year,c_timestamp.month,
            c_timestamp.day, c_timestamp.hour, c_timestamp.min,
            c_timestamp.sec, c_timestamp.fract, None)

    def _time_to_py(self, short i):
        cdef nanodbc.time c_time
        c_time = self.c_result.get[nanodbc.time](i)
        return cpython.datetime.time_new(c_time.hour, c_time.min, c_time.sec, 0, None)
    

    def __cinit__(self):
        self.c_result = nanodbc.result()
        self._arraysize = 1
        self._timeout = 0

    def __init__(self, Connection connection not None):
        self._connection = connection
        self._datatype_get_map = {
            SQLTypes.SQL_WLONGVARCHAR : (self._chartype_to_py, STRING),
            SQLTypes.SQL_LONGVARCHAR : (self._chartype_to_py, STRING),
            SQLTypes.SQL_CHAR : (self._chartype_to_py, STRING),
            SQLTypes.SQL_VARCHAR : (self._chartype_to_py, STRING),
            SQLTypes.SQL_NVARCHAR : (self._chartype_to_py, STRING),
            SQLTypes.SQL_WCHAR : (self._chartype_to_py, STRING),
            SQLTypes.SQL_WVARCHAR : (self._chartype_to_py, STRING),

            SQLTypes.SQL_DOUBLE : (self._float_to_py,NUMBER),
            SQLTypes.SQL_FLOAT : (self._float_to_py,NUMBER),
            SQLTypes.SQL_REAL : (self._float_to_py,NUMBER),

            SQLTypes.SQL_DECIMAL : (self._numeric_to_py,NUMBER),
            SQLTypes.SQL_NUMERIC : (self._numeric_to_py,NUMBER),

            SQLTypes.SQL_BIT : (self._integral_to_py, NUMBER),
            SQLTypes.SQL_TINYINT : (self._integral_to_py, NUMBER),
            SQLTypes.SQL_SMALLINT : (self._integral_to_py, NUMBER),
            SQLTypes.SQL_INTEGER : (self._integral_to_py, NUMBER),
            SQLTypes.SQL_BIGINT : (self._integral_to_py, NUMBER),

            SQLTypes.SQL_DATE : (self._datetime_to_py, DATETIME),
            SQLTypes.SQL_TYPE_DATE : (self._datetime_to_py, DATETIME),

            SQLTypes.SQL_TIMESTAMP : (self._datetime_to_py, DATETIME),
            SQLTypes.SQL_TYPE_TIMESTAMP : (self._datetime_to_py, DATETIME),
            #SQLTypes.SQL_SS_TIMESTAMPOFFSET : self._datetime_to_py,

            SQLTypes.SQL_TIME : (self._time_to_py,DATETIME),
            SQLTypes.SQL_TYPE_TIME : (self._time_to_py,DATETIME),
            #SQLTypes.SQL_SS_TIME2 : self._time_to_py,



        }
        self.c_description = None

    @property
    def rowcount(self):
        #return -1
        return self.c_result.affected_rows() or -1

    @property
    def has_affected_rows(self):
        return self.c_result.has_affected_rows()

    

    def executemany(self, query, seq_of_parameters):
        cdef nanodbc.statement  stmt = self._connection.c_stmt
        cdef vector[string] values
        cdef vector[char] nulls

        if not stmt.connected():
            raise DatabaseError("Connection Disconnected.")

        stmt.close()
        stmt.prepare(self._connection.c_cnxn, query.encode(), self.timeout)

        transpose = zip(*seq_of_parameters)
        
        for col, idx in zip(transpose, itertools.count()):
            # values = vector[string](len(col))
            print(idx, list(col))

            [values.push_back(str(i).encode()) for i in col]

            [nulls.push_back(True) if i is None else nulls.push_back(False) for i in col ]

            stmt.bind_strings(idx, values, <bool_*>nulls.data(), nanodbc.param_direction.PARAM_IN)
        try:
            self.c_result = stmt.execute(max(1, len(seq_of_parameters)), self.timeout)
            
        except RuntimeError as e:
            raise DatabaseError("Error in Executing") from e
        

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
        self.c_description = _Description()
        
        if self.c_result:
            
            for i in range(self.c_result.columns()):
                name = self.c_result.column_name(i).decode()
                type_code = self._datatype_get_map[self.c_result.column_datatype(i)][1] 
                display_size = self.c_result.column_size(i)
                internal_size = None
                precision = self.c_result.column_decimal_digits(i)
                scale = None
                null_ok = None
                # TODO: Inline these above variables
                col_desc = ColumnDescription(
                    name,
                    type_code,
                    display_size,
                    internal_size,
                    precision, scale,
                    null_ok)
                self.c_description._add(col_desc)

        if self.c_description.column_descriptions:
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
        try:
            while self.c_result.next():
                if Row is None:
                    
                    Row = namedtuple(
                        'Row',
                        [self.c_result.column_name(i).decode() for i in range(self.c_result.columns())],
                        rename=True)
                row_values = []
                for i in range(self.c_result.columns()):
                    sql_datatype = self.c_result.column_datatype(i)
                    # print("Datatype: %s", sql_datatype)
                    if self.c_result.is_null(i):
                        row_values.append(None)
                    else:    
                        row_values.append(self._datatype_get_map[sql_datatype][0](i))
                yield Row(*row_values)
        except RuntimeError as e:
            raise DatabaseError from e

    def fetchall(self):
        if self.c_result:
            return [list(i) for i in self.rows()]
        else:
            raise DatabaseError("Message")

    def fetchone(self):
        if self.c_result:
            try:
                return list(next(self.rows()))
            except StopIteration:
                return
            # return [list(i) for i in self.rows()]
        else:
            raise DatabaseError("Message")
        
    def fetchmany(self, size=None):
        if size is None:
            size = self.arraysize
        if self.c_result:
            
            return [list(i) for i in itertools.islice(self.rows(), size)]
        else:
            raise DatabaseError("Message")