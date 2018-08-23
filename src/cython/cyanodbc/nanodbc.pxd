from libcpp.string cimport string
# Decalre the class with cdef
cdef extern from "nanodbc/nanodbc.h" namespace "nanodbc":
    cdef cppclass connection:
        connection() except +
        connection(const string& connection_string, long timeout = 0) except +

        connection connect(const string_type &dsn, const string_type &user, const string_type &pass, long timeout=0)
        connection connect(const string_type &connection_string, long timeout=0)

        string dbms_name() const
        string dbms_version() const
        string driver_name() const
        string catalog_name() const

        # connection(int, int, int, int) except +
        # int x0, y0, x1, y1
        # int getArea()
        # void getSize(int* width, int* height)
        # void move(int, int)