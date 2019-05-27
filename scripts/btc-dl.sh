#!/bin/sh

# Get URL or VERSION

#OPTION: --all --> 
git clone https://github.com/frz-dev/btc-x86-bin
ln -s btc-x86-bin/bin/0.18.0/

# If no URL or no VERSION
# LATEST=bitcoin/bitcoin/tags/latest -- e.g. 0.18.0
# x86bin-url=https://github.com/frz-dev/btc-x86-bin/raw/master/bin/$LATEST
# wget $x86bin-url/bitcoind $x86bin-url/bitcoin-cli