vagrant-puppetmaster
====================

This is an example of how to automate the setup of a Puppet Master on CentOS 6.4  and Dashboard with Apache and Passenger.

## Create a base CentOS Box
On your local machine, create a new VirtualBox VM and install CentOS 6.4 x86_64. When it's done, log into the machine an execute the following commands to configure several CentOS feature to play nice with Vagrant.

    ifup eth0

    sed -i 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-eth0

    rm /var/lib/dhclient/*.leases

    yum remove postfix

    yum update

    cd /root

    mkdir .ssh

    echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==" > .ssh/authorized_keys

    chmod 600 .ssh/authorized_keys

    sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/sysconfig/selinux

    yum install vim wget gcc unzip make gcc kernel-devel kernel-headers

Next, install Virtual Box Guest additions by mounting the iso (f.e. in /mnt and running the installer):

    mount /dev/cdrom0 /mnt

    /mnt/VBoxLinuxAdditions.run

Finally, do the following changes in /etc/sudoers:

* Remove "Defaults requiretty" line
    
* Add SSH_AUTH_SOCK to env_keep
    
The VM is ready, we can now package and import it into Vagrant: 

    vagrant package --base <name of the VirtualBox VM> --output minimal-centos-6.4-x86_64.box

    vagrant box add <some name> minimal-centos-6.4-x86_64.box

## Clone repo and customize Vagrantfile

You can customize serveral things in the Vagrant file, like the newtowork, database passwords for the Dashboard, etc.

By default, the network is set to internal, with the following forwarded ports:

* 80 -> 10080 
    
* 443 -> 10443. 

For a production server you'll probably need to do some extra work like configuring a static IP, DNS record, SELinux policy, etc.

## Start VM
Run **vagrant up**. When the boot and provisioning process finishes, you'll be able to access the Puppet Dashboard at:

**https://localhost:10443**
