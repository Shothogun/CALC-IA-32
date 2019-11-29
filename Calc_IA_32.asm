section .data
global _start

;  ============== Prebuilt Strings  ==============
;  ===============================================
SPACE                 db  " ", 0h
SPACE_SIZE            EQU $-SPACE

NL                    db  0dh, 0ah, 0h
NL_SIZE               EQU  $-NL

hello_message         db "Insert your name please:", 0h
hello_message_size    EQU $-hello_message

NAME_SIZE             EQU 30

;  ============== Arguments Alias ==============
;  =============================================
%define PRINT_MESSAGE       [EBP+12]
%define PRINT_MESSAGE_SIZE  [EBP+8]

%define MESSAGE_ADDRESS     [EBP+12]
%define MESSAGE_SIZE        [EBP+8]

section .bss
NAME                  resb        30

section .text
_start:
; Ask user name
push hello_message
push hello_message_size
call Print_String
add esp, 8  

; Read user name
push NAME
push NAME_SIZE
call Read_String
add esp, 4 


; Return 0
mov eax, 1
mov ebx, 0
int 80h

;  ========= PRINT STRING FUNCTION =======================
;  ==  Params:                                          ==
;  ==   1. String begining address(without newline)     ==
;  ==   2. String size                                  ==
;  =======================================================
Print_String:
  enter 0,0
  push eax
  push ebx
  push ecx
  push edx

  mov eax, 4
  mov ebx, 1
  mov ecx, PRINT_MESSAGE
  mov edx, PRINT_MESSAGE_SIZE
  int 80h

  mov eax, 4
  mov ebx, 1
  mov ecx, NL
  mov edx, NL_SIZE
  int 80h

  pop edx
  pop ecx
  pop ebx  
  pop eax
  leave
  ret

;  ========= READ STRING FUNCTION =======================
;  ==  Params:                                          ==
;  ==   1. String input begining address(without        ==
;  ==      newline)                                     ==
;  ==   2. Input String size                            ==
;  =======================================================
Read_String:
  enter 0,0
  push eax
  push ebx
  push ecx
  push edx

  mov eax, 3
  mov ebx, 0
  mov ecx, MESSAGE_ADDRESS
  mov edx, MESSAGE_SIZE
  int 80h

  pop edx
  pop ecx
  pop ebx  
  pop eax
  leave
  ret

