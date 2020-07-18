cdef class Connection:
    cdef nanodbc.connection c_cnxn
    cdef unique_ptr[nanodbc.transaction] c_trxn_ptr
    cdef unique_ptr[nanodbc.catalog] c_cat_ptr
    cdef unique_ptr[nanodbc.tables] c_tbl_ptr
    cdef unique_ptr[nanodbc.columns] c_col_ptr

    cdef list cursors
    cdef int _get_data_any_order

    def __cinit__(self):
        self.c_cnxn = nanodbc.connection()
        self.c_cat_ptr.reset(new nanodbc.catalog(self.c_cnxn))
        self.c_trxn_ptr.reset(new nanodbc.transaction(self.c_cnxn))

    def __init__(self):
        self.cursors = []
        self._get_data_any_order = -1

    def _register_cursor(self, cursor not None):
        if cursor not in self.cursors:
            self.cursors.append(cursor)

    def _deregister_cursor(self, cursor not None):
        if cursor in self.cursors:
            self.cursors.remove(cursor)

    def _connect(self, dsn, username=None, password=None, long timeout=0):
        try:
            if username and password:
                self.c_cnxn.connect(dsn.encode(),username.encode(), password.encode(), timeout)
            else:
                self.c_cnxn.connect(dsn.encode(), timeout)
        except RuntimeError as e:
            raise ConnectError(str(e)) from e

    def find_tables(self, catalog, schema, table, type):
        """
        List all tables in the specified catalog, schema, table.
        This is a thin wrapper to the SQLTables ODBC endpoint.  For more
        information, see:
        https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/sqltables-function?view=sql-server-ver15

        :param catalog: The catalog to search.
        :param schema: The schema to search.
        :param table: The table to search.
        :param type: Type to search - should be 'VIEW' or 'TABLE'.  If an empty string, in theory the driver should return both.
        """
        out = []
        try:
            self.c_tbl_ptr.reset(new nanodbc.tables(
                deref(self.c_cat_ptr).find_tables(
                    table = table.encode(),
                    type = type.encode(),
                    schema = schema.encode(),
                    catalog = catalog.encode()
                )
            ))
            Row = namedtuple(
                'Row',
                ["catalog", "schema", "name", "type"],
                rename=True)
            while deref(self.c_tbl_ptr).next():
                out.append(Row(*[
                deref(self.c_tbl_ptr).table_catalog().decode(),
                deref(self.c_tbl_ptr).table_schema().decode(),
                deref(self.c_tbl_ptr).table_name().decode(),
                deref(self.c_tbl_ptr).table_type().decode()
                ]))
            return out
        except RuntimeError as e:
            raise DatabaseError("Error in find_tables: " + str(e)) from e

    def find_columns(self, catalog, schema, table, column):
        """
        List details for columns in the specified table.
        This is a thin wrapper to the SQLColumns ODBC endpoint.  For more
        information, see:
        https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/sqlcolumns-function?view=sql-server-ver15

        :param catalog: The table catalog.
        :param schema: The table schema.
        :param table: The table name.
        :param column: If interested in a specific column only enter here.  Otherwise if empty string, should return information on all columns.
        """
        out = []
        try:
            self.c_col_ptr.reset(new nanodbc.columns(
                deref(self.c_cat_ptr).find_columns(
                    column = column.encode(),
                    table = table.encode(),
                    schema = schema.encode(),
                    catalog = catalog.encode()
                )
            ))
            Row = namedtuple(
                'Row',
                ["catalog", "schema", "table", "column", "data_type", "type_name", "column_size", "buffer_length", "decimal_digits", "numeric_precision_radix", "nullable", "remarks", "default", "sql_data_type", "sql_datetime_subtype", "char_octet_length"],
                rename=True)
            while deref(self.c_col_ptr).next():
                out.append(Row(*[
                    deref(self.c_col_ptr).table_catalog().decode(),
                    deref(self.c_col_ptr).table_schema().decode(),
                    deref(self.c_col_ptr).table_name().decode(),
                    deref(self.c_col_ptr).column_name().decode(),
                    deref(self.c_col_ptr).data_type(),
                    deref(self.c_col_ptr).type_name().decode(),
                    deref(self.c_col_ptr).column_size(),
                    deref(self.c_col_ptr).buffer_length(),
                    deref(self.c_col_ptr).decimal_digits(),
                    deref(self.c_col_ptr).numeric_precision_radix(),
                    deref(self.c_col_ptr).nullable(),
                    deref(self.c_col_ptr).remarks().decode(),
                    deref(self.c_col_ptr).column_default().decode(),
                    deref(self.c_col_ptr).sql_data_type(),
                    deref(self.c_col_ptr).sql_datetime_subtype(),
                    deref(self.c_col_ptr).char_octet_length()
                ]))
            return out
        except RuntimeError as e:
            raise DatabaseError("Error in find_columns: " + str(e)) from e

    def list_catalogs(self):
        """
        List all catalogs in the data source attached to the connection.
        """
        try:
            res = deref(self.c_cat_ptr).list_catalogs()
        except RuntimeError as e:
            raise DatabaseError("Error in list_catalogs: " + str(e)) from e
        return [a.decode() for a in res]

    def list_schemas(self):
        """
        List all schemas in the current catalog.
        """
        try:
            res = deref(self.c_cat_ptr).list_schemas()
        except RuntimeError as e:
            raise DatabaseError("Error in list_schemas: " + str(e)) from e
        return [a.decode() for a in res]

    def commit(self):
        if self.c_cnxn.connected():
            deref(self.c_trxn_ptr).commit()
        else:
            raise DatabaseError("Connection inactive")
    
    def rollback(self):
        if self.c_cnxn.connected():
            deref(self.c_trxn_ptr).rollback()
        else:
            raise DatabaseError("Connection inactive")
        

    def get_info(self, short info_type):
        return self.c_cnxn.get_info[string](info_type).decode()

    @property
    def get_data_any_order(self):
        if self._get_data_any_order == -1:
        # In a perfect world we would query
        # SQL_GETDATA_EXTENSIONS to learn whether
        # a driver supports this extension.  However
        # some drivers don't accurately report this
        # (looking at you FreeTDS).  So for now we just lean
        # on experience.  We know the microsoft drivers
        # do not support this.
            if re.search("msodbcsql",
                self.get_info(SQLGetInfo.SQL_DRIVER_NAME)) and \
                (self.dbms_name == "Microsoft SQL Server"):
                self._get_data_any_order = 0
            else:
                self._get_data_any_order = 1

        return self._get_data_any_order == 1

    @property    
    def Error(self):
        return Error
    @property    
    def Warning(self):
        return Warning
    @property    
    def InterfaceError(self):
        return InterfaceError
    @property    
    def DatabaseError(self):
        return DatabaseError
    @property    
    def InternalError(self):
        return InternalError
    @property    
    def OperationalError(self):
        return OperationalError
    @property    
    def ProgrammingError(self):
        return ProgrammingError
    @property    
    def IntegrityError(self):
        return IntegrityError
    @property    
    def DataError(self):
        return DataError
    @property    
    def NotSupportedError(self):
        return NotSupportedError
    
    def cursor(self):
        cursor = Cursor(self)
        return cursor

    def connected(self):
        """
        Check to see if the underlying connection object reports as being
        connected.
        """
        return self.c_cnxn.connected()
    def close(self):
        #try:
            if self.c_cnxn.connected():
                for crsr in self.cursors:
                    try:
                        crsr.close()
                    except RuntimeError as e:
                        # There are many reasons why trying to close all
                        # cursors could fail.
                        continue
                self.c_cnxn.disconnect()
            else:
                raise DatabaseError("Connection inactive")
        
            #log(traceback.format_exc(e), logging.WARNING)
             
            
    def execute(self, query, parameters=None):
        """
        This method is equivalent to obtaining a cursor and calling its
        execute method.  Returns the cursor.
        """
        crsr = self.cursor()
        crsr.execute(query, parameters)
        return crsr

    # @property
    # def transactions(self):
    
    #     return self.c_cnxn.transactions()

    @property
    def dbms_name(self):
        """
        Retrieve the name of the DBMS product accessed by the driver.  Thin
        wrapper around a call to the ODBC SQLGetInfo endpoint, with an
        argument SQL_DBMS_NAME.  See:
        https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/sqlgetinfo-function?view=sql-server-ver15
        """
        return self.c_cnxn.dbms_name().decode('UTF-8')
    
    @property
    def dbms_version(self):
        """
        Retrieve the version of the DBMS product accessed by the driver.  Thin
        wrapper around a call to the ODBC SQLGetInfo endpoint, with an
        argument SQL_DBMS_VER.  See:
        https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/sqlgetinfo-function?view=sql-server-ver15
        """
        return self.c_cnxn.dbms_version().decode('UTF-8')

    # @property
    # def driver_name(self):
    #     return self.c_cnxn.driver_name().decode('UTF-8')

    @property
    def catalog_name(self):
        """
        Retrieve the catalog we are currently attached to.  Thin wrapper
        around a call to the ODBC SQLGetConnectAttr endpoint, with an argument
        SQL_ATTR_CURRENT_CATALOG.  See:
        https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/sqlgetconnectattr-function?view=sql-server-ver15
        """
        return self.c_cnxn.catalog_name().decode('UTF-8')

def connect(dsn, username=None, password=None, long timeout=0):
    cnxn = Connection()
    cnxn._connect(dsn, username, password, timeout)
    return cnxn

def datasources():
    out = {}
    res = nanodbc.list_datasources()
    for r in res:
        out.update({ r.name.decode() : r.driver.decode() })
    return out
