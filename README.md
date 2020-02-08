# A set of scripts for generating certificates

- `kt-pkcs12-chain-ca-ca1-ca2-my.sh`: create certificates chain using keytool in pkcs12 store format
- `kt-jks-chain-ca-ca1-ca2-my.sh`: create certificates chain using keytool in java jks store format
- `kt-view-certs-in-store.sh` : views ceritifcates in a keystore
- `kt-pkcs12-self-signed.sh` : create self-signed certificate

## Reference
- keytool -gencert
  
  https://www.ibm.com/support/knowledgecenter/en/SSYKE2_8.0.0/com.ibm.java.security.component.80.doc/security-component/keytoolDocs/gencert.html

- Certificate ext named extension
 
  https://www.ibm.com/support/knowledgecenter/SSYKE2_8.0.0/com.ibm.java.security.component.80.doc/security-component/keytoolDocs/commonoptions.html#commonoptions

- Configure a Java HTTP Client to Accept Self-Signed Certificates

  https://kb.novaordis.com/index.php/Configure_a_Java_HTTP_Client_to_Accept_Self-Signed_Certificates