find_program(PYTHON "python")
find_program(ECHO "ECHO")
if (PYTHON)
    set(SETUP_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in")
    set(SETUP_PY    "${CMAKE_CURRENT_BINARY_DIR}/setup.py")
    set(DEPS        "${CMAKE_CURRENT_SOURCE_DIR}/cyanodbc/__init__.py")
    set(OUTPUT      "${CMAKE_CURRENT_BINARY_DIR}/build/timestamp")
    message("PACKAGE_NAME: ${PROJECT_NAME} - ${CYANODBC_VERSION}")
    
    FILE(COPY cyanodbc DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
    configure_file("${SETUP_PY_IN}" ${SETUP_PY})


    add_custom_command(OUTPUT ${OUTPUT}
                       COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:cyanodbc> ${CMAKE_CURRENT_BINARY_DIR}/cyanodbc
                       COMMAND ${PYTHON} ${SETUP_PY} bdist_wheel 

                       COMMAND ${CMAKE_COMMAND} -E touch ${OUTPUT}

                       DEPENDS ${DEPS}
                       COMMENT "Copy pyd"
                       VERBATIM)


    # add_custom_command(OUTPUT ${OUTPUT}
    #                 #    COMMAND ${CMAKE_COMMAND} -E echo "$<TARGET_FILE:cyanodbc>" "${CMAKE_CURRENT_BINARY_DIR}/cyanodbc"

    #                    COMMAND ${PYTHON} ${SETUP_PY} bdist_wheel
    #                    COMMAND ${CMAKE_COMMAND} -E touch ${OUTPUT}

    #                    DEPENDS ${DEPS}
    #                    COMMENT "Running python setup.py bdist_wheel")

    add_custom_target(target ALL DEPENDS ${OUTPUT})

    # install(CODE "execute_process(COMMAND ${PYTHON} ${SETUP_PY} install)")
endif()