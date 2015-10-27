function get_mgit() {
    cd
    if [[ -d mgit ]]; then return; fi

    git clone http://github.com/blockapps/mgit &&
    cd mgit &&
    stack setup &&
    stack install
}

function set_localbinpath () {
    localbinpath="~/.local/bin"
    profilefile="~/.profile"

    case ":$PATH:" in
	*":$localbinpath:"*) :;;
	*)
	    setpath="PATH=\"$localbinpath:$PATH\""
	    echo $setpath >> $profilefile
	    eval $setpath
	    ;;
    esac
}

function get_ethereumH () {
    cd
    if [[ ! -d ethereumH ]]; then
	mgit clone http://github.com/blockapps/ethereumH -b develop
    fi &&
    cd ethereumH/ethereum-vm &&
    git merge origin/deployment-patches
}

function build_ethereumH () {
    cd ~/ethereumH $$
    stack install
}

function install_auth () {
    cp ~/{priv,{certificate,key}.pem} ~/ethereumH/hserver-eth
}

function install_solc() {
    cd &&
    tar xvf solc.tar.gz &&
    cat <<EOF
#!/bin/bash
SOLC_PATH=$HOME/solc
LD_LIBRARY_PATH="$SOLC_PATH:$LD_LIBRARY_PATH" $SOLC_PATH/ld.so $SOLC_PATH/solc $@
EOF
}

function setup_dbs() {
    sudo -u postgres psql -U postgres -d postgres \
	-c "alter user postgres with password 'api';" &&
    sudo -u postgres createdb eth 2> /dev/null \
	|| echo "database already exists" &&
    cat <<EOF | sudo tee $db_conf_dir/pg_hba.conf >/dev/null &&
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     ident
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
EOF
    cd ~/ethereumH/ethereum-data-sql &&
    mv genesis.json genesis-real.json &&
    ln -s stablenetGenesis.json genesis.json &&
    ethereum-setup
}

function setup_nginx () {
    cat <<EOF | sudo tee /etc/nginx/sites-available/https_redirect >/dev/null &&
server {
    server_name *.blockapps.net;
    return 301 https://$host$request_uri;5F5F
}
EOF
    sudo ln -s ../https_redirect /etc/nginx/sites-enabled &&
    sudo rm -r /etc/nginx/sites-enabled/default
}
