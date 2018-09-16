FILE(COPY cyanodbc DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
FILE(GLOB_RECURSE PYX_FILES
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.pyx

)


list(TRANSFORM PYX_FILES REPLACE "\\.pyx\$" ".cpp"
    OUTPUT_VARIABLE CPP_FILES)

find_program(CYTHON cython)


message("Pyx files: ${PYX_FILES}, Cpp files: ${CPP_FILES}")
add_custom_command(
    OUTPUT ${CPP_FILES}
    COMMAND ${CYTHON} --cplus -a -3 -p --line-directives ${PYX_FILES}
    DEPENDS ${PYX_FILES}
    COMMENT "Running Cython"
    COMMAND_EXPAND_LISTS)



find_package(nanodbc REQUIRED)

# Include Interpreter component to ensure libraries/includes are compatible
find_package (Python3 ${CYANODBC_TARGET_PYTHON} EXACT REQUIRED COMPONENTS Interpreter  Development)

add_library(cyanodbc SHARED
    ${CPP_FILES})

target_include_directories(cyanodbc PRIVATE ${Python3_INCLUDE_DIRS})


set_property (TARGET cyanodbc PROPERTY PREFIX "")
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    target_link_libraries(cyanodbc nanodbc Python3::Python)
    set_property (TARGET cyanodbc PROPERTY SUFFIX ".pyd")
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    target_link_libraries(cyanodbc nanodbc)
    set_property (TARGET cyanodbc PROPERTY SUFFIX ".so")
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
