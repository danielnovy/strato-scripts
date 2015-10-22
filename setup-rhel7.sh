#!/bin/bash

# Get screen
sudo yum -y install screen

# Get stack
curl -sSL https://s3.amazonaws.com/download.fpcomplete.com/centos/7/fpco.repo | sudo tee /etc/yum.repos.d/fpco.repo
sudo yum -y install stack

# Get git
sudo yum -y install git

# Get mgit
git clone http://github.com/blockapps/mgit
cd mgit
stack setup
stack install

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
## alex and happy
stack install happy alex

## PostgreSQL
sudo yum -y install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-redhat94-9.4-2.noarch.rpm
sudo yum -y install postgresql
sudo yum -y install postgresql-devel
sudo yum -y install postgresql94-server
sudo /usr/pgsql-9.4/bin/postgresql94-setup initdb
sudo systemctl enable postgresql-9.4.service
sudo systemctl start postgresql-9.4.service

## LevelDB
sudo yum -y install ftp://ftp.pbone.net/mirror/download.fedora.redhat.com/pub/fedora/epel/7/x86_64/l/leveldb-1.12.0-5.el7.x86_64.rpm
sudo yum -y install ftp://ftp.pbone.net/mirror/download.fedora.redhat.com/pub/fedora/epel/7/x86_64/l/leveldb-devel-1.12.0-5.el7.x86_64.rpm

## ZLib
sudo yum -y install zlib-devel

# Build
cd ~/ethereumH
stack install

# Set up databases
sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password 'api';"
sudo -u postgres createdb eth 2> /dev/null || echo "database already exists"
cat <<EOF | sudo tee /var/lib/pgsql/9.4/data/pg_hba.conf >/dev/null
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

cd
cp ~/ethereumH/ethereum-conf/ethconf.yaml ~/.ethereumH
nohup ~/ethereumH/ethereum-build/startAPI.sh
nohup ~/ethereumH/ethereum-build/startEVM.sh
