#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -e

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

docker network create commercialpaper-net

docker-compose -f docker-compose.yaml up -d 

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
# Check MagnetoCorp Peer
export FABRIC_START_TIMEOUT=30
for i in $(seq 1 ${FABRIC_START_TIMEOUT})
do
    # This command only works if the peer is up and running
    if docker exec peer1.magnetocorp.example.com peer channel list > /dev/null 2>&1
    then
        # Peer now available
        break
    else
        # Sleep and try again
        sleep 1
    fi
done
echo Hyperledger Fabric MagnertoCorp Peer checked in $i seconds

# Check Digibank Peer
export FABRIC_START_TIMEOUT=30
for i in $(seq 1 ${FABRIC_START_TIMEOUT})
do
    # This command only works if the peer is up and running
    if docker exec peer5.digibank.example.com peer channel list > /dev/null 2>&1
    then
        # Peer now available
        break
    else
        # Sleep and try again
        sleep 1
    fi
done
echo Hyperledger Fabric DigiBank peer checked in $i seconds


# Check Hedgematic Peer
export FABRIC_START_TIMEOUT=30
for i in $(seq 1 ${FABRIC_START_TIMEOUT})
do
    # This command only works if the peer is up and running
    if docker exec peer3.hedgematic.example.com peer channel list > /dev/null 2>&1
    then
        # Peer now available
        break
    else
        # Sleep and try again
        sleep 1
    fi
done
echo Hyperledger Fabric HedgeMatic peer checked in $i seconds


# Check to see if the channel already exists
if ! docker exec peer1.magnetocorp.example.com peer channel getinfo -c papernet
then
    # Create the channel
    docker exec -e "CORE_PEER_ADDRESS=peer1.magnetocorp.example.com:7051" -e "CORE_PEER_LOCALMSPID=magnetocorpMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/magnetocorp.example.com/users/Admin@magnetocorp.example.com/msp" cli peer channel create -o orderer1.magnetocorp.example.com:7050 -c papernet -f ./channel-artifacts/channel.tx
    # Join MagnetoCorp Peer to the channel.
    docker exec -e "CORE_PEER_ADDRESS=peer1.magnetocorp.example.com:7051" -e "CORE_PEER_LOCALMSPID=magnetocorpMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/magnetocorp.example.com/users/Admin@magnetocorp.example.com/msp" cli peer channel join -b papernet.block
    # Join DigiBank Peer to the channel.
    docker exec -e "CORE_PEER_ADDRESS=peer5.digibank.example.com:7051" -e "CORE_PEER_LOCALMSPID=digibankMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/digibank.example.com/users/Admin@digibank.example.com/msp" cli peer channel join -b papernet.block
    # Join HedgeMatic Peer to the channel.
    docker exec -e "CORE_PEER_ADDRESS=peer3.hedgematic.example.com:7051" -e "CORE_PEER_LOCALMSPID=hedgematicMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hedgematic.example.com/users/Admin@hedgematic.example.com/msp" cli peer channel join -b papernet.block
    # Update channel with MagnetoCorp information.
    docker exec -e "CORE_PEER_ADDRESS=peer1.magnetocorp.example.com:7051" -e "CORE_PEER_LOCALMSPID=magnetocorpMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/magnetocorp.example.com/users/Admin@magnetocorp.example.com/msp" cli peer channel update -o orderer1.magnetocorp.example.com:7050 -c papernet -f ./channel-artifacts/magnetocorpMSPanchors.tx 
    # Update channel with Digibank information
    docker exec -e "CORE_PEER_ADDRESS=peer5.digibank.example.com:7051" -e "CORE_PEER_LOCALMSPID=digibankMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/digibank.example.com/users/Admin@digibank.example.com/msp" cli peer channel update -o orderer1.magnetocorp.example.com:7050 -c papernet -f ./channel-artifacts/digibankMSPanchors.tx 
    # Update channel with HedgeMatic information
    docker exec -e "CORE_PEER_ADDRESS=peer3.hedgematic.example.com:7051" -e "CORE_PEER_LOCALMSPID=hedgematicMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hedgematic.example.com/users/Admin@hedgematic.example.com/msp" cli peer channel update -o orderer1.magnetocorp.example.com:7050 -c papernet -f ./channel-artifacts/hedgematicMSPanchors.tx 
fi
