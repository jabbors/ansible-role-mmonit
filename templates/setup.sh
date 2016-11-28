#!/usr/bin/env bash

if [ -f /etc/.mmonit_installed ]; then
    # script has been run already
    exit 0
fi

host={{ mmonit_setup_url }}

# create secure cookie storage
mkdir -p -m 0700 ~/.mmonit

# go to login page to retrieve cookie
curl --insecure -c ~/.mmonit/cookie ${host}/index.csp # > /dev/null

# login
curl --insecure -b ~/.mmonit/cookie \
 -d z_username=admin \
 -d z_password=swordfish \
 -d z_csrf_protection=off \
 ${host}/z_security_check #> /dev/null

# Create admin
curl --insecure -b ~/.mmonit/cookie \
 -d uname='{{ mmonit_admin_username }}' \
 -d fullname='Administrator' \
 -d password='{{ mmonit_admin_password }}' \
 -d admin=1 \
 ${host}/admin/users/create > /dev/null

# Create monit user
curl --insecure -b ~/.mmonit/cookie \
 -d uname='{{ mmonit_connector_username }}' \
 -d fullname='monit' \
 -d password='{{ mmonit_connector_password }}' \
 -d admin=0 \
 ${host}/admin/users/create > /dev/null

# Delete default admin
curl --insecure -b ~/.mmonit/cookie \
 -d uname=admin \
 ${host}/admin/users/delete > /dev/null

# Delete default monit user
curl --insecure -b ~/.mmonit/cookie \
 -d uname=monit \
 ${host}/admin/users/delete > /dev/null

# Set done if grep is successful
curl --insecure -b ~/.mmonit/cookie ${host}/admin/users/list | grep '{{ mmonit_connector_username }}' && touch /etc/.mmonit_installed

# logout
curl --insecure -b ~/.mmonit/cookie ${host}/login/logout.csp

exit 0