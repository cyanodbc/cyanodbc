# cyanodbc
A Cython Wrapper for Nanodbc

## Testing
1. Start up a SQL Server docker image to test SQL functionality.
Instructions can be found at: https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-2017

The main command is 
```
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Passw0rd"    -p 1433:1433 --name sql1    -d microsoft/mssql-server-linux:2017-latest
```
To build Debug python with valgrind:
```
CC=/usr/local/opt/llvm/bin/clang CXX=/usr/local/opt/llvm/bin/clang++ ../configure --with-pydebug --without-pymalloc --with-valgrind --prefix=$HOME/cpython-custom CFLAGS=-I$(brew --prefix)/opt/openssl/include LDFLAGS=-L$(brew --prefix)/opt/openssl/lib
make install VERBOSE=1
```

To install nanodbc on OSX():
```
cd nanodbc
mkdir build
cd build
CC=/usr/local/opt/llvm/bin/clang CXX=/usr/local/opt/llvm/bin/clang++ cmake -DNANODBC_ENABLE_BOOST=ON  -DCMAKE_INSTALL_PREFIX=$HOME -DCMAKE_BUILD_TYPE=Debug ..

make install VERBOSE=1
```

To build cyanodbc on OSX:
```
CC=/usr/local/opt/llvm/bin/clang CXX=/usr/local/opt/llvm/bin/clang++  LDFLAGS="-undefined dynamic_lookup" cmake -DCMAKE_BUILD_TYPE=Debug    -DCMAKE_INSTALL_PREFIX=$HOME -DCMAKE_PREFIX_PATH=$HOME/cpython-custom ..

export PYTHONPATH=/Users/dash/repos/cyanodbc/build/src/python
export PATH=/Users/dash/Downloads/cpython-3.5/valgrind-exe/usr/local/bin:$PATH

```


Testing with valgrind
```
valgrind --tool=memcheck --dsymutil=yes --track-origins=yes --show-leak-kinds=all --trace-children=yes --suppressions=$HOME/valgrind-python.supp $HOME/cpython-custom/bin/python3.5 -X showrefcount
```


https://stackoverflow.com/questions/48289858/fatal-error-in-extension-pythreadstate-get-no-current-thread-when-using-swig-w


https://superuser.com/questions/289344/is-there-something-like-command-substitution-in-windows-cli

https://stackoverflow.com/questions/24174394/cmake-is-not-able-to-find-python-libraries

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set_property (TARGET cyanodbc PROPERTY SUFFIX ".so")
endif()