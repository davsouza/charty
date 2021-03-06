#!/bin/bash

set -x
set -e

# Occasionally another process is using APT, and apt-get errors out with:
#     E: Could not get lock /var/lib/apt/lists/lock - open (11: Resource temporarily unavailable)
#     E: Unable to lock directory /var/lib/apt/lists/
# So we retry apt-get commands indefinitely.
retry(){
    succeeded=0
    while [[ succeeded -eq 0 ]]; do
        set +e
        $*
        if [[ $? -eq 0 ]]; then
            succeeded=1
        else
            succeeded=0
            sleep 5
        fi
        set -e
    done
}

retry sudo apt-get -y update
retry sudo apt-get install -y curl python3-pip python3-flask
curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -
retry sudo apt-get install -y nodejs
sudo npm install -g yarn
pip3 install -r requirements.txt
cd static
yarn install
sudo cp ../system/flask.service /etc/systemd/system
sudo systemctl start flask