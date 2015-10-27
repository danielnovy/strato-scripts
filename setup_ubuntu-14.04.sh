function get_dependencies () {
    # Get stack
    wget -q -O- https://s3.amazonaws.com/download.fpcomplete.com/ubuntu/fpco.key \
	| sudo apt-key add - &&
    echo 'deb http://download.fpcomplete.com/ubuntu/trusty stable main' \
	| sudo tee /etc/apt/sources.list.d/fpco.list &&
    sudo apt-get update &&
    sudo apt-get install stack -y &&

    # Get necessary packages
    stack install happy alex &&
    sudo apt-get -y install libpq-dev postgresql postgresql-client libleveldb-dev
}

db_conf_dir="/etc/postgresql/9.3/main"
