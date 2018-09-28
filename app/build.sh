#!/bin/bash

set -e

iso=CentOS-7-x86_64-Minimal.iso
uribase=https://buildlogs.centos.org/rolling/7/isos/x86_64/
uri=$uribase$iso

time (
	wget -c -N $uri -q --show-progress --progress=bar:force:noscroll -O /cache/$iso
	ls -lah /cache/$iso
	file /cache/$iso

	(mkdir -p /mnt/iso &> /dev/null || exit 0)
	mount -o loop /cache/$iso /mnt/iso

	(mkdir /cache/centos &> /dev/null || exit 0)

	rsync -a --info=progress2 /mnt/iso/ /cache/centos

	(mkdir -pv /cache/rpms || exit 0)

	echo "Downloading open-vm-tools RPMs..."
	yumdownloader --resolve --destdir=/cache/rpms/open-vm-tools/ open-vm-tools &> /dev/null

	echo "Injecting configs & RPMs in to ISO tree..."
	cp /configs/ks.cfg /configs/isolinux.cfg /cache/centos/isolinux
	cp /cache/rpms/open-vm-tools/* /cache/centos/Packages

	echo "Injecting RSA keys in to kickstart..."
	# inject public key into kickstart
	pushd /keys
	sed -i.bak '/COASTER_SSH_PUBKEY/r./id_rsa.pub' /cache/centos/isolinux/ks.cfg
	popd

	pushd /cache/centos

	createrepo -g /cache/centos/repodata/*-comps.xml .

	echo "Creating ISO..."
	mkisofs -q -o /output/centos-7-coaster.iso -b isolinux/isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -V "CentOS 7 x86_64 COASTER" -R -J -v -T . &> /dev/null

	implantisomd5 /output/centos-7-coaster.iso
	file /output/centos-7-coaster.iso

	sha256sum /output/centos-7-coaster.iso
)