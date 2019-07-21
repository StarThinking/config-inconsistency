#!/usr/bin/expect -f
 
set timeout 10
set password 7140
set username [lindex $argv 0]
set host [lindex $argv 1]
set src_file [lindex $argv 2]
set dst_file [lindex $argv 3]

sudo spawn scp $src_file $username@$host:$dst_file

expect {
    "(yes/no)?" {
        send "yes\n"
        expect "password:"
        send "$password\n"
    }
    
    "password:" {
        send "$password\n"
    }
}
interact
