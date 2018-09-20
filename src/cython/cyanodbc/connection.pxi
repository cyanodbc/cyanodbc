cdef class Connection:
    cdef nanodbc.connection c_cnxn
    cdef nanodbc.statement  c_stmt
    cdef unique_ptr[nanodbc.transaction] c_trxn_ptr

    def __cinit__(self):
        self.c_cnxn = nanodbc.connection()
        self.c_trxn_ptr.reset(new nanodbc.transaction(self.c_cnxn))
        

    def _connect(self, dsn, username=None, password=None, long timeout=0):
        if username and password:
            self.c_cnxn.connect(dsn.encode(),username.encode(), password.encode(), timeout)
        else:
            self.c_cnxn.connect(dsn.encode(), timeout)
        self.c_stmt = nanodbc.statement(self.c_cnxn)
    
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
        return Cursor(self)

    def close(self):
        #try:
            if self.c_cnxn.connected():
                self.c_stmt.close()
                self.c_cnxn.disconnect()
            else:
                raise DatabaseError("Connection inactive")
        
            #log(traceback.format_exc(e), logging.WARNING)
             
            

    # @property
    # def transactions(self):
    
    #     return self.c_cnxn.transactions()

    @property
    def dbms_name(self):
        return self.c_cnxn.dbms_name().decode('UTF-8')
    
    # @property
    # def dbms_version(self):
    #     return self.c_cnxn.dbms_version().decode('UTF-8')

    # @property
    # def driver_name(self):
    #     return self.c_cnxn.driver_name().decode('UTF-8')

    # @property
    # def database_name(self):
    #     return self.c_cnxn.database_name().decode('UTF-8')

    # @property
    # def catalog_name(self):
    #     return self.c_cnxn.catalog_name().decode('UTF-8')

def connect(dsn, username=None, password=None, long timeout=0):
    cnxn = Connection()
    cnxn._connect(dsn, username, password, timeout)
    return cnxn