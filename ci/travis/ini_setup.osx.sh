#!/bin/bash -ue
cat >"$(odbc_config --odbcinstini)" <<EOF
[SQLite3 ODBC Driver]
Description             = SQLite3 ODBC Driver
Setup                   = /usr/local/lib/libsqlite3odbc.dylib
Driver                  = /usr/local/lib/libsqlite3odbc.dylib
Threading               = 2


[PostgreSQL ODBC Driver(UNICODE)]
Description = PostgreSQL UNICODE
Driver = /usr/local/opt/psqlodbc/lib/psqlodbcw.so
EOF
