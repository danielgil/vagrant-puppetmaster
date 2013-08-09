#!/bin/bash

. /etc/rc.d/init.d/functions

echo -n "Installing PuppetLabs repository: "
(sudo rpm -ivh http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm 2>>/vagrant/logs/bootstrap-master.log 1>&2 && success) || failure
echo

echo -n "Installing EPEL repository: "
(sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm 2>>/vagrant/logs/bootstrap-master.log 1>&2 && success) || failure
echo

echo -n "Installing Passenger repository: "
(rpm --import http://passenger.stealthymonkeys.com/RPM-GPG-KEY-stealthymonkeys.asc 2>>/vagrant/logs/bootstrap-master.log 1>&2 && yum install -y http://passenger.stealthymonkeys.com/rhel/6/passenger-release.noarch.rpm 2>>/vagrant/logs/bootstrap-master.log 1>&2 && success) || failure
echo

echo -n "Performing yum update: "
(yum update -y 2>>/vagrant/logs/bootstrap-master.log 1>&2 && success) || failure
echo

echo -n "Installing Puppet Master: "
(yum install -y puppet-server 2>>/vagrant/logs/bootstrap-master.log 1>&2 && success) || failure
echo

echo -n "Disabling firewall (temporary): "
(iptables -F 2>>/vagrant/logs/bootstrap-master.log 1>&2 && success) || failure
echo

