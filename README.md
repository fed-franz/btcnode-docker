# btcnode
Bitcoin Core node container

## Usage
```
docker build -t "btcnode" .  
docker run btcnode --name btcnode BITCOIND_OPTIONS
```
  
### Example
docker run btcnode --name btcnode -testnet -prune=550