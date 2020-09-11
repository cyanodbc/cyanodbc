import cyanodbc
import dbapi20
import pytest
import sys
import threading
from time import sleep

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

    def test_zero_decimal_context(self):
        params = [ ['Phone2', 100.12], ['Tablet2', 500.321] ]
        con = self._connect()
        crsr = con.cursor()
        try:
            crsr.execute("DROP TABLE IF EXISTS public.%sproducts" % self.table_prefix)
            crsr.execute( \
                "CREATE TABLE public.%sproducts "
                "(id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, price NUMERIC(5, 0))" % self.table_prefix)
            crsr.executemany("INSERT INTO public.%sproducts (name, price) VALUES (?, ?)" % self.table_prefix, params)
            crsr.execute("SELECT * FROM public.%sproducts" % self.table_prefix)
            res = crsr.fetchall()
            self.assertEqual(float(res[0][2]), 100.0)
            self.assertEqual(float(res[1][2]), 500.0)
            crsr.execute("DROP TABLE public.%sproducts" % self.table_prefix)

        finally:
            con.close()

    def test_cancel(self):
        con = self._connect()
        crsr = con.cursor()
        res = {"test_result": None}
        event = threading.Event()
        def f(crsr, res, event):
            try:
                crsr.execute("SELECT PG_SLEEP(20)")
                res["test_result"] = "Failure"
            except cyanodbc.DatabaseError as e:
                res["test_result"] = "Success"
            event.set()
            return None
        try:
            threading.Thread(target = f, args = [crsr, res, event], daemon = True).start()
            sleep(2) # Give the thread a chance to kick off
            crsr.cancel()
            event.wait()
            self.assertEqual(res["test_result"], "Success")

        finally:
            con.close()
