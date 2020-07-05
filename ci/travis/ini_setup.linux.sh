#!/bin/bash -ue

# If we were to do this
# sudo odbcinst -i -d -f /usr/share/sqliteodbc/unixodbc.ini
# the sqlite drivers would be recorded under a name that is
# different than windows / osx

cat >/tmp/odbcinst.ini <<EOF
[SQLite ODBC Driver]
Description=SQLite ODBC Driver
Driver=libsqliteodbc.so
Setup=libsqliteodbc.so
UsageCount=2

[SQLite3 ODBC Driver]
Description=SQLite3 ODBC Driver
Driver=libsqlite3odbc.so
Setup=libsqlite3odbc.so
UsageCount=2
EOF

sudo odbcinst -i -d -f /tmp/odbcinst.ini
