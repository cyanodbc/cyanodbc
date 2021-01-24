# distutils: language = c++
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.list cimport list as list_
from libcpp cimport bool as bool_
from libcpp.cast cimport reinterpret_cast
from libc.stdint cimport int16_t, int32_t, uint8_t
from cpython.ref cimport PyObject
from libc.stddef cimport wchar_t
from .wstring cimport wstring
ctypedef char* charP

cdef extern from "Python.h":
    PyObject* PyUnicode_FromWideChar(wchar_t *w, Py_ssize_t size)
    PyObject* PyBytes_FromStringAndSize(const char *v, Py_ssize_t len)

cdef extern from "nanodbc/nanodbc.h" namespace "nanodbc::catalog" nogil:
   cdef cppclass tables:
        tables(tables&)
        bool_ next()
        string table_catalog() const
        string table_schema() const
        string table_name() const
        string table_type() const
        string table_remarks() const

   cdef cppclass procedures:
        procedures(procedures&)
        bool_ next()
        string procedure_catalog() const
        string procedure_schema() const
        string procedure_name() const
        string procedure_remarks() const
        short procedure_type() const

   cdef cppclass procedure_columns:
        procedure_columns(procedure_columns&)
        bool_ next()
        string procedure_catalog() except +
        string procedure_schema() except +
        string procedure_name() except +
        string column_name() except +
        short column_type() except +
        short data_type() except +
        string type_name() except +
        long column_size() except +
        long buffer_length() except +
        short decimal_digits() except +
        short numeric_precision_radix() except +
        short nullable() except +
        string remarks()  except +
        string column_default() except +
        short sql_data_type() except +
        short sql_datetime_subtype() except +
        long char_octet_length() except +

   cdef cppclass columns:
        columns(columns&)
        bool_ next()
        string table_catalog() const
        string table_schema() const
        string table_name() const
        string column_name() const
        short data_type() const
        string type_name() const
        long column_size() const
        long buffer_length() const
        short decimal_digits() const
        short numeric_precision_radix() const
        short nullable() const
        string remarks() const
        string column_default() const
        short sql_data_type() const
        short sql_datetime_subtype() const
        long char_octet_length() const

cdef extern from "nanodbc/nanodbc.h" namespace "nanodbc" nogil:
    ctypedef wstring wide_string

    result execute(connection& conn, const string& query, long batch_operations, long timeout) except +
    list_[datasource] list_datasources() except +
    
    cdef cppclass datasource:
        string name
        string driver

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
        result(result&) except +


        long rowset_size() except +
        long affected_rows() except +
        bint has_affected_rows() except +
        long rows() except +
        short columns() except +

        bint first()
        bint last()
        bint next() except +
        bint is_null(short column) except +
        bool_ is_bound(short column) except +
        void unbind(short column) except +
        void unbind() except +

        T get[T](short column) except+
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

    cdef cppclass catalog:
        catalog(connection& conn) except+
        tables find_tables(
            const string& table,
            const string& type,
            const string& schema,
            const string& catalog
        ) except +
        columns find_columns(
            const string& column,
            const string& table,
            const string& schema,
            const string& catalog
        ) except+
        procedures find_procedures(
            const string& procedure,
            const string& schema,
            const string& catalog
        ) except +
        procedure_columns find_procedure_columns(
            const string& column,
            const string& procedure,
            const string& schema,
            const string& catalog
        ) except+
        list_[string] list_catalogs() except+
        list_[string] list_schemas() except+

    cdef cppclass connection:

        connection() except+

        void connect(const string&, long) except+
        void connect(const string&, const string&, const string& , long) except +

        void disconnect() except+

        bint connected() const
        # size_t transactions() const
        T get_info[T](short info_type) const
        string dbms_name() const
        string dbms_version() const
        # string driver_name() const
        string database_name() const
        string catalog_name() const
    cdef enum param_direction "nanodbc::statement::param_direction":
        PARAM_IN "nanodbc::statement::param_direction::PARAM_IN"
        PARAM_OUT "nanodbc::statement::param_direction::PARAM_OUT"
        PARAM_INOUT "nanodbc::statement::param_direction::PARAM_INOUT"
        PARAM_RETURN "nanodbc::statement::param_direction::PARAM_RETURN"

    cdef cppclass statement:
        statement() except+
        statement(connection& conn) except+

        void prepare(string& query, long timeout) except+
        void prepare(connection& conn, string& query, long timeout) except+
        void timeout(long timeout) except+

        result execute(long batch_operations, long timeout) except+
        unsigned long parameter_size(short param_index)
        short parameters()
        void reset_parameters()
        void close() except+
        void cancel() except+
        bint connected()
        
        void bind[T](
            short param_index,
            T* values,
            long batch_size,
            bool_* nulls,
            param_direction direction) except+

        void bind_null(short param_index, long batch_size);

        void bind_strings(
            short param_index,
            vector[string]& values,
            param_direction direction) except +

        void bind_strings(
            short param_index,
            vector[string]& values,
            bool_* nulls,
            param_direction direction) except +



    cdef cppclass transaction:
        transaction(connection& conn) except +
        void commit() except+
        void rollback() except+


