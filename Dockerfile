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
    build-essential

RUN pip install -q virtualenv virtualenvwrapper requests

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

RUN pip install -q -e 'git+https://github.com/djson8/ckanext-sdgdata.git#egg=ckanext-sdgdata'
RUN pip install -q -e 'git+https://github.com/djson8/ckanext-showcase.git#egg=ckanext-showcase'

RUN mkdir -p /etc/ckan/default

COPY config/default.ini /etc/ckan/default/default.ini
RUN ln -s /src/ckan/who.ini /etc/ckan/default/who.ini
COPY ./docker-entrypoint.sh /
