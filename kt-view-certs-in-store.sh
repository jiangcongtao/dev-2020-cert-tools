#!/usr/bin/env bash
set -e -u
#set -x 

USAGE_STR="Usage: $0 [<StoreFile>] [<StorePass>]"
# [ $# -ge 1 -a "${1:- }" == "-h" ] && echo ${USAGE_STR} && exit 0

# print usage if '-h' occurs at command line
if printf '%s\n' $@ | egrep -q '^-h$'; then
    echo "Usage: "
    echo ${USAGE_STR}
    exit 0
fi

STORE_FILE=${1:-st-svr-keystore.jks}
STORE_PASS=${2:-password}

[ ! -f "${STORE_FILE}" ]  && echo "Error: File ${STORE_FILE} Not Exist! ${USAGE_STR}" && exit 1
keytool -list -v -storepass ${STORE_PASS} -keystore ${STORE_FILE}