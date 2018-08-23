FILE(COPY cyanodbc DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
FILE(GLOB_RECURSE PYX_FILES
    RELATIVE ${CMAKE_CURRENT_BINARY_DIR}
    CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_BINARY_DIR}/*.pyx

)

list(JOIN PYX_FILES " " PYX_FILES_ARG)

add_custom_command(OUTPUT cyanodbc.cpp
                   COMMAND cython --cplus -3 -p --line-directives  -o cyanodbc.cpp ${PYX_FILES}
                   DEPENDS ${PYX_FILES}
                   COMMENT "Running Cython"
                   )
message("PYX_FILES: ${PYX_FILES}")

find_package(nanodbc REQUIRED)
find_package (Python3 REQUIRED COMPONENTS Development)

add_library(cyanodbc SHARED
            cyanodbc.cpp)
target_link_libraries(cyanodbc nanodbc Python3::Python)

set_property (TARGET cyanodbc PROPERTY PREFIX "")
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
set_property (TARGET cyanodbc PROPERTY SUFFIX ".pyd")
endif()