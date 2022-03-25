#!/usr/bin/env bash

aws ec2 create-key-pair\ 
 --key-name packer 
 --key-type rsa 
 --query "KeyMaterial" 
 --output text > ~/.ssh/packer.pem

chmod 400 ~/.ssh/packer.pem

ssh-keygen -y -f ~/.ssh/packer.pem > ~/.ssh/packer.pub

chmod 600 ~/.ssh/packer.pub

ls -la ~/.ssh/

