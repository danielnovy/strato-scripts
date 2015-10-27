#!/bin/bash

cd
screen -d -m -S ethereum-vm ethereum-vm --sqlDiff --createTransactionResults --wrapTransactions
