# Modified from the repository cmbant/docker-gcc-build
#   @ https://github.com/cmbant/docker-gcc-build

FROM ubuntu:20.04

ARG GCC_BRANCH=releases/gcc-10

ENV DEBIAN_FRONTEND=noninteractive transientBuildDeps="dpkg-dev apt-utils bison flex libmpc-dev"

RUN apt-get update \
  && apt-get install -y $transientBuildDeps \
  build-essential git wget sudo cmake libtool ca-certificates openssh-client gcc g++ \
  libisl-dev liblapack-dev libopenblas-dev openmpi-bin libopenmpi-dev \
  --no-install-recommends --no-install-suggests

RUN git clone --depth=1 --single-branch --branch $GCC_BRANCH git://gcc.gnu.org/git/gcc.git gcc

# Supposed to do 'make install-strip' but that target is temporarily broken in the latest gcc commits
RUN cd gcc \
  && mkdir objdir \
  && cd objdir \
  && ../configure --enable-languages=c,c++ --disable-multilib \
  && make -j"$(nproc)" \
  && make install \
  && make distclean \
  && cd ../.. \
  && rm -rf ./gcc

RUN echo '/usr/local/lib64' > /etc/ld.so.conf.d/local-lib64.conf \
  && ldconfig -v \
  && dpkg-divert --divert /usr/bin/gcc.orig --rename /usr/bin/gcc \
  && dpkg-divert --divert /usr/bin/g++.orig --rename /usr/bin/g++ \
  && update-alternatives --install /usr/bin/cc cc /usr/local/bin/gcc 999 \
  && apt-get purge -y --auto-remove $transientBuildDeps \
  && rm -rf /var/lib/apt/lists/* /var/log/* /tmp/*
