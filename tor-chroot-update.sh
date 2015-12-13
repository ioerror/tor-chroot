#!/bin/bash -x
#
# This assumes that you already have a copy of Tor installed
# It is based on:
# https://trac.torproject.org/projects/tor/wiki/doc/TorInChroot
#
TORCHROOT=/home/tor-chroot

# Prep the chroot
mkdir -p $TORCHROOT
mkdir -p $TORCHROOT/{root,etc/tor/,dev,lib,var/run/tor/,var/lib/tor/,var/log/tor/}/
chown debian-tor:debian-tor $TORCHROOT{/root,/var/lib/tor,/var/run/tor,/var/log/tor}
chmod 750 $TORCHROOT{/var/lib/tor,/var/run/tor,/var/log/tor}
ls -al $TORCHROOT{/var/lib/tor,/var/run/tor,/var/log/tor}

# Copy over the libs for Tor
# Discover this with "ldd `which tor`"
mkdir -p $TORCHROOT{/lib,/usr/lib/,/lib64/}
cp /lib/x86_64-linux-gnu/libz.so.1 $TORCHROOT/usr/lib/libz.so.1
cp /lib/x86_64-linux-gnu/libm.so.6 $TORCHROOT/lib/libm.so.6
cp /usr/lib/x86_64-linux-gnu/libevent-2.0.so.5 $TORCHROOT/usr/lib/libevent-2.0.so.5
cp /usr/lib/x86_64-linux-gnu/libssl.so.1.0.0 $TORCHROOT/usr/lib/libssl.so.1.0.0
cp /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.0 $TORCHROOT/usr/lib/libcrypto.so.1.0.0
cp /lib/x86_64-linux-gnu/libpthread.so.0 $TORCHROOT/lib/libpthread.so.0
cp /lib/x86_64-linux-gnu/libdl.so.2 $TORCHROOT/lib/libdl.so.2
cp /lib/x86_64-linux-gnu/libc.so.6 $TORCHROOT/lib/libc.so.6
cp /lib/x86_64-linux-gnu/libnsl.so.1 $TORCHROOT/lib/libnsl.so.1
cp /lib/x86_64-linux-gnu/librt.so.1 $TORCHROOT/lib/librt.so.1
cp /lib/x86_64-linux-gnu/libresolv.so.2 $TORCHROOT/lib/libresolv.so.2
cp /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 $TORCHROOT/lib64/ld-linux-x86-64.so.2
cp /usr/lib/x86_64-linux-gnu/libseccomp.so.2 $TORCHROOT/lib/libseccomp.so.2

# More generic libs
cp /lib/x86_64-linux-gnu/libnss* /lib/x86_64-linux-gnu/libnsl* /lib/x86_64-linux-gnu/libresolv* \
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
/usr/sbin/chroot --userspec debian-tor:debian-tor $TORCHROOT /usr/sbin/tor $*
EOF
chmod +x $TORCHROOT/usr/sbin/tor-chroot.sh

# copy over the device nodes
mkdir -p $TORCHROOT/dev/
mknod -m 644 $TORCHROOT/dev/random c 1 8
mknod -m 644 $TORCHROOT/dev/urandom c 1 9
mknod -m 666 $TORCHROOT/dev/null c 1 3

# copy over the passwd/group and other system configs
grep debian-tor /etc/passwd > $TORCHROOT/etc/passwd
grep debian-tor /etc/group > $TORCHROOT/etc/group

cp /etc/nsswitch.conf /etc/host.conf /etc/resolv.conf /etc/hosts $TORCHROOT/etc/
cp /etc/localtime $TORCHROOT/etc

# If we get here, we hope to have a proper chroot 
echo "Chroot is configured; start the /etc/init.d/tor-chroot init.d script"
