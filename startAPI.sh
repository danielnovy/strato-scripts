#!/bin/bash

cd ~/ethereumH/hserver-eth
screen -S api sudo HOST="$(hostname -I)" APPROOT="" PORT=80 PATH="$PATH" $(which api)
