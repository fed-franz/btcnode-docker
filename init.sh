#!/bin/bash

# Local Variables
datadir=$HOME/.bitcoin

# Check Bitcoin Network Option and setup paths and aliases
logdir=$datadir
for i in "$@"
do
   case "$i" in
   "-h")
      print_help=true
      ;;
   "-testnet")
      obtcnet="-testnet"
      logdir=$datadir/testnet3
      ;;
   "-regtest")
      obtcnet="-regtest"
      logdir=$datadir/regtest
      ;;
   *) btcdopts+="$i "
   esac
done
btcdopts="$obtcnet $btcdopts"

# Local variables
btcstart="bitcoind $btcdopts"
btcd="bitcoind $obtcnet"
btccli="bitcoin-cli $obtcnet"

# Set bash commands
cd $sys_bin_dir
echo "$btcd" > btcd
echo "$btccli" > btccli
echo "$btccli getblockcount" > getblockcount
echo "$btccli getpeerinfo" > getpeers
echo "getpeers | grep --color=never -E '\\\"addr\\\": \\\"|inbound'" > getpeersaddr
echo "$btcstart" > btcstart
echo "$btccli stop" > btcstop
echo "cat $logdir/debug.log" > getlog
chmod +x ./*
cd -

# Set container functions
echo \
"
function start_btc () {
   echo $btcstart
   $btcstart
}

function stop_btc () {
   echo $btccli stop
   $btccli stop
}

function check_btc () {
   echo $btccli getblockcount &> /dev/null
   $btccli getblockcount &> /dev/null
}
"\
> ~/.bash_aliases

# Print aliases to screen
if [ "$print_help" = true ]; then
   echo "
   bashrc:"
   cat ~/.bashrc
   echo "
   bash_aliases:"
   cat ~/.bash_aliases
fi

# Load aliases
source ~/.bashrc
source ~/.bash_aliases

# Start Bitcoin Core
start_btc
