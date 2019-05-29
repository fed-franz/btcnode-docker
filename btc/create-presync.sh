#!/bin/bash

### Set Environment ###
if [ -z "$1" ]; then
  echo "Usage: $0 BTC_VERSION BTC_OPTIONS"
  exit 1
fi

BTC_VER=$1
BTC_OPT="${@:2}"
BTCNODE=fedfranz/btcnode:$BTC_VER
CNT_NAME=btcnode

### Run container ###
[ "$(docker ps -a | grep $CNT_NAME)" ] && echo "Container name already exists. Exiting" && exit 1
docker run -d --name $CNT_NAME $BTCNODE $BTC_OPT
if [ $? -ne 0 ]; then
    echo "Docker run failed. Exiting"; exit 1
fi

### Monitor Blockchain Sync ###
# Wait for Bitcoin Core to start
sleep 10
echo "Monitoring Initial Block Download"
TOT=$(docker exec $CNT_NAME bash -c getlog | grep 'outbound peer' | tail -n 1 | grep -Po 'blocks=\K\S*' | tr -dc '0-9')
CUR=$(docker exec $CNT_NAME bash -c getblockcount | tr -dc '0-9')

while [ "$CUR" -lt "$TOT" ]; do
echo "Blocks: $CUR/$TOT"
T=$(( ( $TOT - $CUR ) / 1000 ))
echo "Sleeping $T seconds"
sleep $T
CUR=$(docker exec $CNT_NAME bash -c getblockcount | tr -dc '0-9')
done

### Stop Bitcoin ###
docker exec $CNT_NAME sync && free -m
docker exec $CNT_NAME bash -c btcstop
while [ $(docker inspect -f '{{.State.Running}}' $CNT_NAME) = true ]; do sleep 1; done

### Commit and push image ###
#Set btc-network name
for i in "$@"
do
   case "$i" in
   "-testnet")
      btcnet="testnet"
      ;;
   "-regtest")
      btcnet="regtest"
      ;;
   *) btcnet="mainnet"
   esac
done
IMAGE_NAME="$BTCNODE-$btcnet-sync"
echo "Committing $CNT_NAME as $IMAGE_NAME"
docker commit $CNT_NAME $IMAGE_NAME
docker push $IMAGE_NAME

#Remove container
docker rm $CNT_NAME

echo "Done"
exit 0
