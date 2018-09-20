import cyanodbc
import base_case
import pytest

pytestmark = pytest.mark.skip("WIP")
class TestPostgres(base_case.BaseCase):
    driver = cyanodbc
    connect_args = ("Driver={PostgreSQL ODBC Driver(UNICODE)};Database=test;Server=localhost;Port=5432;Uid=postgres;Pwd=Password12!;",)
    
    ddl1 = """ CREATE TABLE so_header (
    so_header_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    
    ship_to VARCHAR (255)
    );
    """

    ddl2 = """ CREATE TABLE so_item (
    so_item_id INTEGER PRIMARY KEY,
    so_header_id INTEGER,
    product_id INTEGER,
    qty INTEGER,
    net_price NUMERIC,
    FOREIGN KEY (so_header_id) REFERENCES so_header (so_header_id)
    );
    """

    #insert1 = (cyanodbc.integer(1), cyanodbc.integer(1), cyanodbc.string("7 Racecourse Road\n Elms, NY"))
    def setUp(self):
        cnxn = self.driver.connect(
                "Driver={PostgreSQL ODBC Driver(UNICODE)};Server=localhost;Port=5432;Uid=postgres;Pwd=Password12!;"
                )
        cur = cnxn.cursor()
        cur.execute("""DROP DATABASE IF EXISTS test""")
        cur.execute("""CREATE DATABASE test
            WITH 
            
            ENCODING = 'UTF8'
            CONNECTION LIMIT = -1;""")

    def tearDown(self):
        cnxn = self.driver.connect(
                "Driver={PostgreSQL ODBC Driver(UNICODE)};Server=localhost;Port=5432;Uid=postgres;Pwd=Password12!;"
                )
        cur = cnxn.cursor()

        cur.execute("""DROP DATABASE IF EXISTS test""")