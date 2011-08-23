#
# A basic Makefile to install and remove things
#

install:
	# These could go into DESTDIR but I want them in the normal init.d path
	cp tor-chroot.init $(DESTDIR)/etc/init.d/tor-chroot
	cp tor-chroot.default $(DESTDIR)/etc/default/tor-chroot
	cp tor-chroot-update.sh $(DESTDIR)/sbin/tor-chroot-update.sh
	# This is not needed but is included outside of the chroot for debugging
	cp tor-chroot.sh $(DESTDIR)/sbin/tor-chroot.sh
	# You want to use update-rc.d to enable tor-chroot at boot time

uninstall:
	rm $(DESTDIR)/etc/init.d/tor-chroot
	rm $(DESTDIR)/etc/default/tor-chroot
	rm $(DESTDIR)/sbin/tor-chroot-update.sh
	rm $(DESTDIR)/sbin/tor-chroot.sh
