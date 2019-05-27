# btcnode
Bitcoin Core node container

## Usage
```
docker build -t "btcnode" .  [--build-arg btc_ver=BITCOIN_CORE_VERSION]
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