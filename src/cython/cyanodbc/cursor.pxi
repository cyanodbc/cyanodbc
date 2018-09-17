

from libc.stddef cimport wchar_t
from wstring cimport const_wchar_t
from collections import namedtuple

import decimal

ColumnDescription = namedtuple(
    'ColumnDescription',
    ['name', 'type_code', 'display_size', 'internal_size', 'precision', 'scale', 'null_ok'],
    rename=True)

cdef class _Description:
    cdef list column_descriptions
    cdef object row_definition

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

    def __init__(self, Connection connection not None):
        self._connection = connection
        self._datatype_get_map = {
            SQLTypes.SQL_WLONGVARCHAR : self._chartype_to_py,
            SQLTypes.SQL_LONGVARCHAR : self._chartype_to_py,
            SQLTypes.SQL_CHAR : self._chartype_to_py,
            SQLTypes.SQL_VARCHAR : self._chartype_to_py,
            SQLTypes.SQL_NVARCHAR : self._chartype_to_py,
            SQLTypes.SQL_WCHAR : self._chartype_to_py,
            SQLTypes.SQL_WVARCHAR : self._chartype_to_py,

            SQLTypes.SQL_DOUBLE : self._float_to_py,
            SQLTypes.SQL_FLOAT : self._float_to_py,
            SQLTypes.SQL_REAL : self._float_to_py,

            SQLTypes.SQL_DECIMAL : self._numeric_to_py,
            SQLTypes.SQL_NUMERIC : self._numeric_to_py,

            SQLTypes.SQL_BIT : self._integral_to_py,
            SQLTypes.SQL_TINYINT : self._integral_to_py,
            SQLTypes.SQL_SMALLINT : self._integral_to_py,
            SQLTypes.SQL_INTEGER : self._integral_to_py,
            SQLTypes.SQL_BIGINT : self._integral_to_py,

            SQLTypes.SQL_DATE : self._datetime_to_py,
            SQLTypes.SQL_TYPE_DATE : self._datetime_to_py,

            SQLTypes.SQL_TIMESTAMP : self._datetime_to_py,
            SQLTypes.SQL_TYPE_TIMESTAMP : self._datetime_to_py,
            #SQLTypes.SQL_SS_TIMESTAMPOFFSET : self._datetime_to_py,

            SQLTypes.SQL_TIME : self._time_to_py,
            SQLTypes.SQL_TYPE_TIME : self._time_to_py,
            #SQLTypes.SQL_SS_TIME2 : self._time_to_py,



        }
        self.c_description = None

    def execute(self, query, long batch_operations=1, long timeout=0):
        cdef nanodbc.connection conn = self._connection.c_cnxn
        self.c_result = nanodbc.execute(conn, query.encode(), batch_operations, timeout)

    # @property
    # def rowset_size(self):
    #     return self.c_result.rowset_size()

    # @property
    # def affected_rows(self):
    #     return self.c_result.affected_rows()

    # @property
    # def has_affected_rows(self):
    #     return self.c_result.has_affected_rows()

    # @property
    # def rows(self):
    #     return self.c_result.rows()

    # @property
    # def columns(self):
    #     return self.c_result.columns()

    # @property
    # def first(self):
    #     return self.c_result.first()

    # @property
    # def last(self):
    #     return self.c_result.last()

    # @property
    # def next(self):
    #     return self.c_result.next()

    @property
    def description(self):
        cdef int i
        self.c_description = _Description()
        
        if self.c_result:
            
            for i in range(self.c_result.columns()):            
                name = self.c_result.column_name(i).decode()
                type_code = self.c_result.column_datatype(i)
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

        while self.c_result.next():
            if Row is None:
                
                Row = namedtuple(
                    'Row',
                    [self.c_result.column_name(i).decode() for i in range(self.c_result.columns())],
                    rename=True)
            row_values = []
            for i in range(self.c_result.columns()):
                sql_datatype = self.c_result.column_datatype(i)
                print("Datatype: %s", sql_datatype)
                row_values.append(self._datatype_get_map[sql_datatype](i))
            yield Row(*row_values)

