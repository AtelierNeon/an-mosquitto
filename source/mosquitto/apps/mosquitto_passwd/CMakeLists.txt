include_directories(${mosquitto_SOURCE_DIR} ${mosquitto_SOURCE_DIR}/include
		${mosquitto_SOURCE_DIR}/lib ${mosquitto_SOURCE_DIR}/src
		${OPENSSL_INCLUDE_DIR} ${STDBOOL_H_PATH} ${STDINT_H_PATH})

if (WITH_TLS)
	set(MOSQ_PASS_SRCS
		mosquitto_passwd.c
		get_password.c get_password.h
		../../lib/memory_mosq.c ../../lib/memory_mosq.h
		../../src/memory_public.c
		../../lib/misc_mosq.c
		../../src/password_mosq.c ../../src/password_mosq.h
		)

	if (WIN32)
		include( Windows-MyExeVersion )
		generate_product_exe_version(MOSQ_PASS_VERSION_FILES
			NAME "mosquitto_passwd - manage password files for mosquitto"
			ICON ${mosquitto_SOURCE_DIR}/logo/mosquitto.ico
			VERSION_MAJOR ${MOSQ_VER_MAJOR}
			VERSION_MINOR ${MOSQ_VER_MINOR}
			VERSION_PATCH ${MOSQ_VER_PATCH}
			VERSION_REVISION ${MY_REVISION}
			ORIGINAL_FILENAME "mosquitto_passwd.exe")
		set (MOSQ_PASS_SRCS ${MOSQ_PASS_SRCS} ${MOSQ_PASS_VERSION_FILES})
	endif (WIN32)

	add_executable(mosquitto_passwd
		${MOSQ_PASS_SRCS}
		)

	target_link_libraries(mosquitto_passwd ${OPENSSL_LIBRARIES})
	install(TARGETS mosquitto_passwd RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
endif (WITH_TLS)
