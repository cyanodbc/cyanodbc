# distutils: language = c++

from nanodbc cimport connection
from libcpp.string cimport string

cdef class Connection:
    cdef connection c_cnxn

    def __cinit__(self, connstr=None, long timeout=0):
        if connstr:
            self.c_cnxn = connection(connstr.encode('UTF-8'))

    def connect(self, connstr,  long timeout=0):
        self.c_cnxn = self.c_cnxn.connect(connstr.encode('UTF-8'), timeout)
    
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


