#!/bin/bash

# Script for installing tmux on systems where you don't have root access.
# tmux will be installed in ${PREFIX}/bin.
# It's assumed that wget and a C/C++ compiler are installed.

# exit on error
set -e

PREFIX=$HOME/.Local
TEMP_FOLDER=$HOME/temp

# create our directories
mkdir -p ${PREFIX} ${TEMP_FOLDER}
cd ${TEMP_FOLDER}


function openssl () {
    [[ -e ${PREFIX}/lib64/pkgconfig/openssl.pc ]] && return

    OPENSSL_VERSION=3.1.0
    [[ ! -e openssl-${OPENSSL_VERSION}.tar.gz ]] && wget https://ghproxy.com/https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz
    tar xvzf openssl-${OPENSSL_VERSION}.tar.gz
    cd openssl-${OPENSSL_VERSION}
    ./Configure --prefix=${PREFIX}
    make
    make install
    cd ..
}


function libevent () {
    [[ -e ${PREFIX}/lib/pkgconfig/libevent.pc ]] && return

    openssl

    LIBEVENT_VERSION=2.1.12-stable
    [[ ! -e libevent-${LIBEVENT_VERSION}.tar.gz ]] && wget https://ghproxy.com/https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz
    tar xvzf libevent-${LIBEVENT_VERSION}.tar.gz
    cd libevent-${LIBEVENT_VERSION}
    # Need to install pkg-config: sudo apt install pkg-config
    ./configure PKG_CONFIG_PATH=${PREFIX}/lib64/pkgconfig --prefix=${PREFIX} --disable-shared
    make
    make install
    cd ..
}


function ncurses () {
    if [[ -e ${PREFIX}/include/ncurses ]] && [[ -e ${PREFIX}/include/ncursesw ]]; then
        return
    fi

    NCURSES_VERSION=6.4
    [[ ! -e ncurses.tar.gz ]] && wget -O ncurses.tar.gz https://ghproxy.com/https://github.com/mirror/ncurses/archive/refs/tags/v${NCURSES_VERSION}.tar.gz
    tar xvzf ncurses.tar.gz
    cd ncurses-${NCURSES_VERSION}
    _CONFIGURE_COMMAND='./configure CPPFLAGS="-P" --with-shared --with-termlib --prefix=${PREFIX}'
    # _CONFIGURE_COMMAND="$_CONFIGURE_COMMAND --disable-tic-depends --with-ticlib"
    _CONFIGURE_COMMAND="$_CONFIGURE_COMMAND --with-versioned-syms"
    if [[ ! -e ${PREFIX}/include/ncurses ]]; then
        CONFIGURE_COMMAND="$_CONFIGURE_COMMAND --disable-widec"
        eval "$CONFIGURE_COMMAND"
        make
        make install
        make clean
    fi
    if [[ ! -e ${PREFIX}/include/ncursesw ]]; then
        CONFIGURE_COMMAND="$_CONFIGURE_COMMAND --enable-widec"
        eval "$CONFIGURE_COMMAND"
        make
        make install
    fi
    cd ..
}


function tmux () {
    [[ -e ${PREFIX}/bin/tmux ]] && return

    libevent
    ncurses

    TMUX_VERSION=3.3a
    [[ ! -e tmux-${TMUX_VERSION}.tar.gz ]] && wget https://ghproxy.com/https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
    tar xvzf tmux-${TMUX_VERSION}.tar.gz
    cd tmux-${TMUX_VERSION}
    ./configure CFLAGS="-I${PREFIX}/include -I${PREFIX}/include/ncurses" LDFLAGS="-L${PREFIX}/lib -L${PREFIX}/include/ncurses -L${PREFIX}/include"
    CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/ncurses" LDFLAGS="-static -L${PREFIX}/include -L${PREFIX}/include/ncurses -L${PREFIX}/lib" make
    cp tmux ${PREFIX}/bin
    cd ..
}


function ncdu () {
    echo 'Bug here: ncdu'
    return
    [[ -e ${PREFIX}/bin/ncdu ]] && return

    ncurses

    NCDU_VERSION=1.18.1
    [[ ! -e ncdu-${NCDU_VERSION}.tar.gz ]] && wget https://ghproxy.com/https://github.com/ysl2/ncdu/releases/download/v${NCDU_VERSION}/ncdu-${NCDU_VERSION}.tar.gz
    tar xvzf ncdu-${NCDU_VERSION}.tar.gz
    cd ncdu-${NCDU_VERSION}
    ./configure CFLAGS="-I${PREFIX}/include -I${PREFIX}/include/ncurses" LDFLAGS="-L${PREFIX}/lib -L${PREFIX}/include/ncurses -L${PREFIX}/include" --prefix=${PREFIX}
    CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/ncurses" LDFLAGS="-static -L${PREFIX}/include -L${PREFIX}/include/ncurses -L${PREFIX}/lib" make
    make install
    cd ..
}


function lf () {
    [[ -e ${PREFIX}/bin/lf ]] && return

    LF_VERSION=r28
    [[ ! -e lf-linux-amd64.tar.gz ]] && wget https://ghproxy.com/https://github.com/gokcehan/lf/releases/download/${LF_VERSION}/lf-linux-amd64.tar.gz
    tar xvzf lf-linux-amd64.tar.gz
    mkdir -p ${PREFIX}/bin
    mv lf ${PREFIX}/bin
}


function htop () {
    [[ -e ${PREFIX}/bin/htop ]] && return

    ncurses

    HTOP_VERSION=3.2.2
    [[ ! -e htop-${HTOP_VERSION}.tar.xz ]] && wget https://ghproxy.com/https://github.com/htop-dev/htop/releases/download/${HTOP_VERSION}/htop-${HTOP_VERSION}.tar.xz
    tar xvf htop-${HTOP_VERSION}.tar.xz
    cd htop-${HTOP_VERSION}
    ./configure --prefix=${PREFIX}
    make
    # No need below:
    # ./configure CFLAGS="-I${PREFIX}/include -I${PREFIX}/include/ncurses" LDFLAGS="-L${PREFIX}/lib -L${PREFIX}/include/ncurses -L${PREFIX}/include" --prefix=${PREFIX}
    # CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/ncurses" LDFLAGS="-static -L${PREFIX}/include -L${PREFIX}/include/ncurses -L${PREFIX}/lib" make
    make install
    cd ..
}


function gcc8 () {
    echo 'Bug here: gcc'
    return

    # wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-8/gcc-8_8.4.0-3ubuntu2_amd64.deb
    # wget http://mirrors.edge.kernel.org/ubuntu/pool/universe/g/gcc-8/gcc-8-base_8.4.0-3ubuntu2_amd64.deb
    # wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-8/libgcc-8-dev_8.4.0-3ubuntu2_amd64.deb
    # wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-8/cpp-8_8.4.0-3ubuntu2_amd64.deb
    # wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-8/libmpx2_8.4.0-3ubuntu2_amd64.deb
    # wget http://mirrors.kernel.org/ubuntu/pool/main/i/isl/libisl22_0.22.1-1_amd64.deb

    wget https://mirror.bjtu.edu.cn/ubuntu/pool/universe/g/gcc-8/gcc-8_8.4.0-3ubuntu2_amd64.deb
    wget https://mirror.bjtu.edu.cn/ubuntu/pool/universe/g/gcc-8/gcc-8-base_8.4.0-3ubuntu2_amd64.deb
    wget https://mirror.bjtu.edu.cn/ubuntu/pool/universe/g/gcc-8/libgcc-8-dev_8.4.0-3ubuntu2_amd64.deb
    wget https://mirror.bjtu.edu.cn/ubuntu/pool/universe/g/gcc-8/cpp-8_8.4.0-3ubuntu2_amd64.deb
    wget https://mirror.bjtu.edu.cn/ubuntu/pool/universe/g/gcc-8/libmpx2_8.4.0-3ubuntu2_amd64.deb
    wget https://mirror.bjtu.edu.cn/ubuntu/pool/universe/g/gcc-8/libisl22_0.22.1-1_amd64.deb

    sudo apt update
    sudo apt install ./libisl22_0.22.1-1_amd64.deb ./libmpx2_8.4.0-3ubuntu2_amd64.deb ./cpp-8_8.4.0-3ubuntu2_amd64.deb ./libgcc-8-dev_8.4.0-3ubuntu2_amd64.deb ./gcc-8-base_8.4.0-3ubuntu2_amd64.deb ./gcc-8_8.4.0-3ubuntu2_amd64.deb
}


if [[ -z $1 ]]; then
    echo 'Please select an item to install.'
fi

while [[ ! -z $1 ]]; do
    eval "$1"
    shift
done

# cleanup
# rm -rf ${TEMP_FOLDER}
