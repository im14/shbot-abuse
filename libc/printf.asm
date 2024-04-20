%include "libc-offsets.inc"
%define __libc_start_main 0x209fe0       ; readelf -W -r nl | awk '/libc_start_main/{print $1}'
%define __libc_start_main_offset 0x21b10 ; readelf -W -s libc.so.6 | awk '/libc_start_main/{print $2}' 
%define	_bin_sh 1785370                  ; grep -Pabo /bin/sh libc.so.6
%define _start 0x1de0

; amd64 abi:
;   rdi, rsi, rdx, rcx, r8, r9, RTL stack

BITS 64
ORG _start
; for some reason nasm calculates $ from 0 even if i put sections
;  probably gotta use some different directive for bin format
main:
	push	rsi		; argv
	push	rdx		; envp

  ; get base_addr of libc into rbx
  ; one way
fromhere equ __libc_start_main-_start-$
  mov rbx,[rel $+fromhere]
  ; or another
  ;call .get_GOT
.get_GOT:
  ;pop rbx
  ;mov rbx,[rbx+__libc_start_main-.get_GOT]

  sub rbx,__libc_start_main_offset

	pop	rdx		; envp
	pop	rsi		; argv
  mov rdx, [rdx]
  mov rsi, [rsi]
	lea	rdi, [rel fmt]
  lea rax, [rbx+printf]
  call rax

  ret

fmt: db '%s %s', 10, 0
