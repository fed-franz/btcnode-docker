# Bitcoin Node
FROM fedfranz/debian-base:net

# ENV
ARG btc_ver

ENV btc=btc
ENV btcdir=/root/.bitcoin
ENV sys_bin_dir=/usr/local/bin
ENV btc_url_base="https://raw.githubusercontent.com/frz-dev/btc-x86-bin/master/bin"

# Copy Bitcoin files
COPY ${btc} ${btc}
RUN chmod a+x ${btc}/*.sh

RUN if [ ! -f "$btc/bitcoind" ] ; then \
        if [ -z "$btc_ver" ] ; then \
            btc_ver=$(curl "$btc_url_base/latest"); \
        fi ; \
        btc_url="$btc_url_base/$btc_ver"; \
        wget -P $btc "$btc_url/bitcoind" "$btc_url/bitcoin-cli"; \
    fi

RUN mv $btc/bitcoind $btc/bitcoin-cli $sys_bin_dir/
RUN chmod a+x $sys_bin_dir/bitcoind $sys_bin_dir/bitcoin-cli
RUN mkdir $btcdir
RUN if [ -f "$btc/bitcoin.conf" ] ; then \
       mv $btc/bitcoin.conf $btcdir; \
    fi

COPY init.sh ./
RUN chmod a+x init.sh

# Expose Bitcoin ports
EXPOSE 8333 8332 18333 18332 18443 18444

# Run 'init' script
ENTRYPOINT ["./init.sh"]
CMD [""]
