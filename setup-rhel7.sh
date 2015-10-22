#!/bin/bash

# Get stack
curl -sSL https://s3.amazonaws.com/download.fpcomplete.com/centos/7/fpco.repo | sudo tee /etc/yum.repos.d/fpco.repo
sudo yum -y install stack

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
## alex and happy
stack install happy alex

## PostgreSQL
sudo yum install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-redhat94-9.4-2.noarch.rpm
# sudo yum -y install postgresql
# sudo yum -y install postgresql-devel
# sudo yum -y install postgresql94-server
sudo systemctl enable postgresql-9.4.service
sudo systemctl start postgresql-9.4.service

## LevelDB
sudo yum install ftp://ftp.pbone.net/mirror/download.fedora.redhat.com/pub/fedora/epel/7/x86_64/l/leveldb-1.12.0-5.el7.x86_64.rpm
sudo yum install ftp://ftp.pbone.net/mirror/download.fedora.redhat.com/pub/fedora/epel/7/x86_64/l/leveldb-devel-1.12.0-5.el7.x86_64.rpm

## ZLib
sudo yum install zlib-devel

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
