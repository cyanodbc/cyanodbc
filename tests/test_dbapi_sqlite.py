import cyanodbc
import dbapi20


class CyanodbcDBApiTest(dbapi20.DatabaseAPI20Test):
    driver = cyanodbc
    connect_args = ("DRIVER=SQLite3 ODBC Driver;Database="
    "example.db;LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;", )
    ""
    def test_setoutputsize(self):
        pass

    def test_nextset(self):
        pass # for sqlite no nextset()