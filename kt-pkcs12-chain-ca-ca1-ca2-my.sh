#!/bin/bash
set -e -u 
#set -x

# Note: 
# - PKCS12 keystore key password must be at least 6 characters
# - PKCS12 keystore keypass and storepass must be the same

KEY_PASS=password
STORE_PASS=password

[ $# -ge 1 ] && KEY_PASS=$1 && STORE_PASS=$1

AUTHORITY_STORE=st-ca-keystore.p12
KEY_STORE=st-svr-keystore.p12
TRUST_STORE=st-svr-truststore.p12

PARAM_STORE_TYPE='-storetype PKCS12'

[ -f ${AUTHORITY_STORE} ] && rm ${AUTHORITY_STORE}
[ -f ${KEY_STORE} ] && rm  ${KEY_STORE}
[ -f ${TRUST_STORE} ] && rm  ${TRUST_STORE}

echo "=============================================================================="
echo "Creating third-party chain ca2 -> ca1 -> ca in CA store ${AUTHORITY_STORE} ..."
echo "=============================================================================="

keytool -genkeypair -alias ca  -dname cn=ca                           \
        -validity 10000 -keyalg RSA -keysize 2048                           \
        -ext BasicConstraints:critical=ca:true,pathlen:10000                \
        -keystore ${AUTHORITY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}

keytool -genkeypair -alias ca1 -dname cn=ca1                                \
        -validity 10000 -keyalg RSA -keysize 2048                           \
        -keystore ${AUTHORITY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE} 

keytool -genkeypair -alias ca2 -dname cn=ca2                                \
        -validity 10000 -keyalg RSA -keysize 2048                           \
        -keystore ${AUTHORITY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}


keytool -certreq -alias ca1                                                         \
        -keystore ${AUTHORITY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS}          \
| keytool   -gencert -alias ca                                                      \
            -ext KeyUsage:critical=keyCertSign                                      \
            -ext SubjectAlternativeName=dns:ca1                                     \
            -keystore ${AUTHORITY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS}  ${PARAM_STORE_TYPE}     \
| keytool -importcert -alias ca1                                                    \
            -keystore   ${AUTHORITY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS}  ${PARAM_STORE_TYPE}

keytool -certreq -alias ca2                                                     \
        -keystore ${AUTHORITY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS}      \
| keytool   -gencert -alias ca1                                                 \
            -ext KeyUsage:critical=keyCertSign                                  \
            -ext SubjectAlternativeName=dns:ca2                                 \
            -keystore ${AUTHORITY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS}  ${PARAM_STORE_TYPE} \
| keytool   -importcert -alias ca2                                              \
            -keystore ${AUTHORITY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}

#keytool -list -v -storepass ${STORE_PASS} -keystore ${AUTHORITY_STORE}


echo  "=========================================================================================================="
echo  "third-party chain generated in store ${AUTHORITY_STORE}. Now generating keystore ${KEY_STORE} ..."
echo  "=========================================================================================================="
read -p "Press a key to continue."

# Import authority's certificate chain

keytool -exportcert -alias ca                                               \
        -keystore ${AUTHORITY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS}  \
| keytool   -importcert -trustcacerts -noprompt -alias ca                   \
            -keystore  ${KEY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}

keytool -exportcert -alias ca1                                              \
        -keystore ${AUTHORITY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS}  \
| keytool   -importcert -noprompt -alias ca1                                \
            -keystore  ${KEY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}

keytool -exportcert -alias ca2                                              \
        -keystore ${AUTHORITY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS}  \
| keytool   -importcert -noprompt -alias ca2                                \
            -keystore  ${KEY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}

# Create our own certificate, the authority signs it.

keytool -genkeypair -alias e1  -dname cn=e1                                     \
        -validity 10000 -keyalg RSA -keysize 2048                               \
        -keystore ${KEY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}

keytool -certreq -alias e1                                                      \
        -keystore ${KEY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS}       \
| keytool   -gencert -alias ca2                                                 \
            -ext SubjectAlternativeName=dns:localhost                           \
            -ext KeyUsage:critical=keyEncipherment,digitalSignature             \
            -ext ExtendedKeyUsage=serverAuth,clientAuth                         \
            -keystore ${AUTHORITY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}  \
| keytool   -importcert -alias e1                                               \
            -keystore ${KEY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}

#keytool -list -v  -storepass ${STORE_PASS} -keystore ${KEY_STORE}

echo "============================================================================================="
echo "Keystore ${KEY_STORE} generated. Now generating truststore ${TRUST_STORE} ..."
echo "============================================================================================="
read -p "Press a key to continue."

keytool -exportcert -alias ca                                                   \
        -keystore ${KEY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS}       \
| keytool   -importcert -trustcacerts -noprompt -alias ca                       \
            -keystore ${TRUST_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}

keytool -exportcert -alias ca1                                                  \
        -keystore ${KEY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS}       \
| keytool   -importcert -noprompt -alias ca1                                    \
            -keystore ${TRUST_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}

keytool -exportcert -alias ca2                                                  \
        -keystore ${KEY_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS}       \
| keytool   -importcert -noprompt -alias ca2                                    \
            -keystore ${TRUST_STORE} -keypass ${KEY_PASS} -storepass ${STORE_PASS} ${PARAM_STORE_TYPE}

#keytool -list -v  -storepass ${STORE_PASS} -keystore  ${TRUST_STORE}

