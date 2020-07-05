import cyanodbc
import dbapi20
from distro import linux_distribution
import pytest

class CyanodbcDBApiTest(dbapi20.DatabaseAPI20Test):
    driver = cyanodbc
    connect_args = ("Driver={SQLite3 ODBC Driver};Database="
    "example.db;Timeout=1000;", )
    ""
    def test_setoutputsize(self):
        pass

    def test_nextset(self):
        pass # for sqlite no nextset()

    @pytest.mark.skipif(linux_distribution()[2]=="xenial",
            reason = "Strange behavior seen in Xenial")
    def test_rowcount(self):
        super().test_rowcount()
