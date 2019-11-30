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

BUFFER32                resb        11
BUFFER32_SIZE           EQU 11

BUFFER64                resb        21
BUFFER64_SIZE           EQU 21

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
; push NAME
; push NAME_SIZE
; call Print_String
; add esp, 8  

; push NL
; push NL_SIZE
; call Print_String
; add esp, 8

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

;  ========= READ INT 32 FUNCTION ========================
;  ==  Params:                                          ==
;  ==                                                   ==
;  =======================================================

Read_Int32:
  enter 0,0
  push ebx
  push ecx
  push edx
  push edi

  mov eax, 3
  mov ebx, 0
  mov ecx, BUFFER32
  mov edx, BUFFER32_SIZE
  int 80h

  xor ecx, ecx
  xor eax, eax
  mov ebx, BUFFER32

RI32_Conv_Loop:
  ; Check if it's a "\n"
  mov dl, 0x0a
  cmp dl, [ebx + ecx]
  je RI32_Cont
  ; Multiplies by 10
  push eax
  shl eax, 3
  add eax, [esp]
  add eax, [esp]
  ; Check if it's a negative sign
  mov dl, 0x2d
  cmp dl, [ebx + ecx]
  je RI32_Neg_Signal
  ; Convert ASCII to int
  sub edx, edx
  mov dl, [ebx + ecx]
  sub edx, 0x30
  add eax, edx
RI32_Neg_Signal:
  inc ecx
  jmp RI32_Conv_Loop
RI32_Cont:
  ; Check if it's a negative number
  mov dl, 0x2d
  cmp byte dl, [ebx]
  jne RI32_Positive
  push eax
  xor eax, eax
  sub eax, [esp]
  add esp, 4
RI32_Positive:
  pop edi
  pop edx
  pop ecx
  pop ebx
  leave
  ret

;  ========= PRINT INT 32 FUNCTION =======================
;  ==  Params:                                          ==
;  ==                                                   ==
;  =======================================================

;  ========= PRINT INT 64 FUNCTION =======================
;  ==  Params:                                          ==
;  ==                                                   ==
;  =======================================================