#!/bin/bash

# Exit on first error, print all commands.
set -ev
source ${PWD}/scripts/.env

docker exec cli peer chaincode invoke -o orderer.example.com:7050  --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["initLedger"]}'

