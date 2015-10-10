#ethereum-build

[![BlockApps logo](http://blockapps.net/img/logo_cropped.png)](http://blockapps.net)

## Building and installing

Run `npm install js-yaml`, necessary for the yaml-reader script to work.

Run `make [-b <branch>] [pull]` to fetch the repos from the blockapps
org on github, optionally from the specified branch (i.e. "develop").
You can pull just one repo with `make <repo-name>-pull`, i.e. `make
hserver-eth-pull`.

Run `make install` to build and install everything.

## Modifying

Once `make pull` is run, you can work in any of the repo
subdirectories.  Commit changes to all repos with `make push`.  You
can commit individual repos with `make <repo-name>-push`, i.e. `make
hserver-eth-push`.