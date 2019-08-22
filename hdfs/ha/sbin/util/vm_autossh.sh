#!/usr/bin/expect -f
 
set timeout 10
set password 7140
set username [lindex $argv 0]
set host [lindex $argv 1]
set command [lindex $argv 2]

spawn ssh $username@$host "$command"

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
