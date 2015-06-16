#!/usr/bin/env bash

set -eux

ls -l $HOME/.ssh
cat /etc/hosts
cat $HOME/.ssh/config
cat $HOME/.ssh/authorized_keys
./circleci/ssh_config_to_etc_hosts.py > hosts
sudo cp hosts /etc/hosts
ssh-keygen -y -f ~/.ssh/build_key.rsa > ~/.ssh/build_key.rsa.pub
scp $HOME/.ssh/build_key.rsa.pub node1:mzbench_server.pub
scp $HOME/.ssh/build_key.rsa.pub node2:mzbench_server.pub
scp $HOME/.ssh/build_key.rsa.pub node3:mzbench_server.pub
ssh node1 'cat mzbench_server.pub | sudo tee -a /root/.ssh/authorized_keys'
ssh node2 'cat mzbench_server.pub | sudo tee -a /root/.ssh/authorized_keys'
ssh node3 'cat mzbench_server.pub | sudo tee -a /root/.ssh/authorized_keys'
scp $HOME/.ssh/build_key.rsa root@node1:.ssh/build_key.rsa
scp $HOME/.ssh/build_key.rsa root@node2:.ssh/build_key.rsa
scp $HOME/.ssh/build_key.rsa root@node3:.ssh/build_key.rsa
scp $HOME/.ssh/config root@node1:.ssh/config
scp $HOME/.ssh/config root@node2:.ssh/config
scp $HOME/.ssh/config root@node3:.ssh/config
scp hosts root@node1:/etc/hosts
scp hosts root@node2:/etc/hosts
scp hosts root@node3:/etc/hosts
ssh root@node1 'ls -l /etc/init.d'
ssh root@node1 'echo node1 > /etc/hostname && /etc/init.d/hostname restart'
ssh root@node2 'echo node2 > /etc/hostname && /etc/init.d/hostname restart'
ssh root@node3 'echo node3 > /etc/hostname && /etc/init.d/hostname restart'
ssh node1 'ls $HOME/.ssh'
ssh node2 'ls $HOME/.ssh'
ssh node3 'ls $HOME/.ssh'
ssh node1 'cat $HOME/.ssh/build_key.rsa'
ssh node2 'cat $HOME/.ssh/build_key.rsa'
ssh node3 'cat $HOME/.ssh/build_key.rsa'
ssh node1 'cat $HOME/.ssh/config'
ssh node2 'cat $HOME/.ssh/config'
ssh node3 'cat $HOME/.ssh/config'
ssh node1 'cat /etc/hosts'
ssh node2 'cat /etc/hosts'
ssh node3 'cat /etc/hosts'
ssh node1 'hostname'
ssh node2 'hostname'
ssh node3 'hostname'
ssh node1 'ssh node2 hostname'
ssh node1 'ssh node3 hostname'
ssh root@node1 'ssh node2 hostname'
ssh root@node1 'ssh root@node2 hostname'