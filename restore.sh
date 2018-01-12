#!/bin/bash
aws s3 cp s3://sdgdatahub-backups/ckan.dump /home/ec2-user/ckan.dump
docker exec ckan paster --plugin=ckan db clean -c /etc/ckan/default/default.ini
docker cp /home/ec2-user/ckan.dump sdgdatahubruntime_postgres_1:/home/
docker exec -u postgres sdgdatahubruntime_postgres_1 pg_restore -v --clean --if-exists -d ckan /home/ckan.dump
