set(shared_src client_shared.c client_shared.h client_props.c)

if (WITH_SRV)
	add_definitions("-DWITH_SRV")
endif (WITH_SRV)

set( CLIENT_INC ${mosquitto_SOURCE_DIR} ${mosquitto_SOURCE_DIR}/include
            ${STDBOOL_H_PATH} ${STDINT_H_PATH} ${PTHREAD_INCLUDE_DIR}
            ${OPENSSL_INCLUDE_DIR})

set( CLIENT_DIR ${mosquitto_BINARY_DIR}/lib)

if (CJSON_FOUND)
	add_definitions("-DWITH_CJSON")
	set( CLIENT_DIR "${CLIENT_DIR};${CJSON_DIR}" )
	set( CLIENT_INC "${CLIENT_INC};${CJSON_INCLUDE_DIRS}" )
endif()

include_directories(${CLIENT_INC})
link_directories(${CLIENT_DIR})

set(mosq_pub_src pub_client.c pub_shared.c ${shared_src})
set(mosq_sub_src sub_client.c sub_client_output.c ${shared_src})
set(mosq_rr_src rr_client.c pub_shared.c sub_client_output.c ${shared_src})

if (WIN32)
	include( Windows-MyExeVersion )
	generate_product_exe_version(MOSQ_PUB_VERSION_FILES
		NAME "mosquitto_pub - an MQTT version 5/3.1.1/3.1 client for publishing simple messages"
		ICON ${mosquitto_SOURCE_DIR}/logo/mosquitto.ico
		VERSION_MAJOR ${MOSQ_VER_MAJOR}
		VERSION_MINOR ${MOSQ_VER_MINOR}
		VERSION_PATCH ${MOSQ_VER_PATCH}
		VERSION_REVISION ${MY_REVISION}
		ORIGINAL_FILENAME "mosquitto_pub.exe")
	set (mosq_pub_src ${mosq_pub_src} ${MOSQ_PUB_VERSION_FILES})
	generate_product_exe_version(MOSQ_SUB_VERSION_FILES
		NAME "mosquitto_sub - an MQTT version 5/3.1.1/3.1 client for subscribing to topics"
		ICON ${mosquitto_SOURCE_DIR}/logo/mosquitto.ico
		VERSION_MAJOR ${MOSQ_VER_MAJOR}
		VERSION_MINOR ${MOSQ_VER_MINOR}
		VERSION_PATCH ${MOSQ_VER_PATCH}
		VERSION_REVISION ${MY_REVISION}
		ORIGINAL_FILENAME "mosquitto_pub.exe")
	set (mosq_sub_src ${mosq_sub_src} ${MOSQ_SUB_VERSION_FILES})
	generate_product_exe_version(MOSQ_RR_VERSION_FILES
		NAME "mosquitto_rr - an MQTT version 5/3.1.1 client for request/response messaging"
		ICON ${mosquitto_SOURCE_DIR}/logo/mosquitto.ico
		VERSION_MAJOR ${MOSQ_VER_MAJOR}
		VERSION_MINOR ${MOSQ_VER_MINOR}
		VERSION_PATCH ${MOSQ_VER_PATCH}
		VERSION_REVISION ${MY_REVISION}
		ORIGINAL_FILENAME "mosquitto_rr.exe")
	set (mosq_rr_src ${mosq_rr_src} ${MOSQ_RR_VERSION_FILES})
endif (WIN32)

add_executable(mosquitto_pub ${mosq_pub_src})
add_executable(mosquitto_sub ${mosq_sub_src})
add_executable(mosquitto_rr ${mosq_rr_src})

if (CJSON_FOUND)
	target_link_libraries(mosquitto_pub ${CJSON_LIBRARIES})
	target_link_libraries(mosquitto_sub ${CJSON_LIBRARIES})
	target_link_libraries(mosquitto_rr ${CJSON_LIBRARIES})
endif()

if (WITH_STATIC_LIBRARIES)
	target_link_libraries(mosquitto_pub libmosquitto_static)
	target_link_libraries(mosquitto_sub libmosquitto_static)
	target_link_libraries(mosquitto_rr libmosquitto_static)
else()
	target_link_libraries(mosquitto_pub libmosquitto)
	target_link_libraries(mosquitto_sub libmosquitto)
	target_link_libraries(mosquitto_rr libmosquitto)
endif()

if (QNX)
    target_link_libraries(mosquitto_pub socket)
    target_link_libraries(mosquitto_sub socket)
    target_link_libraries(mosquitto_rr socket)
endif()

install(TARGETS mosquitto_pub RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
install(TARGETS mosquitto_sub RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
install(TARGETS mosquitto_rr RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
