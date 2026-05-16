#!/bin/bash
set -eux

apt-get update -y
apt-get install -y unzip curl snapd

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
cd /tmp
unzip -o awscliv2.zip
./aws/install

snap install kubectl --classic || true

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash