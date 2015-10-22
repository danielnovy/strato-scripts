#!/bin/bash

# Get stack
wget -q -O- https://s3.amazonaws.com/download.fpcomplete.com/ubuntu/fpco.key | sudo apt-key add -
echo 'deb http://download.fpcomplete.com/ubuntu/trusty stable main'|sudo tee /etc/apt/sources.list.d/fpco.list
sudo apt-get update && sudo apt-get install stack -y

# Get mgit
git clone git@github.com:blockapps/mgit
cd mgit
stack setup
stack install

# Get ethereumH
cd
mgit clone git@github.com:blockapps/ethereumH -b develop
cd ethereumH/ethereum-vm
git rebase develop deployment-patches

# Get API certificates
echo "Enter azure password to get certificates"
scp 'ryanr@azure.blockapps.net:~/ethereumH/hserver-eth/{priv,{certificate,key}.pem}' .

# Get solc
cd
echo "Enter azure password to get solc"
scp ryanr@azure.blockapps.net:~/solc.tar.gz .
tar xvf solc.tar.gz 
sed -i "s@$$HOME@$HOME@g" ~/.local/bin/solc

# Get necessary packages
stack install happy alex

apt-get -y install libpq-dev postgresql postgresql-client libleveldb-dev libboost-filesystem1.54.0 libboost-program-options1.54.0 libjsoncpp0 libboost-system1.55.0 libboost-thread1.55.0 libboost-filesystem1.55.0

# Build
cd ~/ethereumH
stack install

# Set up databases
sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password 'api';"
sudo -u postgres createdb eth 2> /dev/null || echo "database already exists"
sudo cat >/var/lib/pgsql/9.4/data/pg_hba.conf <<EOF
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     ident
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
EOF

cd ~/ethereumH/ethereum-data-sql
mv genesis.json genesis-real.json
ln -s stablenetGenesis.json genesis.json
ethereum-setup
