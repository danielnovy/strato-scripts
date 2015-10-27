#!/bin/bash

cd ~/ethereumH/hserver-eth
export HOST="$(hostname -I)" APPROOT="" PORT=443
screen -d -m -S api api
