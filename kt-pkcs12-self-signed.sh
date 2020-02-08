#!/bin/bash
set -e -u 
#set -x

# Note: 
# - PKCS12 keystore key password must be at least 6 characters
# - PKCS12 keystore keypass and storepass must be the same

# Usage: $0 <KEY_STORE_PASS> <KEY_ALIAS> <CERT_DNAME>
USAGE_STR="$0 [<KEY_STORE_PASS>] [<KEY_ALIAS>] [<CERT_DNAME>]"

# print usage if '-h' occurs at command line
if printf '%s\n' $@ | egrep -q '^-h$'; then
    echo "Usage: "
    echo ${USAGE_STR}
    exit 0
fi

KEY_ALIAS=${2:-localhost}
CERT_DNAME="cn=${3:-localhost}"

KEY_PASS=${1:-password}
STORE_PASS=${1:-password}

KEY_STORE=st-${KEY_ALIAS}-keystore.p12
TRUST_STORE=st-${KEY_ALIAS}-truststore.p12

PARAM_STORE_TYPE='-storetype PKCS12'

[ -f ${KEY_STORE} ] && rm  ${KEY_STORE}
[ -f ${TRUST_STORE} ] && rm  ${TRUST_STORE}

echo "=============================================================================="
echo "Creating self-signed key store ${KEY_STORE} ..."
echo "=============================================================================="

keytool -genkeypair -alias ${KEY_ALIAS} -dname ${CERT_DNAME}                              \
        -validity 10000 -keyalg RSA -keysize 2048                           \
        -keystore ${KEY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}


echo "============================================================================================="
echo "Keystore ${KEY_STORE} generated. Now generating truststore ${TRUST_STORE} ..."
echo "============================================================================================="
read -p "Press a key to continue."

keytool -exportcert -alias ${KEY_ALIAS}                                                  \
        -keystore ${KEY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS}       \
| keytool   -importcert -noprompt -alias ${KEY_ALIAS}                                    \
            -keystore ${TRUST_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}

#keytool -list -v  -storepass ${STORE_PASS} -keystore  ${TRUST_STORE}

