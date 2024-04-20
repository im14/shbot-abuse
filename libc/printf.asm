%include "libc-offsets.inc"
%define __libc_start_main 0x209fe0       ; readelf -W -r nl | awk '/libc_start_main/{print $1}'
%define __libc_start_main_offset 0x21b10 ; readelf -W -s libc.so.6 | awk '/libc_start_main/{print $2}' 
%define	_bin_sh 1785370                  ; grep -Pabo /bin/sh libc.so.6
%define _start 0x1de0

; parameters
;   rdi, rsi, rdx, rcx, r8, r9, RTL stack
; syscall clobbers
;   rcx, r11, rax (return)
; caller-saved
;   rax, (rdi, rsi, rdx, rcx, r8, r9), r10, r11
; callee-saved
;   rsp, rbx, rbp, r12, r13, r14, r15

BITS 64
ORG _start
; for some reason nasm calculates $ from 0 even if i put sections
;  probably gotta use some different directive for bin format
main:
  ; get base_addr of libc into rbx
fromhere equ __libc_start_main-_start-$
  mov rbp,[rel $+fromhere]

	mov	r12, rdi   ; argc
	mov	r13, rsi   ; argv
	mov r14, 0     ; i
loop1:
	cmp	r14, r12   ; while i < argc
	jnl	.end

  mov rdx, r13[r14*8]    ; rdx=argv[i]

	lea	rdi, [rel str1]    ; printf(fmt1, i, argv[i])
  mov rsi, r14
  lea rax, [rbp-__libc_start_main_offset+printf]
  call rax
	add	r14, 1
  jmp loop1

.end:
	lea	rdi, [rel str2]
  lea rax, [rbp-__libc_start_main_offset+puts]
  call rax

  ; exit(42)
  mov edi,42
  lea rax, [rbp-__libc_start_main_offset+exit]
  call rax
  ret

str1: db '%d:%s '
str2: db 0
