section .data
global _start

;  ============== Prebuilt Strings  ==============
;  ===============================================
NEGATIVE_BIT          EQU 1


SPACE                 db  " ", 0h
SPACE_SIZE            EQU $-SPACE

NL                    db  0dh, 0ah, 0h
NL_SIZE               EQU  $-NL

hello_message         db "Insert your name please:", 0h
hello_message_size    EQU $-hello_message

hello                 db "Olá, "
hello_size            EQU $-hello

welcome               db ", bem-vindo ao programa de CALC IA-32"
welcome_size          EQU $-welcome

NAME_SIZE             EQU 30

;  ============== Arguments Alias ==============
;  =============================================
%define PRINT_MESSAGE       [EBP+12]
%define PRINT_MESSAGE_SIZE  [EBP+8]

%define MESSAGE_ADDRESS     [EBP+12]
%define MESSAGE_SIZE        [EBP+8]

%define PRINT_INT           [EBP+8]

section .bss
NAME                  resb        30
DEBUG                 resd        1

section .text
_start:
; Ask user name
push hello_message
push hello_message_size
call Print_String
add esp, 8  

push NL
push NL_SIZE
call Print_String
add esp, 8  

; Read user name
push NAME
push NAME_SIZE
call Read_String
add esp, 4 

; Ask user name
push NAME
push NAME_SIZE
call Print_String
add esp, 8  

push NL
push NL_SIZE
call Print_String
add esp, 8

; Hello Message
push hello
push hello_size
call Print_String
add esp, 8  

push NAME
push NAME_SIZE
call Print_String
add esp, 8  

push welcome
push welcome_size
call Print_String
add esp, 8 

push NL
push NL_SIZE
call Print_String
add esp, 8 

; Return 0
mov eax, 1
mov ebx, 0
int 80h

;  ========= PRINT STRING FUNCTION =======================
;  ==  Params:                                          ==
;  ==   1. String beginning address(without newline)     ==
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

  pop edx
  pop ecx
  pop ebx  
  pop eax
  leave
  ret

;  ========= READ STRING FUNCTION =======================
;  ==  Params:                                          ==
;  ==   1. String input beginning address(without        ==
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

  sub esi, esi

ITERATE_MESSAGE:
  mov eax, MESSAGE_ADDRESS
  mov ebx, [eax + esi]
  mov [DEBUG], ebx  

  inc esi
  cmp esi, NAME_SIZE    ; Iterates through name string              
  ja  Finish_Read_String

  cmp ebx, 0dh          ; Compare a CR character with the current character
  je ERASE_NL
  cmp ebx, 0ah          ; Compare a newline character with the current character
  jne ITERATE_MESSAGE

ERASE_NL:
  ; Erases newline character
  dec esi
  mov byte [eax + esi], 0h
  inc esi
  mov byte [eax + esi], 0h

Finish_Read_String:
  pop edx
  pop ecx
  pop ebx  
  pop eax
  leave
  ret

;  ========= PRINT INT FUNCTION =======================
;  ==  Params:                                          ==
;  ==   1. INT address input beginning address(without  ==
;  ==      newline)                                     ==
;  =======================================================
Print_int:
  enter 0,0
  pusha

  ; EAX =====> Bytes from number(64 bits)
  ; EBX =====> Pointer to the number bytes
  ; ECX =====> Value at the pointer
  mov eax,7
  mov ebx, PRINT_INT

  ; Gets the first MST byte
  mov cl,[ebx]


  ; Check signal
  

  ; Convert Binary to ASCII
  popa
  leave
  ret
