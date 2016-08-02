#!/usr/bin/env bash

PROJECT_ID=`gcloud config list project | tr '\n' ' ' | cut -d' ' -f4`
BUCKET_NAME="${PROJECT_ID}.appspot.com"

gsutil cp schema/*.json gs://${BUCKET_NAME}/schema/

# Create instance
gcloud compute instances create "jawikipedia" \
  --zone "asia-east1-b" \
  --machine-type "n1-standard-2" \
  --network "default" \
  --metadata-from-file "startup-script=startup.sh" \
  --maintenance-policy "MIGRATE" \
  --scopes default="https://www.googleapis.com/auth/cloud-platform" \
  --tags "http-server","https-server" \
  --image "/ubuntu-os-cloud/ubuntu-1404-trusty-v20160516" \
  --boot-disk-size "1000" \
  --boot-disk-type "pd-ssd" \
  --boot-disk-device-name "jawikipedia"
