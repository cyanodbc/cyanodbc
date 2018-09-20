import pytest
import cyanodbc
from cyanodbc import SQLGetInfo
import sqlite3
import os
import datetime

pytestmark = pytest.mark.skip("For local Testing only")
@pytest.fixture(scope="module")
def sqlite_db():
    conn = sqlite3.connect('example.db')
    c = conn.cursor()
    try:
    # Create tables
        with open(os.path.join(
            os.path.dirname(__file__), '..',
            'vendor', 'chinook-database', 'ChinookDatabase',
            'DataSources', 'Chinook_Sqlite.sql'), encoding="utf-8-sig") as f:
            c.executescript(f.read())
    except sqlite3.OperationalError:
        raise
    
    
    # Save (commit) the changes
    conn.commit()



@pytest.fixture(scope="module")
def connection(sqlite_db):
    cnxn = cyanodbc.connect("DRIVER=SQLite3 ODBC Driver;Database="
    "example.db;LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;")
    yield cnxn

def test_connection_properties(connection):

    assert connection.get_info(SQLGetInfo.SQL_DBMS_NAME) == "SQLite"
    assert connection.get_info(SQLGetInfo.SQL_DATABASE_NAME) == "example.db"
    assert connection.get_info(SQLGetInfo.SQL_DRIVER_NAME).startswith("sqlite3odbc")

def test_cursor_description(connection):
    cursor = connection.cursor()
    cursor.execute("select * from [Artist]")
    description = cursor.description
    assert description
    names = tuple([col_desc[0] for col_desc in description])
    assert names == ('ArtistId', 'Name')

def test_numeric_to_py(connection):
    import decimal
    cursor = connection.cursor()
    cursor.execute("select Total from Invoice where InvoiceId =1 ")
    rows = list(cursor.rows())
    assert rows
    for row in rows:
        dec, *_ = row
        if connection.get_info(SQLGetInfo.SQL_DRIVER_NAME).startswith("sqlite3odbc"):
            assert dec ==  1.98 # https://sqlite.org/faq.html#q3 - Sqlite Will convert Decimal to Double

def test_datetime_to_py(connection):
    import decimal
    cursor = connection.cursor()
    cursor.execute("select [HireDate] from employee where EmployeeId=1")
    rows = list(cursor.rows())
    assert rows
    for row in rows:
        dec, *_ = row
        if connection.get_info(SQLGetInfo.SQL_DRIVER_NAME).startswith("sqlite3odbc"):
            assert dec ==  datetime.datetime(2002, 8, 14, 0, 0) # https://sqlite.org/faq.html#q3 - Sqlite Will convert Decimal to Double


            

def test_cursor_wlongvarchar_to_py(connection):
    cursor = connection.cursor()
    cursor.execute("select Name from [MediaType]")
    rows = list(cursor.rows())
    assert rows
    for row in rows:
        assert row in [('MPEG audio file 💮', ), ('Protected AAC audio file', ),
         ('Protected MPEG-4 video file',), ('Purchased AAC audio file',), ('AAC audio file',)]

def test_multiple_open_connection():
    connection = cyanodbc.connect("DRIVER=SQLite3 ODBC Driver;Database="
    "example.db;LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;")
    cursor = connection.cursor()
    cursor.execute("select 'a'")
    connection = cyanodbc.connect("DRIVER=SQLite3 ODBC Driver;Database="
    "example.db;LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;")
    cursor = connection.cursor()
    cursor.execute("select 'a'")




# Test for Integer

# Test for Date/time/timestamp and utc

# Test for numeric
