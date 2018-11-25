set -ev

BASEDIR=$(dirname "$0")
cd $BASEDIR

# docker-compose -f docker-compose.yml down

docker-compose -f docker-compose.yml up -d

# wait for Hyperledger Fabric to start

# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}


ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Create the channel 
docker exec org7cli peer channel fetch 0 --tls --cafile $ORDERER_CA -o orderer.example.com:7050 -c mychannel
# Join peer0.org7.example.com to the channel.
docker exec org7cli peer channel join -b mychannel_0.block --tls --cafile $ORDERER_CA
# Join peer1.org7.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org7MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org7.example.com/peers/peer0.org7.example.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp" -e "CORE_PEER_ADDRESS=peer1.org7.example.com:7051" org7cli peer channel join -b mychannel_0.block --tls --cafile $ORDERER_CA
# Update peer0.org7.example.com as anchor peer.
docker exec org7cli peer channel update -o orderer.example.com:7050 -c mychannel -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/Org7MSPanchors.tx --tls --cafile $ORDERER_CA


# # Install & Instantiating The ChainCode
# CHAINCODE_NAME="mycc"
# CHAINCODE_SRC="github.com/chaincode"
# CHAINCODE_VERSION="1.0"
# CHANNEL_NAME="mychannel"
# ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# docker exec org7cli peer chaincode install -n $CHAINCODE_NAME -p $CHAINCODE_SRC -v $CHAINCODE_VERSION
# docker exec org7cli peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -c '{"Args":[]}' -n $CHAINCODE_NAME -v $CHAINCODE_VERSION -P "OR('Org1MSP.member', 'Org2MSP.member')"
