#! /bin/bash

# Wait until ready (a bit dirty)
(sleep 10; /opt/update_ldap.sh)&

# Start fusion
/container/tool/run
