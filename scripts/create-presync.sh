#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 BTC_VERSION. Exiting"
  exit 1
fi

BTC_VER=$1
BTCNODE=fedfranz/btcnode:$BTC_VER
CNT_NAME=btcnode
BTC_NET=-testnet

# If $CNT_NAME already exists, exits
[ "$(docker ps -a | grep $CNT_NAME)" ] && echo "Container name already exists. Exiting" && exit 1
docker run -d --name $CNT_NAME $BTCNODE
if [ $? -ne 0 ]; then
    echo "command1 borked it"
fi
echo ok
exit 0
# Wait for Bitcoin Core to start
sleep 10

TOT=$(docker exec -it $CNT_NAME bitcoin-cli $BTC_NET getblockchaininfo | grep headers | tr -dc '0-9')
CUR=$(docker exec -it $CNT_NAME bitcoin-cli $BTC_NET getblockcount | tr -dc '0-9')

while [ "$CUR" -lt "$TOT" ]; do
echo "Blocks: $CUR/$TOT"
T=$(( ( $TOT + $CUR ) / 10000 ))
echo "Sleeping $T seconds"
sleep $T
CUR=$(docker exec -it $CNT_NAME bitcoin-cli $BTC_NET getblockcount | tr -dc '0-9')
done

docker exec -it $CNT_NAME sync && free -m
docker exec -it $CNT_NAME bitcoin-cli $BTC_NET stop
while [ $(docker inspect -f '{{.State.Running}}' $CNT_NAME) ]; do sleep 1; done
echo "Committing $CNT_NAME as $BTCNODE:sync"
docker commit $CNT_NAME $BTCNODE-sync
docker push $BTCNODE-sync
docker rm $CNT_NAME
echo "Done"