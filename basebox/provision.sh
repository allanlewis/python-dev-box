#!/bin/bash -eux

# Provision a Fedora VM according to the requirements for a Vagrant basebox:
# https://docs.vagrantup.com/v2/boxes/base.html
# https://docs.vagrantup.com/v2/virtualbox/boxes.html

# Vagrant insecure private key:
# https://github.com/mitchellh/vagrant/tree/master/keys
VAGRANT_SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"

# Vagrant: Passwordless SSH login for vagrant user
mkdir -p -m 0700 ~vagrant/.ssh
echo "${VAGRANT_SSH_KEY}" >~vagrant/.ssh/authorized_keys
chmod 0600 ~vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant ~vagrant/.ssh

# Vagrant: Passwordless sudo for vagrant user
cat <<-EOF >/etc/sudoers.d/vagrant
	Defaults: vagrant !requiretty
	vagrant ALL=(ALL) NOPASSWD: ALL
	EOF
chmod 0400 /etc/sudoers.d/vagrant

# Vagrant: Avoid reverse DNS lookup to keep SSH speedy when host is offline
echo "UseDNS no" >>/etc/ssh/sshd_config

sed -i 's/^enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates.repo

# Upgrade all packages
yum upgrade -y

# Install base packages for X.org display server
yum install -y @base-x

# Vagrant: Install VirtualBox guest additions with X.org driver
VBOX_MOUNT='/mnt/vbox'
VBOX_ISO=~vagrant/"VBoxGuestAdditions.iso"
mkdir "${VBOX_MOUNT}"
mount -o ro,loop "${VBOX_ISO}" "${VBOX_MOUNT}"
"${VBOX_MOUNT}"/VBoxLinuxAdditions.run || true  # Ignore false failure
umount "${VBOX_MOUNT}"
rmdir "${VBOX_MOUNT}"
rm "${VBOX_ISO}"
for module in vboxguest vboxsf vboxvideo; do    # Verify modules loaded
    modprobe "${module}"
done

# Vagrant: Remove all traces of MAC addresses from network configs
sed -i '/^HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth*

# YouView: Also passwordless SSH login for root user
mkdir -p -m 0700 /root/.ssh
echo "${VAGRANT_SSH_KEY}" >/root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys

# Clean out yum caches to reduce size of image on disk
yum -y clean all
