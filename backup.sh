#!/bin/bash
docker exec -u postgres sdgdatahubruntime_postgres_1 pg_dump --format=custom -d ckan > ckan.dump
aws s3 cp ckan.dump s3://sdgdatahub-backups/ckan.dump
