#!/bin/bash

# Exit on first error, print all commands.
source .env
set -ev
CHAINCODE_NAME="mycc"
CHAINCODE_SRC="github.com/chaincode"
CHAINCODE_VERSION="21.0"
CHANNEL_NAME=mychannel
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
ORDERER_ENDPOINT=orderer.example.com:7050
# Install chaincode in Org1
docker exec cli peer chaincode install -n $CHAINCODE_NAME -p $CHAINCODE_SRC -v $CHAINCODE_VERSION

# # Install chaincode in Org2 
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" -e "CORE_PEER_ADDRESS=peer0.org2.example.com:7051" cli peer chaincode install -n $CHAINCODE_NAME -p $CHAINCODE_SRC -v $CHAINCODE_VERSION

# # Install chaincode in Org3
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp" -e "CORE_PEER_ADDRESS=peer0.org3.example.com:7051" cli peer chaincode install -n $CHAINCODE_NAME -p $CHAINCODE_SRC -v $CHAINCODE_VERSION

# Instantiate chaincode in Org3 Channel
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp" -e "CORE_PEER_ADDRESS=peer0.org3.example.com:7051" cli peer chaincode upgrade -o $ORDERER_ENDPOINT --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -c '{"Args":["init"]}' -n $CHAINCODE_NAME -v $CHAINCODE_VERSION -P "OR ('Org1MSP.member', 'Org2MSP.member')"