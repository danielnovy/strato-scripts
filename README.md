#ethereum-build

[![BlockApps logo](http://blockapps.net/img/logo_cropped.png)](http://blockapps.net)

Running autobuild will build ethereumH in this directory and should work
seamlessly on Ubuntu. Debian is also reported to work.

Autobuild sets up the development environment, then calls setup (which sets up
postgres) and finally build (which itself calls cabal-install).

In the future, use "repo sync" to update ethereumH. Beware of making changes
in detached head state.

Running autobuild from a brand new machine may take a while.
