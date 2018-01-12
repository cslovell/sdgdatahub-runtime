<img src="http://tfig.unece.org/images/logos/unescap-logo.png" align="right" width="300px" />

# SDG Data Hub

Version: 1.0 beta

## Author

[David Johnson](http://djson.io), *Big Data Consultant*, for [UNESCAP](http://www.unescap.org).

## Overview

The SDG Data Hub is a platform to expand and scale up the use of innovative data approaches in ESCAP member states as they close data gaps to monitor the SDGs. While there are ongoing efforts to build capacity in big data for SDGs in the UN through training (e.g. The UNECE Sandbox big data platform) and global inventories of standards (e.g. UN Stats Global inventory of Statistical Standards) and big data projects (UN Big Data Inventory), there has yet to be a single platform to bring together both information about different data, and how it has been applied to SDG research and development.  The Data Hub will bring together key indicator research projects, enable reproducible research and the sharing of methodology, consolidate training methodologies through interactive tutorials, and provide a hub for governments, industry, research and the development communities broadly to explore and adopt open source innovations. The Data Hub will connect researchers authoring peer-reviewed, innovative data science methods with opportunities to pilot and scale up the use of these for compiling and analysing SDG indicators. 

![Concept](sdgdatahub_concept.png)

The SDG Data Hub is built from a customized implementation of CKAN, the open source data platform in use by government and organizations around the world. 

## Installation on Amazon EC2

Launch an Amazon EC2 instance using Amazon Linux AMI 2017.09.1 (HVM), SSD Volume Type (tested against `ami-1a962263`), `t2.medium` instance type, and use the following in the Instance Details Advanved Details "User data" section:

    #!/bin/sh
    export PATH=/usr/local/bin:$PATH;

    yum update
    yum install docker -y
    service docker start
    mv /root/.dockercfg /home/ec2-user/.dockercfg
    chown ec2-user:ec2-user /home/ec2-user/.dockercfg
    usermod -a -G docker ec2-user
    curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    chown root:docker /usr/local/bin/docker-compose

    yum install git -y
    git clone https://github.com/cslovell/sdgdatahub-runtime /home/ec2-user/sdgdatahub-runtime
    /usr/local/bin/docker-compose -f /home/ec2-user/sdgdatahub-runtime/docker-compose.yml up -d
    
100GiB of EBS is recommended and take care to ensure your Security Group has exposed ports 80 and 443 (HTTP/HTTPS).

Once you've created your container, you will need to login and enter the container, and type the following command: 

    docker ps
    
This will show a list of containers. Get the "container id" of the image "sdgdatahubruntime_ckan". (In this case, it was 05b63985539d.) Once you do, type the following command: 

    docker exec -it 05b63985539d sh
    . /usr/lib/ckan/default/bin/activate
    paster --plugin=ckan sysadmin add sa --config=/etc/ckan/default/default.ini

## Restore latest database

Download the last backup from s3: 

    aws s3 cp s3://sdgdatahub-backups/ckan.dump ckan.dump

Second, wipe the database:
    
    docker exec ckan paster --plugin=ckan db clean -c /etc/ckan/default/default.ini

Third, navigate to the folder where the database copy was stored and copy the database into the docker container (assuming it is called "ckan.dump"): 

    docker cp ckan.dump sdgdatahubruntime_postgres_1:/home/
    
Finally, restore the database: 

    docker exec -u postgres sdgdatahubruntime_postgres_1 pg_restore -v --clean --if-exists -d ckan /home/ckan.dump
    
## Backup the database

To backup the database to aws, run the following: 

    docker exec -u postgres sdgdatahubruntime_postgres_1 pg_dump --format=custom -d ckan > ckan.dump
    aws s3 cp ckan.dump s3://sdgdatahub-backups/ckan.dump
    
## Restart and reload from github

In the home directory [ec2-user], create two files, one "credentials" and another "config". In the credentials file, put the following (replacing with your own): 

    [default]
    aws_access_key_id=AKIAIOSFODNN7EXAMPLE
    aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

In the config file, put the following: 

    [default]
    region=us-west-2
    output=json

Create a file 

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)
sudo rm -R /home/ec2-user/sdgdatahub-runtime
git clone https://github.com/cslovell/sdgdatahub-runtime.git
/usr/local/bin/docker-compose -f /home/ec2-user/sdgdatahub-runtime/docker-compo
se.yml up -d
docker cp /home/ec2-user/config ckan:/home/.aws/config
docker cp /home/ec2-user/credentials ckan:/home/.aws/credentials
docker exec ckan export AWS_SHARED_CREDENTIALS_FILE=/home/.aws/credentials
docker exec ckan export AWS_CONFIG_FILE=/home/.aws/config
