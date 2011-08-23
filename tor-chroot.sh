#!/bin/bash -x
#
# Script to start Tor in a chroot
#
# Originally by:
#  Steven J. Murdoch (http://www.cl.cam.ac.uk/users/sjm217/)
# Modified by:
#  Jacob Appelbaum <jacob@appelbaum.net>
#
# This script goes in /usr/local/bin/tor-chroot or somewhere similar
#
# This file should be in /usr/local/sbin/tor-chroot and then 
# /etc/default/tor-chroot should reference it. The /etc/init.d/tor-chroot file
# should source /etc/default/tor-chroot to override the defaults in the init.d
# script.
# 

DEFAULTSFILE=/etc/default/tor-chroot
# Include tor defaults if available
if [ -f $DEFAULTSFILE ] ; then
        . $DEFAULTSFILE
fi

echo "Trying to chroot into $TORCHROOT..."
/usr/sbin/chroot $TORCHROOT /usr/sbin/tor $*
