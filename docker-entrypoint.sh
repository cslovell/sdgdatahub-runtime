#!/bin/bash
checkDB () {
  # Check if the DB is live
  psql -d "$DATABASE_URL"
}

checkDB

while [ $? -gt 0 ]; do
  echo 'DB not ready waiting 10 seconds'
	sleep 10
	checkDB
done
cd /src/ckan && paster db init -c /etc/ckan/default/default.ini
paster --plugin=ckanext-harvest harvester initdb --config=/etc/ckan/default/default.ini

mkdir /home/.aws
echo "starting server"

exec paster serve /etc/ckan/default/default.ini

#exec echo "Abcd1234$" | paster --plugin=ckan sysadmin add sa --config=/etc/ckan/default/default.ini --stdin
