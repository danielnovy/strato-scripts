function get_mgit() {
    cd
    if [[ -d mgit ]]; then
	info "mgit already installed"
	return 0
    fi

    info "Installing mgit..."
    git clone http://github.com/blockapps/mgit &&
    cd mgit &&
    stack setup &&
    stack install
}

function set_localbinpath () {
    localbinpath=~/.local/bin
    profilefile=~/.profile
    setpath="PATH=\"$localbinpath:$PATH\""

    case ":$PATH:" in
	*":$localbinpath:"*) 
	    info "$localbinpath already in PATH"
	    ;;
	*)
	    info "Adding $localbinpath to PATH..."
	    echo $setpath >> $profilefile
	    eval $setpath
	    ;;
    esac
}

function get_ethereumH () {
    cd
    if [[ ! -d ethereumH ]]
    then
	info "Unpacking ethereumH..."
	mgit clone http://github.com/blockapps/ethereumH -b develop
    else
	info "ethereumH/ is already present"
    fi &&
    cd ethereumH/ethereum-vm &&
    git merge origin/deployment-patches
}

function build_ethereumH () {
    cd ~/ethereumH
    info "Installing ethereumH..."
    stack install
}

function install_auth () {
    cd
    info "Installing private keys and certificates..."
    hserver_dir=ethereumH/hserver-eth
    [[ -f priv ]] && cp priv $hserver_dir
    [[ -f certificate.pem && -f key.pem ]] && cp {certificate,key}.pem $hserver_dir
}

function install_solc() {
    cd
    if [[ -f solc.tar.gz ]]
    then
	info "Installing solc..."
	tar xvf solc.tar.gz &&
	cat <<EOF >~/.local/bin/solc &&
#!/bin/bash
SOLC_PATH=$HOME/solc
LD_LIBRARY_PATH="$SOLC_PATH:$LD_LIBRARY_PATH" $SOLC_PATH/ld.so $SOLC_PATH/solc $@
EOF
	chmod 755 ~/.local/bin/solc
    else
	info "$HOME/solc.tar.gz is missing; skipping solc install"
    fi
}

function setup_dbs() {
    info "Setting up postgresql..."
    sudo -u postgres psql -U postgres -d postgres \
	-c "alter role postgres password '5Fapi'" &&
    info "  user: postgres" &&
    info "  password: api" &&
    (sudo -u postgres createdb eth 2> /dev/null &&
	info "  database: eth" ||
	info "  database 'eth' already exists") &&
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
    info "  configuring database 'eth', installing genesis block" &&
    ethereum-setup
}

function setup_nginx () {
    info "Setting up http->https redirect..."
    cat <<EOF | sudo tee /etc/nginx/sites-available/https_redirect >/dev/null &&
server {
    server_name *.blockapps.net;
    return 301 https://$host$request_uri;5F5F
}
EOF
    sudo ln -s ../https_redirect /etc/nginx/sites-enabled &&
    sudo rm -r /etc/nginx/sites-enabled/default
}

build_log=~/ethereum-build.log

function setup_info () {
    exec 3>&1 1>$build_log 2>&1
}

function info () {
    echo 1>&3 $@
}
