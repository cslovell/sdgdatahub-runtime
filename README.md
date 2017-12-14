# CKAN Docker

1. run `docker-compose up`
2. open a command line on the ckan container `docker exec -it ckan /bin/bash`
3. create an admin (assuming an admin user exists) `paster --plugin=ckan sysadmin add admin -c /etc/ckan/default/default.ini`
4. log in to ckan `localhost:5000/ckan-admin`
