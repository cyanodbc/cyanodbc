# distutils: language = c++


cimport nanodbc
from libcpp.string cimport string

cdef class Result:
    cdef nanodbc.result c_result

    def __cinit__(self):
        self.c_result = nanodbc.result()

    @property
    def rowset_size(self):
        return self.c_result.rowset_size()

cdef class Connection:
    cdef nanodbc.connection c_cnxn

    def __cinit__(self, connstr=None, long timeout=0):
        if connstr:
            self.c_cnxn = nanodbc.connection(connstr.encode(), timeout)

    def connect(self, connstr, username=None, password=None, long timeout=0):
        if username and password:
            self.c_cnxn.connect(connstr.encode(),username.encode(), password.encode(), timeout)
        else:
            self.c_cnxn.connect(connstr.encode(), timeout)


    @property
    def dbms_name(self):
        return self.c_cnxn.dbms_name().decode('UTF-8')
    
    @property
    def dbms_version(self):
        return self.c_cnxn.dbms_version().decode('UTF-8')

    @property
    def driver_name(self):
        return self.c_cnxn.driver_name().decode('UTF-8')

    @property
    def catalog_name(self):
        return self.c_cnxn.catalog_name().decode('UTF-8')


# def execute(connection, query, long batch_operations, long timeout):
#     if isinstance(connection, Connection):
#         execute()
