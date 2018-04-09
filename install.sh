#!/bin/bash


if [ "$EUID" -ne 0 ]
then echo "Must be root"
     exit
fi

if [[ $# -lt 2 ]]; 
then echo "You need to pass a password and name!"
     echo "Usage:"
     echo "sudo $0 [apPassword] [apName]"
     exit
fi



basic-setup.sh $1 $2 && cp dhcpcd.sh /usr/lib/dhcpcd5/dhcpcd

