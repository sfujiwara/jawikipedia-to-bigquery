#!/usr/bin/env bash

BUCKET_NAME="jawikipedia"

apt-get update
apt-get -y upgrade

# Install MySQL
debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
apt-get -y install mysql-server

# Create database
mysql -uroot -proot -e "create database jawikipedia"

gsutil cp gs://${BUCKET_NAME}/schema/*.json /tmp/

import_wikipedia () {
    wget https://dumps.wikimedia.org/jawiki/latest/jawiki-latest-$1.sql.gz
    gzip -df jawiki-latest-$1.sql.gz
    mysql -uroot -proot jawikipedia < jawiki-latest-$1.sql
    mysqldump -uroot -proot -T /tmp/ --fields-terminated-by="\t" --fields-optionally-enclosed-by="" --lines-terminated-by="\n" --fields-escaped-by="" jawikipedia $1
    gsutil cp /tmp/$1.txt gs://${BUCKET_NAME}/
    bq load --max_bad_records=100000 --source_format=CSV --field_delimiter='\t' --schema=/tmp/$1.json jawikipedia.$1 gs://jawikipedia/$1.txt
}

import_wikipedia category
# import_wikipedia page
# import_wikipedia externallinks

gcloud -q compute instances delete jawikipedia
