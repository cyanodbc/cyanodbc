from libcpp.string cimport string
from libc.stdint cimport int16_t, int32_t
from cpython.ref cimport PyObject
from libc.stddef cimport wchar_t
from wstring cimport wstring

ctypedef unsigned long ULong

cdef extern from "Python.h":
    PyObject* PyUnicode_FromWideChar(wchar_t *w, Py_ssize_t size)


cdef extern from "nanodbc/nanodbc.h" namespace "nanodbc":
    ctypedef wstring wide_string

    result execute(connection& conn, const string& query, long batch_operations, long timeout) except +
    
    cdef cppclass date:
        int16_t year
        int16_t month
        int16_t day

    cdef cppclass time:
        int16_t hour
        int16_t min
        int16_t sec

    cdef cppclass timestamp:
        int16_t year
        int16_t month
        int16_t day
        int16_t hour
        int16_t min
        int16_t sec
        int32_t fract

    cdef cppclass result:
        result() except +

        long rowset_size() const
        long affected_rows() const
        bint has_affected_rows() const
        long rows() const
        short columns() const

        bint first()
        bint last()
        bint next()

        T get[T](short column) const
        short column(const string& column_name) const
        string column_name(short column) const

        long column_size(short column) const
        long column_size(const string& column_name) const

        int column_decimal_digits(short column) const
        int column_decimal_digits(const string& column_name) const

        int column_datatype(short column) const
        int column_datatype(const string& column_name) const

        string column_datatype_name(short column) const
        string column_datatype_name(const string& column_name) const

        int column_c_datatype(short column) const
        int column_c_datatype(const string& ) const

        bint next_result()
        bint operator bool()

    cdef cppclass connection:

        connection() except +
        # connection(const string&, long) except +

        void connect(const string&, long) except +
        void connect(const string&, const string&, const string& , long) except +

        bint connected() const
        # size_t transactions() const
        T get_info[T](short info_type) const
        string dbms_name() const
        # string dbms_version() const
        # string driver_name() const
        # string database_name() const
        # string catalog_name() const
