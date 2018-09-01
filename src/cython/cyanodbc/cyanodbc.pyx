# distutils: language = c++


cimport nanodbc
from libcpp.string cimport string

import cython


cdef class _TypeCode:
    pass





include "constants.pxi"
include "connection.pxi"    


