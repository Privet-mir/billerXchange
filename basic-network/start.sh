#!/bin/bash
#
# Exit on first error, print all commands.
set -ev

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

docker-compose -f docker-compose.yml down

docker-compose -f docker-compose.yml up -d ca.billerxchange.com orderer.billerxchange.com peer0.sales.billerxchange.com couchdb

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=BillerXchange" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@sales.billerxchange.com/msp" peer0.sales.billerxchange.com peer channel create -o orderer.billerxchange.com:7050 -c settlement -f /etc/hyperledger/configtx/channel.tx
# Join peer0.sales.billerxchange.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=BillerXchange" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@sales.billerxchange.com/msp" peer0.sales.billerxchange.com peer channel join -b settlement.block
