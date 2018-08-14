#! /bin/bash

# Wait until ready ( abit dirty)
(sleep 10 \
&& fusiondirectory-insert-schema \
&& fusiondirectory-insert-schema -i /etc/ldap/schema/fusiondirectory/systems-fd.schema /etc/ldap/schema/fusiondirectory/systems-fd-conf.schema)&

# Start fusion
/container/tool/run
