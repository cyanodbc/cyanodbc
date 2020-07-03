import cyanodbc
import dbapi20


class CyanodbcDBApiTest(dbapi20.DatabaseAPI20Test):
    driver = cyanodbc
    connect_args = ("Driver={ODBC Driver 11 for SQL Server};Server=(local);UID=sa;PWD=Password12!;Database=tempdb;", )
    ""

    # nanodbc fetches all long columns using exact
    # size specification - there is no need for user
    # interaction here
    def test_setoutputsize(self):
        pass

    def test_nextset(self):
        pass # for sqlite no nextset()
