FILE(COPY cyanodbc DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
FILE(COPY setup.py.in DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
configure_file(setup.py.in setup.py)
FILE(GLOB_RECURSE PYX_FILES
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.pyx

)


list(TRANSFORM PYX_FILES REPLACE "\\.pyx\$" ".cpp"
    OUTPUT_VARIABLE CPP_FILES)

find_program(CYTHON cython)


message("Pyx files: ${PYX_FILES}, Cpp files: ${CPP_FILES}")

if(CYANODBC_ENABLE_COVERAGE)
    add_custom_command(
    OUTPUT ${CPP_FILES}
    COMMAND ${CYTHON} --cplus -a -3 -p --line-directives  -X linetrace=True ${PYX_FILES}
    DEPENDS ${PYX_FILES}
    COMMENT "Running Cython"
    COMMAND_EXPAND_LISTS)

    add_definitions(-DCYTHON_TRACE=1 -DCYTHON_TRACE_NOGIL=1)
else()
    add_custom_command(
    OUTPUT ${CPP_FILES}
    COMMAND ${CYTHON} --cplus -a -3 -p --line-directives  ${PYX_FILES}
    DEPENDS ${PYX_FILES}
    COMMENT "Running Cython"
    COMMAND_EXPAND_LISTS)
endif()


find_package(nanodbc REQUIRED)

# Include Interpreter component to ensure libraries/includes are compatible
find_package (Python3 ${CYANODBC_TARGET_PYTHON} EXACT REQUIRED COMPONENTS Interpreter  Development)

add_library(_cyanodbc SHARED
    ${CPP_FILES})

target_include_directories(_cyanodbc PRIVATE ${Python3_INCLUDE_DIRS})


set_property (TARGET _cyanodbc PROPERTY PREFIX "")
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    target_link_libraries(_cyanodbc nanodbc Python3::Python)
    set_property (TARGET _cyanodbc PROPERTY SUFFIX ".pyd")
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    target_link_libraries(_cyanodbc nanodbc)
    set_property (TARGET _cyanodbc PROPERTY SUFFIX ".so")
endif()

set_target_properties( _cyanodbc
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/cyanodbc"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/cyanodbc"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/cyanodbc"
    
)

  set(CYANODBC_CONFIG _cyanodbc-config)
  # 'make install' to the correct location
  if(BUILD_SHARED_LIBS)
    install(TARGETS _cyanodbc
      EXPORT ${CYANODBC_CONFIG} # associate installed target files with export
      INCLUDES DESTINATION include
      LIBRARY DESTINATION lib
      ARCHIVE DESTINATION lib
      RUNTIME DESTINATION bin) # for Windows
  else()
    install(TARGETS _cyanodbc
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
  export(TARGETS _cyanodbc FILE ${CYANODBC_CONFIG}.cmake)
