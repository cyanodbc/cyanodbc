class SQLGetInfo:
    """"Constants referenced from https://github.com/Microsoft/ODBC-Specification/blob/master/Windows/inc/sql.h """
    SQL_MAX_DRIVER_CONNECTIONS          = 0
    SQL_MAXIMUM_DRIVER_CONNECTIONS      = SQL_MAX_DRIVER_CONNECTIONS
    SQL_MAX_CONCURRENT_ACTIVITIES       = 1
    SQL_MAXIMUM_CONCURRENT_ACTIVITIES   = SQL_MAX_CONCURRENT_ACTIVITIES
    SQL_DATA_SOURCE_NAME                = 2
    SQL_DRIVER_NAME                     = 6
    SQL_FETCH_DIRECTION                 = 8
    SQL_SERVER_NAME                     = 13
    SQL_SEARCH_PATTERN_ESCAPE           = 14
    SQL_DATABASE_NAME                   = 16
    SQL_DBMS_NAME                       = 17
    SQL_DBMS_VER                        = 18
    SQL_ACCESSIBLE_TABLES               = 19
    SQL_ACCESSIBLE_PROCEDURES           = 20
    SQL_CURSOR_COMMIT_BEHAVIOR          = 23
    SQL_DATA_SOURCE_READ_ONLY           = 25
    SQL_DEFAULT_TXN_ISOLATION           = 26
    SQL_IDENTIFIER_CASE                 = 28
    SQL_IDENTIFIER_QUOTE_CHAR           = 29
    SQL_MAX_COLUMN_NAME_LEN             = 30
    SQL_MAXIMUM_COLUMN_NAME_LENGTH      = SQL_MAX_COLUMN_NAME_LEN
    SQL_MAX_CURSOR_NAME_LEN             = 31
    SQL_MAXIMUM_CURSOR_NAME_LENGTH      = SQL_MAX_CURSOR_NAME_LEN
    SQL_MAX_SCHEMA_NAME_LEN             = 32
    SQL_MAXIMUM_SCHEMA_NAME_LENGTH      = SQL_MAX_SCHEMA_NAME_LEN
    SQL_MAX_CATALOG_NAME_LEN            = 34
    SQL_MAXIMUM_CATALOG_NAME_LENGTH     = SQL_MAX_CATALOG_NAME_LEN
    SQL_MAX_TABLE_NAME_LEN              = 35
    SQL_SCROLL_CONCURRENCY              = 43
    SQL_TXN_CAPABLE                     = 46
    SQL_TRANSACTION_CAPABLE             = SQL_TXN_CAPABLE
    SQL_USER_NAME                       = 47
    SQL_TXN_ISOLATION_OPTION            = 72
    SQL_TRANSACTION_ISOLATION_OPTION    = SQL_TXN_ISOLATION_OPTION
    SQL_INTEGRITY                       = 73
    SQL_GETDATA_EXTENSIONS              = 81
    SQL_NULL_COLLATION                  = 85
    SQL_ALTER_TABLE                     = 86
    SQL_ORDER_BY_COLUMNS_IN_SELECT      = 90
    SQL_SPECIAL_CHARACTERS              = 94
    SQL_MAX_COLUMNS_IN_GROUP_BY         = 97
    SQL_MAXIMUM_COLUMNS_IN_GROUP_BY     = SQL_MAX_COLUMNS_IN_GROUP_BY
    SQL_MAX_COLUMNS_IN_INDEX            = 98
    SQL_MAXIMUM_COLUMNS_IN_INDEX        = SQL_MAX_COLUMNS_IN_INDEX
    SQL_MAX_COLUMNS_IN_ORDER_BY         = 99
    SQL_MAXIMUM_COLUMNS_IN_ORDER_BY     = SQL_MAX_COLUMNS_IN_ORDER_BY
    SQL_MAX_COLUMNS_IN_SELECT           = 100
    SQL_MAXIMUM_COLUMNS_IN_SELECT       = SQL_MAX_COLUMNS_IN_SELECT
    SQL_MAX_COLUMNS_IN_TABLE            = 101
    SQL_MAX_INDEX_SIZE                  = 102
    SQL_MAXIMUM_INDEX_SIZE              = SQL_MAX_INDEX_SIZE
    SQL_MAX_ROW_SIZE                    = 104
    SQL_MAXIMUM_ROW_SIZE                = SQL_MAX_ROW_SIZE
    SQL_MAX_STATEMENT_LEN               = 105
    SQL_MAXIMUM_STATEMENT_LENGTH        = SQL_MAX_STATEMENT_LEN
    SQL_MAX_TABLES_IN_SELECT            = 106
    SQL_MAXIMUM_TABLES_IN_SELECT        = SQL_MAX_TABLES_IN_SELECT
    SQL_MAX_USER_NAME_LEN               = 107
    SQL_MAXIMUM_USER_NAME_LENGTH        = SQL_MAX_USER_NAME_LEN
    SQL_OJ_CAPABILITIES                 = 115
    SQL_OUTER_JOIN_CAPABILITIES         = SQL_OJ_CAPABILITIES

    SQL_XOPEN_CLI_YEAR                  = 10000
    SQL_CURSOR_SENSITIVITY              = 10001
    SQL_DESCRIBE_PARAMETER              = 10002
    SQL_CATALOG_NAME                    = 10003
    SQL_COLLATION_SEQ                   = 10004
    SQL_MAX_IDENTIFIER_LEN              = 10005
    SQL_MAXIMUM_IDENTIFIER_LENGTH       = SQL_MAX_IDENTIFIER_LEN

class SQLTypes:
    SQL_UNKNOWN_TYPE                    = 0
    SQL_VARIANT_TYPE			        = SQL_UNKNOWN_TYPE
    SQL_CHAR                            = 1
    SQL_NUMERIC                         = 2
    SQL_DECIMAL                         = 3
    SQL_INTEGER                         = 4
    SQL_SMALLINT                        = 5
    SQL_FLOAT                           = 6
    SQL_REAL                            = 7
    SQL_DOUBLE                          = 8
    SQL_DATETIME                        = 9
    SQL_DATE                            = 9
    SQL_INTERVAL                        = 10
    SQL_TIME                            = 10
    SQL_TIMESTAMP                       = 11
    SQL_VARCHAR                         = 12
    SQL_UDT 				            = 17
    SQL_ROW 				            = 19
    SQL_ARRAY 				            = 50
    SQL_MULTISET				        = 55
    SQL_TYPE_DATE                       = 91
    SQL_TYPE_TIME                       = 92
    SQL_TYPE_TIMESTAMP                  = 93
    SQL_TYPE_TIME_WITH_TIMEZONE		    = 94
    SQL_TYPE_TIMESTAMP_WITH_TIMEZONE    = 95
    SQL_LONGVARCHAR                     = (-1)
    SQL_BINARY                          = (-2)
    SQL_VARBINARY                       = (-3)
    SQL_LONGVARBINARY                   = (-4)
    SQL_BIGINT                          = (-5)
    SQL_TINYINT                         = (-6)
    SQL_BIT                             = (-7)
    SQL_WCHAR                           = (-8)
    SQL_WVARCHAR                        = (-9)
    SQL_WLONGVARCHAR                    = (-10)
    SQL_GUID                            = (-11)
    SQL_NVARCHAR                        = (-10) #Defined in nanodbc.cpp


