#!/bin/bash

cd
screen -S ethereum-vm ethereum-vm --sqlDiff --createTransactionResults --wrapTransactions
