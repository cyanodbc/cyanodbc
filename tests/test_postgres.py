import cyanodbc
import base_case
import datetime
import pytest

# pytestmark = pytest.mark.skip("WIP")
class TestPostgres(base_case.BaseCase):
    driver = cyanodbc
    connect_args = ("Driver={PostgreSQL Unicode(x64)};Database=test;Server=localhost;Port=5432;Uid=postgres;Pwd=Password12!;",)
    
    ddl1 = """ CREATE TABLE so_header (
    header_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    ship_to TEXT,
    creation_date TIMESTAMP,
    last_update_date TIMESTAMPTZ,
    created_by varchar(60),
    last_updated_by varchar(60),
    last_update_login varchar(60)
    );
    """

    ddl2 = """ CREATE TABLE so_item (
    item_id INTEGER PRIMARY KEY,
    header_id INTEGER,
    product_id INTEGER,
    qty INTEGER,
    net_price NUMERIC,
    FOREIGN KEY (header_id) REFERENCES so_header (header_id)
    );
    """

    insert1 = [
        ("header_id", 1),
        ("customer_id", 47),
        ("ship_to", "10 Racecourse Road\n Bangalore, India"),
        ("creation_date", datetime.datetime.now()),
        ("last_update_date", datetime.datetime.now(datetime.timezone.utc)),
        ("created_by", "Major Frank"),
        ("last_updated_by", "Rob Shaw"),
        ("last_update_login", "ROBSHAW"),

        ]
    def setUp(self):
        cnxn = self.driver.connect(
                "Driver={PostgreSQL Unicode(x64)};Server=localhost;Port=5432;Uid=postgres;Pwd=Password12!;"
                )
        cur = cnxn.cursor()
        cur.execute("""DROP DATABASE IF EXISTS test""")
        cur.execute("""CREATE DATABASE test
            WITH 
            
            ENCODING = 'UTF8'
            CONNECTION LIMIT = -1;""")

    def tearDown(self):
        cnxn = self.driver.connect(
                "Driver={PostgreSQL Unicode(x64)};Server=localhost;Port=5432;Uid=postgres;Pwd=Password12!;"
                )
        cnxn.close()