#!/usr/bin/env zsh

##
## Global config
##
DIRNAME_CLI=/usr/bin/dirname
PWD_CLI=/bin/pwd
UNAME_CLI=/usr/bin/uname
SYSTEM_PLATFORM=$($UNAME_CLI)

echo "[$SYSTEM_PLATFORM] Applying preset options ..."
MY_PROJECT_CARES_WITHOUT_APPS=ON
MY_PROJECT_CARES_WITHOUT_TEST_APPS=ON
MY_PROJECT_CJSON_WITHOUT_TEST_APPS=ON
MY_PROJECT_LIBWEBSOCKETS_WITH_EXTERNAL_POLL=ON
MY_PROJECT_LIBWEBSOCKETS_WITHOUT_TEST_APPS=ON
MY_PROJECT_MOSQUITTO_WITH_LIBWEBSOCKETS=ON
MY_PROJECT_OPENSSL_WITH_DEPRECATED_CIPHERS=ON
MY_PROJECT_OPENSSL_WITH_ZLIB=ON
MY_PROJECT_OPENSSL_WITHOUT_APPS=ON
MY_PROJECT_ZLIB_WITHOUT_TEST_APPS=ON
echo "[$SYSTEM_PLATFORM] Applying default options ... DONE"

SCRIPT_DIR=$(cd -- "$(${DIRNAME_CLI} "${BASH_SOURCE[0]:-${(%):-%x}}")" &> /dev/null && ${PWD_CLI})
source $SCRIPT_DIR/build-darwin.zsh
