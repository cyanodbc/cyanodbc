# distutils: language = c++

cimport cyanodbc.nanodbc as nanodbc
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool as bool_
cimport cpython.datetime
import cython
import logging
import datetime
import numbers
import time
import traceback
import itertools
from libcpp.memory cimport unique_ptr
from cython.operator cimport dereference as deref


from libc.stddef cimport wchar_t
from .wstring cimport const_wchar_t
from collections import namedtuple
import itertools
import decimal



cpython.datetime.import_datetime()

_LOGGER = logging.getLogger(__name__)
apilevel = "2.0"
threadsafety = 1
paramstyle = "qmark"

cdef int verbosity = 0
cdef inline void log(char* msg, int level):
     if level >= verbosity:
         _LOGGER.log(level, msg)




class Error(Exception):
    pass

class Warning(Exception):
    pass

class InterfaceError(Error):
    pass

class DatabaseError(Error):
    pass

class InternalError(DatabaseError):
    pass

class OperationalError(DatabaseError):
    pass

class ProgrammingError(DatabaseError):
    pass

class IntegrityError(DatabaseError):
    pass

class DataError(DatabaseError):
    pass

class NotSupportedError(DatabaseError):
    pass

def dummy():
    return DataError


### Types Handling
# Ref: https://github.com/Cito/PyGreSQL/blob/master/pgdb.py

class Type(frozenset):
    """Type class for a couple of PostgreSQL data types.
    PostgreSQL is object-oriented: types are dynamic.
    We must thus use type names as internal type codes.
    """

    def __new__(cls, values):
        if isinstance(values, basestring):
            values = values.split()
        return super(Type, cls).__new__(cls, values)

    def __eq__(self, other):
        if isinstance(other, basestring):
            if other.startswith('_'):
                other = other[1:]
            return other in self
        else:
            return super(Type, self).__eq__(other)

    def __ne__(self, other):
        if isinstance(other, basestring):
            if other.startswith('_'):
                other = other[1:]
            return other not in self
        else:
            return super(Type, self).__ne__(other)


class ArrayType:
    """Type class for PostgreSQL array types."""

    def __eq__(self, other):
        if isinstance(other, basestring):
            return other.startswith('_')
        else:
            return isinstance(other, ArrayType)

    def __ne__(self, other):
        if isinstance(other, basestring):
            return not other.startswith('_')
        else:
            return not isinstance(other, ArrayType)




# Mandatory type objects defined by DB-API 2 specs:

STRING = Type('char bpchar name text varchar')
BINARY = Type('bytea')
NUMBER = Type('int2 int4 serial int8 float4 float8 numeric money')
DATETIME = Type('date time timetz timestamp timestamptz interval'
    ' abstime reltime')  # these are very old
ROWID = Type('oid')





# Mandatory type helpers defined by DB-API 2 specs:

def Date(year, month, day):
    """Construct an object holding a date value."""
    return datetime.date(year, month, day)


def Time(hour, minute=0, second=0, microsecond=0, tzinfo=None):
    """Construct an object holding a time value."""
    return datetime.time(hour, minute, second, microsecond, tzinfo)


def Timestamp(year, month, day, hour=0, minute=0, second=0, microsecond=0,
        tzinfo=None):
    """Construct an object holding a time stamp value."""
    return datetime.datetime(year, month, day, hour, minute, second, microsecond, tzinfo)


def DateFromTicks(ticks):
    """Construct an object holding a date value from the given ticks value."""
    return Date(*time.localtime(ticks)[:3])


def TimeFromTicks(ticks):
    """Construct an object holding a time value from the given ticks value."""
    return Time(*time.localtime(ticks)[3:6])


def TimestampFromTicks(ticks):
    """Construct an object holding a time stamp from the given ticks value."""
    return Timestamp(*time.localtime(ticks)[:6])


class Binary(bytes):
    """Construct an object capable of holding a binary (long) string value."""
    pass




include "constants.pxi"
include "cursor.pxi"
include "connection.pxi"