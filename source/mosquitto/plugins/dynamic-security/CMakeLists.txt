if (CJSON_FOUND AND WITH_TLS)
	add_definitions("-DWITH_CJSON")

	set( CLIENT_INC ${mosquitto_SOURCE_DIR} ${mosquitto_SOURCE_DIR}/include
		${STDBOOL_H_PATH} ${STDINT_H_PATH} ${PTHREAD_INCLUDE_DIR}
		${OPENSSL_INCLUDE_DIR} ${mosquitto_SOURCE_DIR}/deps
		${mosquitto_SOURCE_DIR}/src
		${CJSON_INCLUDE_DIRS} )

	set( CLIENT_DIR ${mosquitto_BINARY_DIR}/lib ${CJSON_DIR})

	include_directories(${CLIENT_INC})
	link_directories(${CLIENT_DIR} ${mosquitto_SOURCE_DIR})

	set(MOSQ_PLUG_DYNSEC_SRC
		acl.c
		auth.c
		clients.c
		clientlist.c
		dynamic_security.h
		groups.c
		grouplist.c
		json_help.c
		json_help.h
		plugin.c
		roles.c
		rolelist.c
		sub_matches_sub.c)

	if (WIN32)
		include( Windows-MyDllVersion )
		generate_product_dll_version(MOSQ_PLUG_DYNSEC_VERSION_FILES
			NAME "mosquitto_dynamic_security - Dynamic Security Plugin"
			VERSION_MAJOR ${MOSQ_VER_MAJOR}
			VERSION_MINOR ${MOSQ_VER_MINOR}
			VERSION_PATCH ${MOSQ_VER_PATCH}
			VERSION_REVISION ${MY_REVISION}
			ORIGINAL_FILENAME "mosquitto_dynamic_security.dll")
		set (MOSQ_PLUG_DYNSEC_SRC ${MOSQ_PLUG_DYNSEC_SRC} ${MOSQ_PLUG_DYNSEC_VERSION_FILES})
	endif (WIN32)

	add_library(mosquitto_dynamic_security MODULE
		${MOSQ_PLUG_DYNSEC_SRC})

	set_target_properties(mosquitto_dynamic_security PROPERTIES
		POSITION_INDEPENDENT_CODE 1
	)
	set_target_properties(mosquitto_dynamic_security PROPERTIES PREFIX "")

	target_link_libraries(mosquitto_dynamic_security ${CJSON_LIBRARIES} ${OPENSSL_LIBRARIES})
	if(WIN32)
		target_link_libraries(mosquitto_dynamic_security mosquitto)
		install(TARGETS mosquitto_dynamic_security
			DESTINATION "${CMAKE_INSTALL_BINDIR}")
	else()
		install(TARGETS mosquitto_dynamic_security
			RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
			LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}")
	endif()

endif()
