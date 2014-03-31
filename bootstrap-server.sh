#!/bin/bash

apt-get install -y git puppet

if [ ! -d /etc/puppet-source ] ; then
    git clone https://github.com/ox-it/maps-tiles.git /etc/puppet-source;
fi

if [ -d /etc/puppet ] ; then
    rm -rf /etc/puppet
fi

if [ ! -h /etc/puppet ] ; then
    ln -s /etc/puppet-source/puppet /etc/puppet
fi

( cd /etc/puppet ; puppet apply manifests/init.pp )
