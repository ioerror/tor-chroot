#!/bin/bash -x
#
# This assumes that you already have a copy of Tor installed
# It is based on:
# https://trac.torproject.org/projects/tor/wiki/doc/TorInChroot
#
TORCHROOT=/home/tor-chroot

# Prep the chroot
mkdir -p $TORCHROOT
mkdir -p $TORCHROOT/{etc/tor/,dev,lib,var/run/tor/,var/lib/tor/,var/log/tor/}/
chown debian-tor:debian-tor $TORCHROOT{/var/lib/tor,/var/run/tor,/var/log/tor}
chmod 750 $TORCHROOT{/var/lib/tor,/var/run/tor,/var/log/tor}
ls -al $TORCHROOT{/var/lib/tor,/var/run/tor,/var/log/tor}

# Copy over the libs for Tor
# Discover this with "ldd `which tor`"
mkdir -p $TORCHROOT{/lib,/usr/lib/,/lib64/}
cp /usr/lib/libz.so.1 $TORCHROOT/usr/lib/libz.so.1
cp /lib/libm.so.6 $TORCHROOT/lib/libm.so.6
cp /usr/lib/libevent-1.4.so.2 $TORCHROOT/usr/lib/libevent-1.4.so.2
cp /usr/lib/libssl.so.0.9.8 $TORCHROOT/usr/lib/libssl.so.0.9.8
cp /usr/lib/libcrypto.so.0.9.8 $TORCHROOT/usr/lib/libcrypto.so.0.9.8
cp /lib/libpthread.so.0 $TORCHROOT/lib/libpthread.so.0
cp /lib/libdl.so.2 $TORCHROOT/lib/libdl.so.2
cp /lib/libc.so.6 $TORCHROOT/lib/libc.so.6
cp /lib/libnsl.so.1 $TORCHROOT/lib/libnsl.so.1
cp /lib/librt.so.1 $TORCHROOT/lib/librt.so.1
cp /lib/libresolv.so.2 $TORCHROOT/lib/libresolv.so.2
cp /lib64/ld-linux-x86-64.so.2 $TORCHROOT/lib64/ld-linux-x86-64.so.2

# More generic libs
cp /lib/libnss* /lib/libnsl* /lib/ld-linux.so.2 /lib/libresolv* \
   $TORCHROOT/lib

# Copy over Tor
mkdir -p $TORCHROOT/usr/sbin
cp /usr/sbin/tor  $TORCHROOT/usr/sbin/tor

# Copy over geoip
mkdir -p $TORCHROOT/usr/share/tor/
cp /usr/share/tor/geoip $TORCHROOT/usr/share/tor/geoip

# copy over the tor-exit-notice.html
cp /etc/tor/tor-exit-notice.html $TORCHROOT/etc/tor/tor-exit-notice.html

# Copy over the Tor chroot wrapper script
cat << 'EOF' > $TORCHROOT/usr/sbin/tor-chroot.sh
#!/bin/bash -x
#
# Installed by tor-chroot-update.sh 
#
DEFAULTSFILE=/etc/default/tor-chroot
# Include tor defaults if available
if [ -f $DEFAULTSFILE ] ; then
        . $DEFAULTSFILE
fi

echo "Trying to chroot into $TORCHROOT..."
/usr/sbin/chroot $TORCHROOT /usr/sbin/tor $*
EOF
chmod +x $TORCHROOT/usr/sbin/tor-chroot.sh

# copy over the device nodes
mkdir -p $TORCHROOT/dev/
mknod -m 644 $TORCHROOT/dev/random c 1 8
mknod -m 644 $TORCHROOT/dev/urandom c 1 9
mknod -m 666 $TORCHROOT/dev/null c 1 3

# copy over the passwd/group and other system configs
echo "debian-tor:x:106:107::/var/lib/tor:/bin/false" > $TORCHROOT/etc/passwd
echo "debian-tor:x:107:" > $TORCHROOT/etc/group

cp /etc/nsswitch.conf /etc/host.conf /etc/resolv.conf /etc/hosts $TORCHROOT/etc/
cp /etc/localtime $TORCHROOT/etc

# If we get here, we hope to have a proper chroot 
echo "Chroot is configured; start the /etc/init.d/tor-chroot init.d script"
