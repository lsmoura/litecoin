FROM alpine:3.10

LABEL maintainer "Sergio Moura <sergio@moura.ca>"

RUN export CORES=`nproc` && export DEVDIR=/tmp/dev && \
apk add --update --no-cache --virtual .build-deps curl git alpine-sdk automake autoconf libtool \
  boost-dev openssl-dev libevent-dev db db-c++ db-dev libzmq zeromq-dev && \
mkdir -p $DEVDIR && cd $DEVDIR && \
git clone --depth=1 https://github.com/litecoin-project/litecoin.git && \
cd litecoin && \
./autogen.sh && \
./configure --prefix=/usr --disable-wallet --without-gui --disable-tests --disable-bench --disable-man \
  --disable-shared --disable-static && \
sed -i '/char\ scratchpad\[SCRYPT_SCRATCHPAD_SIZE\];/a\memset(scratchpad, 0, sizeof(scratchpad));' src/crypto/scrypt.cpp && \
sed -i 's/char\ scratchpad\[SCRYPT_SCRATCHPAD_SIZE\];/static &/g' src/crypto/scrypt.cpp && \
make -j`nproc` && \
make install && \
ldd /usr/bin/litecoind /usr/bin/litecoin-cli /usr/bin/litecoin-tx /usr/bin/test_litecoin /usr/bin/bench_litecoin | sed -e 's/[ \t]*//g' -e 's/.*=>//g' -e 's/(.*//g' > $DEVDIR/libs.list && \
apk info --who-owns `cat $DEVDIR/libs.list` | sed -e 's/.*owned by //g' -e 's/-[0-9].*$//g' > $DEVDIR/pkg.list && \
apk add --virtual .litecoin-deps `cat $DEVDIR/pkg.list` && apk del .build-deps  && \
cd / && \
rm -Rf $DEVDIR && \
mkdir -p /etc/litecoin

COPY litecoin.conf /etc/litecoin/

WORKDIR /litecoin

EXPOSE 9333 9332 29000

CMD ["litecoind", "-datadir=/litecoin", "-conf=/etc/litecoin/litecoin.conf", "-printtoconsole"]
