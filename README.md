# cyanodbc
A Cython Wrapper for Nanodbc  which dubs itself as a "A small C++ wrapper for the native C ODBC API".


## Build Status

| Branch |  Linux/OSX | Windows|Coverage|
|:--- |:--- |:---|:--|
| `master`  | [![master][travis-badge-master]][travis] | [![master][appveyor-badge-master]][appveyor] |[![master][coverage-badge-master]][coverage] |
 
## Building
To build Cyanodbc, you'll need CMake, Ninja, Cython, and Python. Additionally to run tests you will need pytest. The good news is all of these are available on [PyPi](https://pypi.org), so they are just a pip install away. 

```{sh}
pip install requirements.txt

```
### Build Nanodbc

The first step is to build and install Nanodbc.

On Unix-like or OSX systems try:

```{sh}
git clone https://github.com/nanodbc/nanodbc.git
cd nanodbc
mkdir build
cd build
cmake -G Ninja -DNANODBC_ENABLE_BOOST=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME -DNANODBC_DISABLE_TESTS=ON ..
cmake --build . --target install
```

On windows you might try:

```{cmd}
git clone https://github.com/nanodbc/nanodbc.git
cd nanodbc
mkdir build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%USERPROFILE% -DNANODBC_DISABLE_TESTS=ON ..
cmake --build . --target install

```


(Note: Please check the [Nanodbc Project](https://github.com/nanodbc/nanodbc) to know more about the cmake options used)

### Building Cyanodbc

Now to the interesting part- building cyanodbc. 

On Unix-like or OSX
```{sh}
git clone https://github.com/rdhushyanth/cyanodbc.git
cd cyanodbc
mkdir build
cd build

LDFLAGS="-undefined dynamic_lookup" cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME  -DCYANODBC_TARGET_PYTHON=3.5 ..


```


On Windows, make sure you have Visual Studio 2015(or VS 2017 with 2015 C++) installed.

```{cmd}
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x64

git clone https://github.com/rdhushyanth/cyanodbc.git
cd cyanodbc
mkdir build
cd build

cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%USERPROFILE%  -DCYANODBC_TARGET_PYTHON=3.5 ..

```

Note: Make sure the CYANODBC_TARGET_PYTHON is set to the corresponding python version you are using - this works around certain quirks of CMake python identification

## Testing
Pytest is used for running the tests. 

simply run 

```
cd cyanodbc
pytest tests
```


[travis]:https://travis-ci.org/rdhushyanth/cyanodbc
[travis-badge-master]:  https://travis-ci.org/rdhushyanth/cyanodbc.svg?branch=master

[appveyor]:         https://ci.appveyor.com/project/rdhushyanth/cyanodbc?branch=master
[appveyor-badge-master]:   https://img.shields.io/appveyor/ci/rdhushyanth/cyanodbc/master.svg

[coverage]: https://codecov.io/gh/rdhushyanth/cyanodbc/branch/master
[coverage-badge-master]: https://codecov.io/gh/rdhushyanth/cyanodbc/branch/master/graph/badge.svg
