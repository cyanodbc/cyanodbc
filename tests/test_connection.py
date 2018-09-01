import pytest
import cyanodbc
from cyanodbc.constants import SQLGetInfo
import sqlite3


@pytest.fixture(scope="module")
def sqlite_db():
    
    conn = sqlite3.connect('example.db')
    c = conn.cursor()
    try:
    # Create table
        c.execute('''CREATE TABLE stocks
                    (date text, trans text, symbol text, qty real, price real)''')
    except sqlite3.OperationalError:
        pass
    # Insert a row of data
    c.execute("INSERT INTO stocks VALUES ('2006-01-05','BUY','RHAT',100,35.14)")
    c.execute("INSERT INTO stocks VALUES ('2006-01-04','SELL','IBM',150,14.23)")
    c.execute("INSERT INTO stocks VALUES ('2006-01-03','HOLD','💮',30,5.14)")
    c.execute("INSERT INTO stocks VALUES ('2006-01-05','BUY','RHAT',100,35.14)")
    c.execute("INSERT INTO stocks VALUES ('2006-01-04','SELL','IBM',150,14.23)")
    c.execute("INSERT INTO stocks VALUES ('2006-01-03','HOLD','DELL',30,5.14)")
    c.execute("INSERT INTO stocks VALUES ('2006-01-05','BUY','RHAT',100,35.14)")
    c.execute("INSERT INTO stocks VALUES ('2006-01-04','SELL','IBM',150,14.23)")
    c.execute("INSERT INTO stocks VALUES ('2006-01-03','HOLD','DELL',30,5.14)")
    c.execute("INSERT INTO stocks VALUES ('2006-01-05','BUY','RHAT',100,35.14)")
    c.execute("INSERT INTO stocks VALUES ('2006-01-04','SELL','IBM',150,14.23)")
    c.execute("INSERT INTO stocks VALUES ('2006-01-03','HOLD','DELL',30,5.14)")
    
    # Save (commit) the changes
    conn.commit()
    
    yield
    c = conn.cursor()
    # Create table
    c.execute('''DROP TABLE stocks''')    
    conn.close()



@pytest.fixture(scope="module")
def connection(sqlite_db):
    cnxn = cyanodbc.Connection()
    cnxn.connect("DRIVER=SQLite3 ODBC Driver;Database="
    "example.db;LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;")
    yield cnxn

def test_connection_create():
    cnxn = cyanodbc.Connection()
    assert not cnxn.connected

def test_connection_properties(connection):
    
    assert connection.connected
    assert connection.get_info(SQLGetInfo.SQL_DBMS_NAME) == "SQLite"
    assert connection.get_info(SQLGetInfo.SQL_DATABASE_NAME) == "example.db"
    assert connection.get_info(SQLGetInfo.SQL_DRIVER_NAME) == "sqlite3odbc.dll"

def test_cursor_description(connection, sqlite_db):
    cursor = connection.cursor()
    batch_operations = 9
    cursor.execute("select * from stocks", batch_operations)
    description = cursor.description
    assert description
    names = tuple([col_desc[0] for col_desc in description])
    assert names == ('date', 'trans' , 'symbol', 'qty', 'price')


def test_cursor_wlongvarchar_to_py(connection, sqlite_db):
    cursor = connection.cursor()
    cursor.execute("select symbol from stocks")
    rows = list(cursor.rows())
    assert rows
    for row in rows:
        assert row in [('💮', ), ('RHAT', ), ('IBM',), ('DELL',)]



#TODO This fails somehow
# import cyanodbc
# connection = cyanodbc.Connection()
# connection.connect("DRIVER=SQLite3 ODBC Driver;Database="
# "example.db;LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;")
# cursor = connection.cursor()
# cursor.execute("select 'a'")
# connection.connect("DRIVER=SQLite3 ODBC Driver;Database="
# "example.db;LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;")