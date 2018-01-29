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

exec paster serve --reload /etc/ckan/default/default.ini
#exec a2ensite ckan_default
#exec a2dissite 000-default
#exec rm -vi /etc/nginx/sites-enabled/default
#exec ln -s /etc/nginx/sites-available/ckan /etc/nginx/sites-enabled/ckan_default
#exec service apache2 reload
#exec service nginx reload

#exec echo "Abcd1234$" | paster --plugin=ckan sysadmin add sa --config=/etc/ckan/default/default.ini --stdin
