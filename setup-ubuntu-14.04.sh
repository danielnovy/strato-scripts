#!/bin/bash

# Get stack
wget -q -O- https://s3.amazonaws.com/download.fpcomplete.com/ubuntu/fpco.key | sudo apt-key add -
echo 'deb http://download.fpcomplete.com/ubuntu/trusty stable main'|sudo tee /etc/apt/sources.list.d/fpco.list
sudo apt-get update && sudo apt-get install stack -y

# Get mgit
git clone http://github.com/blockapps/mgit
cd mgit
stack setup
stack install

# Fix PATH
for x in ~/.local/bin; do
  case ":$PATH:" in
    *":$x:"*) :;; # already there
    *) echo "PATH=\"$x:$PATH\"" >> ~/.profile;;
  esac
done
. ~/.profile

# Get ethereumH
cd
mgit clone http://github.com/blockapps/ethereumH -b develop
cd ethereumH/ethereum-vm
git merge origin/deployment-patches

# Get API certificates
cp ~/{priv,{certificate,key}.pem} ~/ethereumH/hserver-eth

# Get solc
cd
tar xvf solc.tar.gz 
sed -i "s@$$HOME@$HOME@g" ~/.local/bin/solc

# Get necessary packages
stack install happy alex
sudo apt-get -y install libpq-dev postgresql postgresql-client libleveldb-dev

# Build
cd ~/ethereumH
stack install

# Set up databases
sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password 'api';"
sudo -u postgres createdb eth 2> /dev/null || echo "database already exists"
cat <<EOF | sudo tee /etc/postgresql/9.3/main/pg_hba.conf >/dev/null
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     ident
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
EOF

cd ~/ethereumH/ethereum-data-sql
mv genesis.json genesis-real.json5H
ln -s stablenetGenesis.json genesis.json
ethereum-setup

cd
cp ~/ethereumH/ethereum-conf/ethconf.yaml ~/.ethereumH/
cp ~/ethereumH/ethereum-build/start{API,EVM}.sh ~/.local/bin/
sudo setcap 'cap_net_bind_service=+ep' ~/.local/bin/api

sudo apt-get -y install nginx
cat <<EOF | sudo tee /etc/nginx/sites-available/https_redirect >/dev/null
server {
    server_name *.blockapps.net;
    return 301 https://$host$request_uri;5F5F
}
EOF
sudo ln -s ../https_redirect /etc/nginx/sites-enabled
sudo rm -r /etc/nginx/sites-enabled/default
