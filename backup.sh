#!/bin/bash
docker exec -u postgres sdgdatahubruntime_postgres_1 pg_dump --format=custom -d ckan > /home/ec2-user/ckan.dump
aws s3 cp /home/ec2-user/ckan.dump s3://sdgdatahub-backups/ckan.dump
