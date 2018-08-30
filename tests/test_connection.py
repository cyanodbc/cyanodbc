import pytest
import cyanodbc
from cyanodbc.constants import SQLGetInfo
import sqlite3


@pytest.fixture(scope="module")
def sqlite_db():
    
    conn = sqlite3.connect('example.db')
    # c = conn.cursor()
    # try:
    # # Create table
    #     c.execute('''CREATE TABLE stocks
    #                 (date text, trans text, symbol text, qty real, price real)''')
    # except sqlite3.OperationalError:
    #     pass
    # # Insert a row of data
    # c.execute("INSERT INTO stocks VALUES ('2006-01-05','BUY','RHAT',100,35.14)")
    # c.execute("INSERT INTO stocks VALUES ('2006-01-04','SELL','IBM',150,14.23)")
    # c.execute("INSERT INTO stocks VALUES ('2006-01-03','HOLD','DELL',30,5.14)")
    # # Save (commit) the changes
    # conn.commit()
    
    # yield
    # c = conn.cursor()
    # # Create table
    # # c.execute('''DROP TABLE stocks''')    
    # conn.close()



@pytest.fixture(scope="module")
def sqlite_connection(sqlite_db):
    cnxn = cyanodbc.Connection()
    
    yield cnxn

def test_connection_create():
    cnxn = cyanodbc.Connection()
    assert not cnxn.connected

def test_connection_properties(sqlite_connection):    
    sqlite_connection.connect("DRIVER=SQLite3 ODBC Driver;Database="
    ":memory:;LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;")
    assert sqlite_connection.connected
    assert sqlite_connection.get_info(SQLGetInfo.SQL_DBMS_NAME) == "SQLite"
    assert sqlite_connection.get_info(SQLGetInfo.SQL_DATABASE_NAME) == ":memory:"
    assert sqlite_connection.get_info(SQLGetInfo.SQL_DRIVER_NAME) == "sqlite3odbc.dll"    

def test_execute(sqlite_connection, sqlite_db):
    sqlite_connection.connect("DRIVER=SQLite3 ODBC Driver;Database="
    "example.db;LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;")
    cursor = sqlite_connection.cursor()
    cursor.execute("select symbol, trans from stocks")
    while cursor.next:
        pass
    assert cursor.rows == 3
     

