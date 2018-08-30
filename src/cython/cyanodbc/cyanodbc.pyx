# distutils: language = c++


cimport nanodbc
from libcpp.string cimport string



cdef class Connection:
    cdef nanodbc.connection c_cnxn

    def __cinit__(self):
        self.c_cnxn = nanodbc.connection()

    def connect(self, dsn, username=None, password=None, long timeout=0):
        if username and password:
            self.c_cnxn.connect(dsn.encode(),username.encode(), password.encode(), timeout)
        else:
            self.c_cnxn.connect(dsn.encode(), timeout)

    def get_info(self, short info_type):
        return self.c_cnxn.get_info[string](info_type).decode()

    @property
    def connected(self):
        return bool(self.c_cnxn.connected())
    
    def cursor(self):
        return Cursor(self)

    # @property
    # def transactions(self):
    
    #     return self.c_cnxn.transactions()

    # @property
    # def dbms_name(self):
    #     return self.c_cnxn.dbms_name().decode('UTF-8')
    
    # @property
    # def dbms_version(self):
    #     return self.c_cnxn.dbms_version().decode('UTF-8')

    # @property
    # def driver_name(self):
    #     return self.c_cnxn.driver_name().decode('UTF-8')

    # @property
    # def database_name(self):
    #     return self.c_cnxn.database_name().decode('UTF-8')

    # @property
    # def catalog_name(self):
    #     return self.c_cnxn.catalog_name().decode('UTF-8')


    
cdef class Cursor:
    cdef nanodbc.result c_result
    cdef Connection _connection

    def __cinit__(self):
        self.c_result = nanodbc.result()

    def __init__(self, Connection connection):
        self._connection = connection

    def execute(self, query, long batch_operations=100, long timeout=0):
        cdef nanodbc.connection conn = self._connection.c_cnxn
        self.c_result = nanodbc.execute(conn, query.encode(), batch_operations, timeout)

    @property
    def rowset_size(self):
        return self.c_result.rowset_size()

    @property
    def affected_rows(self):
        return self.c_result.affected_rows()

    @property
    def has_affected_rows(self):
        return self.c_result.has_affected_rows()

    @property
    def rows(self):
        return self.c_result.rows()

    @property
    def columns(self):
        return self.c_result.columns()

    @property
    def first(self):
        return self.c_result.first()

    @property
    def last(self):
        return self.c_result.last()

    @property
    def next(self):
        return self.c_result.next()