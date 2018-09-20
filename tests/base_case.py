import pytest

class BaseCase():
    ddl1 = """create table1 """
    ddl2 = """create table2"""

    insert1 = ()
    insert2 = ()

    driver =  None
    connect_args = () # List of arguments to pass to connect
    connect_kw_args = {} # Keyword arguments for connect

    def setUp(self):
        pass

    def tearDown(self):
        pass

    @pytest.fixture(scope="class")
    def db(self):
        self.setUp()
        yield
        self.tearDown()

    @pytest.fixture
    def connection(self, db):
        def cnxn():
            return self.driver.connect(
                *self.connect_args,**self.connect_kw_args
                )
        yield cnxn
        


        
    def test_connect(self, connection):
        con = connection()
        con.close()
    
    def test_ddl1(self, connection):
        cnxn = connection()
        cur = cnxn.cursor()
        con.execute(self.ddl1)
        con.execute(self.ddl2)

    def test_type_STRING(self):
        pass
    def test_type_BINARY(self):
        pass
    def test_type_NUMBER(self):
        pass
    def test_type_DATETIME(self):
        pass
    def test_type_ROWID(self):
        pass
    

        

    


