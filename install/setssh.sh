#!/bin/bash

auto_ssh_copy()
{
        expect -c "set timeout -1;
                spawn ssh-copy-id $user@$ip
                expect {
                        *(yes/no)* {send -- yes\r;exp_continue;}
                        *assword:* {send -- $password\r;exp_continue;}
                        eof        {exit 0;}
        }";
}

ip=$1
user=$2
password=$3

if [ ! -f '/root/.ssh/id_rsa.pub' ]; then
        ssh-keygen -P '' -f /root/.ssh/id_rsa
        auto_ssh_copy
else
        auto_ssh_copy

fi

