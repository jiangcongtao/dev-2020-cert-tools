#!/usr/bin/env bash
# -*- coding: utf-8 -*-

SERVER=${1:-www.bing.com}
PORT=${2:-443}

# Steps: 1. Get server certifcare  2. import certificate to truststore
# Reference : https://backstage.forgerock.com/knowledge/kb/article/a94909995

# 1. Get server certificate using command with the syntax like
#  echo "" | openssl s_client -connect [hostname:port] -showcerts 2>/dev/null | openssl x509 -out certfile.txt

echo "" | openssl s_client -connect ${SERVER}:${PORT} -showcerts 2>/dev/null | openssl x509 -out ${SERVER}.pem

# 2. import certificate to truststore using command with the syntax like
# keytool -importcert -alias [alias_of_certificate_entry] -file [path_to_certificate_file] -trustcacerts -keystore /path/to/truststore -storetype [storetype]

# Note: default JVM truststore  -keystore $JAVA_HOME/jre/lib/security/cacerts
#       if not using default JVM truststore, app need to use -Djavax.net.ssl.trustStore=/path/to/truststore to use it
keytool -importcert -noprompt -alias ${SERVER} -file ${SERVER}.pem -trustcacerts -keystore ./${SERVER}-truststore -storetype jks -storepass "password"

# view certs in store
keytool -list -v -keystore ./${SERVER}-truststore
