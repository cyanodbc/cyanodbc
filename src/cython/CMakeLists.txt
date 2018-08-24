FILE(COPY cyanodbc DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
FILE(GLOB_RECURSE PYX_FILES
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.pyx

)

list(JOIN PYX_FILES " " PYX_FILES_ARG)

find_program(CYTHON cython)

add_custom_command(OUTPUT cyanodbc.cpp
                   COMMAND ${CYTHON} --cplus -3 -p --line-directives  -o cyanodbc.cpp ${PYX_FILES}
                   DEPENDS ${PYX_FILES}
                   COMMENT "Running Cython"
                   )

find_program(PYTHON python)

find_package(nanodbc REQUIRED)
find_package (Python3 3.6 EXACT REQUIRED COMPONENTS Development)

add_library(cyanodbc SHARED
            cyanodbc.cpp)
target_link_libraries(cyanodbc nanodbc Python3::Python)

set_property (TARGET cyanodbc PROPERTY PREFIX "")
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set_property (TARGET cyanodbc PROPERTY SUFFIX ".pyd")
endif()

  set(CYANODBC_CONFIG cyanodbc-config)
  # 'make install' to the correct location
  if(BUILD_SHARED_LIBS)
    install(TARGETS cyanodbc
      EXPORT ${CYANODBC_CONFIG} # associate installed target files with export
      INCLUDES DESTINATION include
      LIBRARY DESTINATION lib
      ARCHIVE DESTINATION lib
      RUNTIME DESTINATION bin) # for Windows
  else()
    install(TARGETS cyanodbc
      EXPORT ${CYANODBC_CONFIG} # associate installed target files with export
      INCLUDES DESTINATION include
      LIBRARY DESTINATION lib
      ARCHIVE DESTINATION lib)
  endif()
  # Make project importable from the install directory
  ## Generate and install *-config.cmake exporting targets from install tree.
  install(EXPORT ${CYANODBC_CONFIG} DESTINATION cmake)
  # Make project importable from the build directory
  ## Generate file *-config.cmake exporting targets from build tree.
  export(TARGETS cyanodbc FILE ${CYANODBC_CONFIG}.cmake)