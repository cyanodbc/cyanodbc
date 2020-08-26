import cyanodbc
import dbapi20
import pytest
import sys

@pytest.mark.skipif(sys.platform not in ["darwin", "Darwin"], reason = "postgreSQL Unavailable")
class CyanodbcDBApiTest(dbapi20.DatabaseAPI20Test):
    driver = cyanodbc
    connect_args = ("Driver={PostgreSQL ODBC Driver(UNICODE)};Server=localhost;UID=postgres;Port=5432;Database=postgres", )
    ""

    def test_setoutputsize(self):
        pass

    def test_nextset(self):
        pass # for sqlite no nextset()

    @pytest.mark.skip(reason = "PSQL odbc driver returns rowcount 0 after CREATE TABLE")
    def test_rowcount():
        super().test_rowcount()

    @pytest.mark.skip(reason = "PSQL odbc driver returns rowcount 1 inserting two rows with prepared statement")
    def test_executemany():
        super().test_executemany()
