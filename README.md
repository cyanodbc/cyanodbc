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

On all platforms the first step is cloning the repo and seting up the build directory

```{sh}
git clone --recurse-submodules https://github.com/cyanodbc/cyanodbc.git
cd cyanodbc
mkdir build
cd build
```

From there, the next step is to build the shared library, using the cmake build system:

```{sh}
cmake -G Ninja -DNANODBC_ODBC_VERSION=SQL_OV_ODBC3 -DCMAKE_BUILD_TYPE=Release -DCYANODBC_TARGET_PYTHON=3.5 ..
cmake --build .
```

Cmake notes:

* Make sure the variable DCYANODBC_TARGET_PYTHON is set to the corresponding python version you are using - this works around certain quirks of CMake python identification.
* Nanodbc is built and linked automatically when you build cyanodbc.  We expose the following cmake compile-time options:

| CMake&nbsp;Option                  | Possible&nbsp;Values | Details |
| -----------------------------------| ---------------------| ------- |
| `NANODBC_ENABLE_BOOST`             | `OFF` or `ON`        | Use Boost for Unicode string convertions (requires [Boost.Locale][boost-locale]). Workaround to issue [#24](https://github.com/nanodbc/nanodbc/issues/24). |
| `NANODBC_ODBC_VERSION`             | `SQL_OV_ODBC3[...]`  | Forces ODBC version to use. Default is `SQL_OV_ODBC3_80` if available, otherwise `SQL_OV_ODBC3`. |

Please check the [Nanodbc Project](https://github.com/nanodbc/nanodbc) for more information on these as well as other options that can be made available, if there is a need.

Finally, once the shared library is built, you can install the package using `pip`

```{sh}
pip install -e src/cython
```

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
[coverage-badge-master]: #
