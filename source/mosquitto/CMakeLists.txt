# This is a cmake script. Process it with the CMake gui or command line utility
# to produce makefiles / Visual Studio project files on Mac OS X and Windows.
#
# To configure the build options either use the CMake gui, or run the command
# line utility including the "-i" option.

cmake_minimum_required(VERSION 3.1...3.15.0)
cmake_policy(SET CMP0042 NEW)

project(mosquitto)
set (VERSION 2.0.18)

## Separate version number into 4 parts
string(REGEX MATCHALL "[0-9]+" _my_ver_LIST "${VERSION}")
list(LENGTH _my_ver_LIST _my_list_len)
list(GET _my_ver_LIST 0 MOSQ_VER_MAJOR)
list(GET _my_ver_LIST 1 MOSQ_VER_MINOR)
list(GET _my_ver_LIST 2 MOSQ_VER_PATCH)
if(_my_list_len EQUAL 4)
	list(GET _my_ver_LIST 3 MOSQ_VER_PATCHLEVEL)
endif()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/")

add_definitions (-DCMAKE -DVERSION=\"${VERSION}\")

if (WIN32)
	add_definitions("-D_CRT_SECURE_NO_WARNINGS")
	add_definitions("-D_CRT_NONSTDC_NO_DEPRECATE")
endif (WIN32)

if(APPLE)
	# https://github.com/eclipse/mosquitto/issues/2858#issuecomment-1664943798
	set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -undefined dynamic_lookup")
endif(APPLE)

include(GNUInstallDirs)

option(WITH_BUNDLED_DEPS "Build with bundled dependencies?" ON)
option(WITH_TLS
	"Include SSL/TLS support?" ON)
option(WITH_TLS_PSK
	"Include TLS-PSK support (requires WITH_TLS)?" ON)
option(WITH_EC
	"Include Elliptic Curve support (requires WITH_TLS)?" ON)
if (WITH_TLS)
	find_package(SiblingOpenSSL)
	if(NOT OPENSSL_FOUND)
		find_package(OpenSSL REQUIRED)
	endif(NOT OPENSSL_FOUND)
	add_definitions("-DWITH_TLS")

	if (WITH_TLS_PSK)
		add_definitions("-DWITH_TLS_PSK")
	endif (WITH_TLS_PSK)

	if (WITH_EC)
		add_definitions("-DWITH_EC")
	endif (WITH_EC)
else (WITH_TLS)
	set (OPENSSL_INCLUDE_DIR "")
endif (WITH_TLS)


option(WITH_UNIX_SOCKETS "Include Unix Domain Socket support?" ON)
if (WITH_UNIX_SOCKETS AND NOT WIN32)
	add_definitions("-DWITH_UNIX_SOCKETS")
endif (WITH_UNIX_SOCKETS AND NOT WIN32)

option(WITH_SOCKS "Include SOCKS5 support?" ON)
if (WITH_SOCKS)
	add_definitions("-DWITH_SOCKS")
endif (WITH_SOCKS)

option(WITH_SRV "Include SRV lookup support?" OFF)

option(WITH_STATIC_LIBRARIES "Build static versions of the libmosquitto/pp libraries?" OFF)
option(MOSQUITTO_WITH_SHARED_LIBRARIES "Build shared version of the libmosquitto/libmosquittopp libraries." OFF)
if (MOSQUITTO_WITH_SHARED_LIBRARIES)
	set (WITH_STATIC_LIBRARIES OFF)
else (MOSQUITTO_WITH_SHARED_LIBRARIES)
	set (WITH_STATIC_LIBRARIES ON)
endif(MOSQUITTO_WITH_SHARED_LIBRARIES)

option(WITH_PIC "Build the static library with PIC (Position Independent Code) enabled archives?" OFF)

option(WITH_THREADING "Include client library threading support?" OFF)
if (WITH_THREADING)
	add_definitions("-DWITH_THREADING")
	if (WIN32)
		find_package(Threads REQUIRED)
		set (PTHREAD_LIBRARIES Threads::Threads)
		set (PTHREAD_INCLUDE_DIR "")
	elseif (ANDROID)
		set (PTHREAD_LIBRARIES "")
		set (PTHREAD_INCLUDE_DIR "")
	else (WIN32)
		find_library(LIBPTHREAD pthread)
		if (LIBPTHREAD)
			set (PTHREAD_LIBRARIES pthread)
		else (LIBPTHREAD)
			set (PTHREAD_LIBRARIES "")
		endif()
		set (PTHREAD_INCLUDE_DIR "")
	endif (WIN32)
else (WITH_THREADING)
	set (PTHREAD_LIBRARIES "")
	set (PTHREAD_INCLUDE_DIR "")
endif (WITH_THREADING)

option(WITH_DLT "Include DLT support?" OFF)
message(STATUS "WITH_DLT = ${WITH_DLT}")
if (WITH_DLT)
	#find_package(DLT REQUIRED)
	find_package(PkgConfig)
	pkg_check_modules(DLT "automotive-dlt >= 2.11")
	add_definitions("-DWITH_DLT")
endif (WITH_DLT)

option(MOSQUITTO_WITH_SHARED_CJSON "Build mosquitto with shared version of cJSON." OFF)
option(WITH_CJSON "Build with cJSON support (required for dynamic security plugin and useful for mosquitto_sub)?" ON)
if (WITH_CJSON)
    if (MOSQUITTO_WITH_SHARED_CJSON)
		set (CJSON_USE_STATIC_LIBS OFF)
	else (MOSQUITTO_WITH_SHARED_CJSON)
		set (CJSON_USE_STATIC_LIBS ON)
	endif(MOSQUITTO_WITH_SHARED_CJSON)
    find_package(SiblingcJSON)
    if (NOT CJSON_FOUND)
        FIND_PACKAGE(cJSON)
    endif(NOT CJSON_FOUND)
    if (CJSON_FOUND)
	    message(STATUS ${CJSON_FOUND})
    else (CJSON_FOUND)
	    message(STATUS "Optional dependency cJSON not found. Some features will be disabled.")
    endif(CJSON_FOUND)
endif()

# ========================================
# Include projects
# ========================================

option(WITH_CLIENTS "Build clients?" ON)
option(WITH_BROKER "Build broker?" ON)
option(WITH_APPS "Build apps?" ON)
option(WITH_PLUGINS "Build plugins?" ON)
option(DOCUMENTATION "Build documentation?" OFF)

option(MOSQUITTO_WITH_LIBWEBSOCKETS "Build mosquitto with libwebsockets." OFF)
option(MOSQUITTO_WITH_SHARED_LIBWEBSOCKETS "Build mosquitto with shared version of libwebsockets." OFF)
if (WIN32)
	set( CMAKE_SHARED_LIBRARY_PREFIX "lib" )
	set( CMAKE_STATIC_LIBRARY_PREFIX "lib" )
endif()

add_subdirectory(lib)
if (WITH_CLIENTS)
	add_subdirectory(client)
endif (WITH_CLIENTS)

if (WITH_BROKER)
	add_subdirectory(src)
endif (WITH_BROKER)

if (WITH_APPS)
	add_subdirectory(apps)
endif (WITH_APPS)

if (WITH_PLUGINS)
	add_subdirectory(plugins)
endif (WITH_PLUGINS)

if (DOCUMENTATION)
	add_subdirectory(man)
endif (DOCUMENTATION)

# ========================================
# Install config file
# ========================================

if (WITH_BROKER)
	install(FILES mosquitto.conf aclfile.example pskfile.example pwfile.example DESTINATION "${CMAKE_INSTALL_SYSCONFDIR}/mosquitto")
endif (WITH_BROKER)

# ========================================
# Install pkg-config files
# ========================================

configure_file(libmosquitto.pc.in libmosquitto.pc @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/libmosquitto.pc" DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
configure_file(libmosquittopp.pc.in libmosquittopp.pc @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/libmosquittopp.pc" DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")

# ========================================
# Testing
# ========================================
enable_testing()
