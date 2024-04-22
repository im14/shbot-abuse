; scott nicholas <m@san.aq> 2024-04-12

%include "libc-offsets.inc"
%define __libc_start_main 0x209fe0
%define __libc_start_main_offset 0x21b10
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
main:
fromhere equ __libc_start_main-_start-$
  mov rbp,[rel $+fromhere]
  mov r12, 0
  mov r13, 1
  mov r15, 92    ; limit

  mov rsi, [rsi+8]  ;argv[1]
  cmp rdi, 2
  jne .L0

  ; use argv[1] as limit
  mov rdi, rsi
  xor rsi, rsi
  mov rdx, 10
  lea rax, [rbp-__libc_start_main_offset+strtoll]
  call rax

  mov r14, rax   ; save it

  ; if 0 or >92, don't use it.
  cmp r14, 0
  je .L0

  cmp r14, r15
  jg .L0

  mov r15, r14
.L0:

  xor eax, eax

  lea rdi, [rel fmt1]
  lea rax, [rbp-__libc_start_main_offset+printf]
  call rax

loop:
  mov rax, r12
  add rax, r13

  mov r12, r13
  mov r13, rax

  xor eax, eax
  mov rsi, r13
  lea rdi, [rel fmt2]
  lea rax, [rbp-__libc_start_main_offset+printf]
  call rax
  dec r15
  jnz loop

  xor eax, eax
  lea rdi, [rel nl]
  lea rax, [rbp-__libc_start_main_offset+printf]
  call rax

  xor eax, eax
  ret

fmt1: db '0, 1', 0
fmt2: db ', %llu', 0
nl: db 10, 0
