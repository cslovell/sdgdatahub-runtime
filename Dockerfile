FROM python:2.7

MAINTAINER David Johnson <david.johnson@djson.net>

LABEL Description="CKAN 2.5.7 with customizations for SDG Data Hub."
LABEL software="CKAN"
LABEL software.version="2.5.7-sdgdatahub"
LABEL version="1.0"

RUN apt-get -qq update && \
    apt-get install -qq -y --no-install-recommends \
    postgresql-client \
    libpq-dev \
    git-core \
    build-essential \
    apache2 \
    libapache2-mod-wsgi \
    libapache2-mod-rpaf \
    nginx

RUN pip install -q virtualenv virtualenvwrapper requests awscli

RUN mkdir -p /usr/lib/ckan/default
RUN /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh"
RUN virtualenv --no-site-packages /usr/lib/ckan/default
RUN . /usr/lib/ckan/default/bin/activate

RUN pip install  -q -e 'git+https://github.com/ckan/ckan.git@ckan-2.5.7#egg=ckan'
RUN pip install -q -r /src/ckan/requirements.txt
RUN pip install -q --upgrade bleach
RUN pip install -q -e 'git+https://github.com/ckan/ckanext-harvest.git#egg=ckanext-harvest'
RUN pip install -q -r /src/ckanext-harvest/pip-requirements.txt
RUN pip install -q -e 'git+https://github.com/ckan/ckanext-dcat.git#egg=ckanext-dcat'
RUN pip install -q -r /src/ckanext-dcat/requirements.txt
RUN pip install -q ckanext-geoview

RUN pip install -q -e 'git+https://github.com/cslovell/ckanext-sdgdata.git#egg=ckanext-sdgdata'
RUN pip install -q -e 'git+https://github.com/cslovell/ckanext-showcase.git#egg=ckanext-showcase'

RUN mkdir -p /etc/ckan/default

COPY apache.wsgi /etc/ckan/default/apache.wsgi
#COPY ckan_default.conf /etc/apache2/sites-available/ckan_default.conf
COPY ports.conf /etc/apache2/ports.conf
COPY config/default.ini /etc/ckan/default/default.ini
#COPY ckan /etc/nginx/sites-available/ckan
RUN ln -s /src/ckan/who.ini /etc/ckan/default/who.ini
COPY ./docker-entrypoint.sh /
