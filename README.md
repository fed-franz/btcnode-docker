# btcnode
Bitcoin Core node container

## Usage
```
docker build -t "btcnode" [--build-arg btc_ver=BITCOIN_CORE_VERSION] .
docker run btcnode --name btcnode BITCOIND_OPTIONS
```
`BITCOIN_CORE_VERSION={...,0.17.0,0.18.0}` -- All values from `frz-dev/btc-x86-bin/bin`  
default = 'latest'

## How it works
### Build
1. The Dockerfile copies 'btc' and 'scripts' directories into the container
2. If 'btc' contains `bitcoind` and `bitcoin-cli`, it build the image with those binaries
3. If no binaries are provided, it automatically downloads precompiled binaries from `https://github.com/frz-dev/btc-x86-bin/bin`.  
You can specify the Bitcoin Core version using the `btc_ver` argument. If no version is specified, the latest available will be used.

The `scripts` folder will be also copied.  
`init.sh` will be used as initial script; from there it is possible to call any other script included in the `scripts` folder.

You can load a customized `bitcoin.conf` file by copying it to `btc`

### Run 
When the container starts, `init.sh` will be called, which in turn will start `bitcoind`
All the parameters passed at the end of the `docker run` command will be used as `bitcoind` options.
  
### Example
docker run --name btcnode btcnode -testnet -prune=550

## Pre-Synced Node
To save the image of a btcnode without losing data, you can commit the container:
```
# Stop Bitcoin Core
docker exec -it btcnode bitcoin-cli -testnet stop
# Commit state to new image
docker commit btcnode btcnode-synced
```

### Script
The `create-presync` script allows to create a presynced images from scratch.  
It starts a new btcnode image, waits for it to synchronize the blockchain and then commits the image adding a -sync suffix to the image name.

Usage:  
`create-presync.sh BTCNODE_VERSION BTCOPTIONS`  
For Example:  
`create-presync.sh 0.17.0 -testnet -prune=550`  

### Available pre-synced images
Pre-synced images can be found in Docker `fedfranz/btcnode` repository, tagged like follows:  
`fedfranz/btcnode:0.18.0-testnet-sync`
