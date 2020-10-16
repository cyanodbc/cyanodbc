import cyanodbc
import dbapi20
import pytest
import sys

@pytest.mark.skipif(sys.platform in ["Darwin", "darwin", "linux"], reason = "SQL Server Unavailable")
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

    #################################
    # Tests below are custom / in   #
    # addition to the dbapi20 tests #
    #################################
    def test_list_catalogs(self):
        con = self._connect()
        try:
            cats = con.list_catalogs()
            self.assertIsInstance(cats, list)
            self.assertIn("tempdb", cats)
            self.assertIn("master", cats)
        finally:
            con.close()

    def test_list_schemas(self):
        con = self._connect()
        try:
            cur = con.cursor()
            self.executeDDL1(cur)
            schemas = con.list_schemas()
            self.assertIsInstance(schemas, list)
            self.assertIn("dbo", schemas)
            cur.execute(self.xddl1)
        finally:
            con.close()

    def test_find_tables(self):
        con = self._connect()
        try:
            cur = con.cursor()
            self.executeDDL1(cur)
            tbls = con.find_tables(
                    catalog = "tempdb",
                    schema = "",
                    table = "",
                    type = "table"
            )
            self.assertIsInstance(tbls, list)
            self.assertEqual(tbls[0]._fields, ('catalog', 'schema', 'name', 'type'))

            self.assertIn(
                    ["tempdb", "dbo", "%sbooze" % self.table_prefix, "TABLE"],\
                    [list(t) for t in tbls])
            cur.execute(self.xddl1)
            tbls = con.find_tables(
                    catalog = "tempdb",
                    schema = "",
                    table = "",
                    type = "table"
            )
            self.assertNotIn(
                    ["tempdb", "dbo", "%sbooze" % self.table_prefix, "TABLE"],\
                    [list(t) for t in tbls])
        finally:
            con.close()

    def test_find_columns(self):
        con = self._connect()
        try:
            cur = con.cursor()
            self.executeDDL1(cur)
            cols = con.find_columns(
                    catalog = "tempdb",
                    schema = "dbo",
                    table = "%sbooze" % self.table_prefix,
                    column = ""
            )
            self.assertIsInstance(cols, list)
            self.assertEqual(len(cols), 1)
            self.assertEqual(cols[0]._fields,
                    ('catalog', 'schema', 'table', 'column', \
                    'data_type', 'type_name', 'column_size', \
                    'buffer_length', 'decimal_digits', \
                    'numeric_precision_radix', 'nullable', 'remarks', \
                    'default', 'sql_data_type', 'sql_datetime_subtype', \
                    'char_octet_length'))
            cur.execute(self.xddl1)
        finally:
            con.close()

    def test_find_procedures(self):
        con = self._connect()
        try:
            con.execute("""
                CREATE OR ALTER PROCEDURE dbo.cyano_test_proc
                    @arg_varchar VARCHAR(10), @arg_int INT
                AS
                    BEGIN
                        SELECT @arg_varchar AS A, @arg_int AS B, GETDATE() AS C
                    END;""")

            procs = con.find_procedures(
                    catalog = "tempdb",
                    schema = "",
                    procedure = "")
            self.assertIsInstance(procs, list)
            self.assertEqual(procs[0]._fields, ('catalog', 'schema', 'name', 'remarks', 'type'))

            self.assertIn("cyano_test_proc;1", [p.name for p in procs])
            procs = con.find_procedures(
                    catalog = "tempdb",
                    schema = "",
                    procedure = "%test_proc"
            )
            self.assertIn("cyano_test_proc;1", [p.name for p in procs])
            cols = con.find_procedure_columns(
                    catalog = "tempdb",
                    schema = "dbo",
                    procedure = "cyano_test_proc",
                    column = ""
            )
            self.assertIsInstance(cols, list)
            col_names = [c.column for c in cols]
            self.assertEqual(sorted(col_names), sorted(['@RETURN_VALUE', '@arg_varchar', '@arg_int']))
            con.execute("DROP PROCEDURE dbo.cyano_test_proc")
            procs = con.find_procedures(
                    catalog = "tempdb",
                    schema = "",
                    procedure = "")
            self.assertNotIn("cyano_test_proc;1", [p.name for p in procs])
            cols = con.find_procedure_columns(
                    catalog = "tempdb",
                    schema = "dbo",
                    procedure = "cyano_test_proc",
                    column = ""
            )
            self.assertEqual(cols, [])

        finally:
            con.close()

    def test_dbms_name(self):
        con = self._connect()
        try:
            dbms = con.dbms_name
            self.assertEqual(dbms, "Microsoft SQL Server")
        finally:
            con.close()

    def test_dbms_version(self):
        con = self._connect()
        try:
            dbms_ver = con.dbms_version
            self.assertIsInstance(dbms_ver, str)
        finally:
            con.close()

    def test_catalog_name(self):
        con = self._connect()
        try:
            cur = con.cursor()
            cat = con.catalog_name
            self.assertEqual(cat, "tempdb")
            cur.execute("USE master")
            cat = con.catalog_name
            self.assertEqual(cat, "master")
        finally:
            con.close()

    # Microsoft's SQL Server OEM driver requires that SQLGetData be used
    # only after the last bound column.  Note that generically this doesn't
    # work with nanodbc since nanodbc binds buffers greedily.  To deal with this
    # internally for Microsoft's driver we unbind buffers past the first unbound
    # (blob/long) column.
    def test_out_of_order_blob(self):
        con = self._connect()
        try:
            tbl_name = "test_get_data_order"
            param_values = [1, 'this is varchar max', 11, 'this is text']
            cur = con.cursor()
            cur.execute('CREATE TABLE %s (c1 INT, c2 VARCHAR(MAX), c3 INT, c4 text)' % tbl_name)
            cur.execute("INSERT INTO %s VALUES(?, ?, ?, ?)" % tbl_name, param_values)
            cur.execute("SELECT c1, c2, c3, c4 FROM %s" % tbl_name)
            res = cur.fetchall()

            self.assertEqual(res, [param_values])
            cur.execute("DROP TABLE %s" % tbl_name)
        finally:
            con.close()

