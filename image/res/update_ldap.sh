#!/bin/bash
set -e

# If already bootstraped then exit (Source: https://github.com/hrektts/docker-fusiondirectory-openldap/blob/master/init.sh)
BOOTSTRAPPED=/etc/ldap/slapd.d/bootstrapped
if [ -e ${BOOTSTRAPPED} ]; then
    exit 0
fi

# Insert the fusion schema
fusiondirectory-insert-schema \
&& fusiondirectory-insert-schema -i /etc/ldap/schema/fusiondirectory/systems-fd.schema /etc/ldap/schema/fusiondirectory/systems-fd-conf.schema

# Create environment vars (Source: https://github.com/hrektts/docker-fusiondirectory-openldap/blob/master/init.sh)
IFS='.' read -a domain_elems <<< "${LDAP_DOMAIN}"
SUFFIX=""
TOP=""
for elem in "${domain_elems[@]}" ; do
    if [ "x${SUFFIX}" = x ] ; then
        SUFFIX="dc=${elem}"
        TOP="${elem}"
    else
        SUFFIX="${SUFFIX},dc=${elem}"
    fi
done

CN_ADMIN="cn=admin,ou=aclroles,${SUFFIX}"
UID_FD_ADMIN="uid=fd-admin,${SUFFIX}"
CN_ADMIN_BS64=$(echo -n ${CN_ADMIN} | base64 | tr -d '\n')
UID_FD_ADMIN_BS64=$(echo -n ${UID_FD_ADMIN} | base64 | tr -d '\n')
FD_ADMIN_PASSWORD=${FD_ADMIN_PASSWORD:-"adminpassword"}

# Create FusionDirectory Structure ldif-File
cat <<EOF > /tmp/config.ldif
version: 1

dn: ou=aclroles,${SUFFIX}
objectclass: organizationalUnit
ou: aclroles

dn: cn=admin,ou=aclroles,${SUFFIX}
cn: admin
description: Gives all rights on all objects
gosaacltemplate: 0:all;cmdrw
objectclass: top
objectclass: gosaRole

dn: ou=fusiondirectory,${SUFFIX}
objectclass: organizationalUnit
ou: fusiondirectory

dn: cn=config,ou=fusiondirectory,${SUFFIX}
cn: config
fdaccountprimaryattribute: uid
fdaclrolerdn: ou=aclroles
fdacltabonobjects: FALSE
fdcasactivated: FALSE
fdcascontext: /cas
fdcashost: localhost
fdcasport: 443
fdcasservercacertpath: /etc/ssl/certs/ca.cert
fdcnpattern: %givenName% %sn%
fddashboardexpiredaccountsdays: 15
fddashboardnumberofdigit: 3
fddashboardprefix: PC
fddebuglevel: 0
fddisplayerrors: FALSE
fddisplayhookoutput: FALSE
fdenablesnapshots: TRUE
fdforcepassworddefaulthash: FALSE
fdforcesaslpasswordask: FALSE
fdforcessl: FALSE
fdhandleexpiredaccounts: FALSE
fdhttpauthactivated: FALSE
fdhttpheaderauthactivated: FALSE
fdhttpheaderauthheadername: AUTH_USER
fdlanguage: en_US
fdldapsizelimit: 200
fdldapstats: FALSE
fdlistsummary: TRUE
fdlogging: TRUE
fdloginattribute: uid
fdmodificationdetectionattribute: entryCSN
fdogrouprdn: ou=groups
fdpassworddefaulthash: ssha
fdpasswordrecoveryactivated: FALSE
fdpasswordrecoveryemail: to.be@chang.ed
fdpasswordrecoveryloginattribute: uid
fdpasswordrecoverymail2body:: SGVsbG8sCgpZb3VyIHBhc3N3b3JkIGhhcyBiZWVuIGNoYW
 5nZWQuCllvdXIgbG9naW4gaXMgc3RpbGwgJXMu
fdpasswordrecoverymail2subject: [FusionDirectory] Password recovery successf
 ul
fdpasswordrecoverymailbody:: SGVsbG8sCgpIZXJlIGlzIHlvdXIgaW5mb3JtYXRpb246IAo
 gLSBMb2dpbiA6ICVzCiAtIExpbmsgOiAlcwoKVGhpcyBsaW5rIGlzIG9ubHkgdmFsaWQgZm9yID
 EwIG1pbnV0ZXMu
fdpasswordrecoverymailsubject: [FusionDirectory] Password recovery link
fdpasswordrecoverysalt: SomethingSecretAndVeryLong
fdpasswordrecoveryusealternate: FALSE
fdpasswordrecoveryvalidity: 10
fdrestrictrolemembers: FALSE
fdschemacheck: TRUE
fdsessionlifetime: 1800
fdsnapshotbase: ou=snapshots,${SUFFIX}
fdsplitpostaladdress: FALSE
fdsslcacertpath: /etc/ssl/certs/ca.cert
fdsslcertpath: /etc/ssl/certs/fd.cert
fdsslkeypath: /etc/ssl/private/fd.key
fdstrictnamingrules: TRUE
fdtheme: breezy
fdtimezone: America/New_York
fduserrdn: ou=people
fdwarnssl: TRUE
fusionconfigmd5: 455edca99c74a0da8e43f12f87ca5fa7
objectclass: fusionDirectoryConf
objectclass: fdDashboardPluginConf
objectclass: fusionDirectoryPluginsConf
objectclass: fdPasswordRecoveryConf

dn: ou=locks,ou=fusiondirectory,${SUFFIX}
objectclass: organizationalUnit
ou: locks

dn: ou=recovery,ou=fusiondirectory,${SUFFIX}
objectclass: organizationalUnit
ou: recovery

dn: ou=people,${SUFFIX}
objectclass: organizationalUnit
ou: people

dn: uid=fd-admin,ou=people,${SUFFIX}
cn: System Administrator
givenname: System
objectclass: inetOrgPerson
objectclass: organizationalPerson
objectclass: person
sn: Administrator
uid: fd-admin
userpassword: ${FD_ADMIN_PASSWORD}
EOF

# Create FusionDirectory Modification ldif-File
cat <<EOF > /tmp/modify.ldif
dn: ${SUFFIX}
changetype: modify
add: description
description: ${TOP}
-
add: gosaaclentry
gosaaclentry: 0:subtree:${CN_ADMIN_BS64}:${UID_FD_ADMIN_BS64}
-
add: objectclass
objectclass: gosaDepartment
-
add: objectclass
objectclass: gosaAcl
-
add: ou
ou: ${TOP}
EOF

# Execute creation and modification
ldapadd -x -D "cn=admin,${SUFFIX}" -w ${LDAP_ADMIN_PASSWORD} -f /tmp/config.ldif
ldapmodify -x -D "cn=admin,${SUFFIX}" -w ${LDAP_ADMIN_PASSWORD} -f /tmp/modify.ldif

echo "ok"
exit
# Cleanup
rm /tmp/conf.ldif
rm /tmp/modify.ldif

# Set bootstrapped flag
touch ${BOOTSTRAPPED}
