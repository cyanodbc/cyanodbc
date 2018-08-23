cmake_minimum_required(VERSION 3.12)
project(cyanodbc CXX)

# NOTE: All options follow CMake convention:
#       If no initial value is provided, OFF is used.

# CMake standard options
option(BUILD_SHARED_LIBS "Build shared library" OFF)
# cyanodbc specific options

option(CYANODBC_DISABLE_INSTALL "Do not generate install target" OFF)
option(CYANODBC_DISABLE_TESTS "Do not build tests" OFF)
option(CYANODBC_ENABLE_COVERAGE "Enable test coverage reporting for GCC/clang" OFF)

########################################
## cyanodbc version
########################################
file(STRINGS VERSION CYANODBC_VERSION REGEX "[0-9]+\\.[0-9]+\\.[0-9]+")
string(REGEX REPLACE "^([0-9]+)\\.[0-9]+\\.[0-9]+" "\\1" CYANODBC_VERSION_MAJOR "${CYANODBC_VERSION}")
string(REGEX REPLACE "^[0-9]+\\.([0-9])+\\.[0-9]+" "\\1" CYANODBC_VERSION_MINOR "${CYANODBC_VERSION}")
string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+)" "\\1" CYANODBC_VERSION_PATCH "${CYANODBC_VERSION}")
message(STATUS "cyanodbc version: ${CYANODBC_VERSION}")

########################################
## require and enable C++0x/11/14
########################################
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
message(STATUS "cyanodbc compile: C++${CMAKE_CXX_STANDARD}")

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_COMPILER_IS_GNUCXX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror")
  include(CheckCXXCompilerFlag)

  if (CYANODBC_ENABLE_COVERAGE)
    add_compile_options(--coverage -O0)
    link_libraries(gcov)
    message(STATUS "cyanodbc build: Enable test coverage - Yes")
  endif()

  if(NOT CYANODBC_DISABLE_LIBCXX)
    check_cxx_compiler_flag("-stdlib=libc++" CXX_SUPPORTS_STDLIB)
    if(CXX_SUPPORTS_STDLIB)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
      set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++")
      set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -stdlib=libc++")
      set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -stdlib=libc++")
    endif()
    set(CYANODBC_DISABLE_LIBCXX ${CYANODBC_DISABLE_LIBCXX} CACHE BOOL "Do not use libc++, if available." FORCE)
  endif()
  message(STATUS "cyanodbc build: Disable linking libc++ - ${CYANODBC_DISABLE_LIBCXX}")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Intel")
    string(REGEX REPLACE "[/-]W[0-4]" "/W4" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    if (NOT (CMAKE_VERSION VERSION_LESS 3.6.0)) # Compiler features for Intel in CMake 3.6+
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Qstd=c++17")
    endif()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /QaxCORE-AVX2")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /fp:precise")
    set(CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG}   /Od")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /O3")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Qipo")
elseif(MSVC)
  string(REGEX REPLACE "/W[0-4]" "/W4" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  if(MSVC_VERSION LESS 1700)
    message(FATAL_ERROR, "cyanodbc requires C++11-compliant compiler")
  endif()
endif()


add_subdirectory(src/cython)