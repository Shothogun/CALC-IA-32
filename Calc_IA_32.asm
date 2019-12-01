;  ============== Useful Macros ==================
;  ===============================================

; Ask for two arguments for user and store in parameters 1 and 2

%macro ReadOp 2
  push op1_message
  push op1_message_size
  call Print_String
  add esp, 8 

  call Read_Int32

  push eax
  push op2_message
  push op2_message_size
  call Print_String
  add esp, 8 
  call Read_Int32
  mov %2, eax
  pop %1
%endmacro

; Skip a line
%macro NwLine 0
  push NL
  push NL_SIZE
  call Print_String
  add esp, 8  
%endmacro

; Print the result of an operation stored in the parameter
%macro PrintResult 1
  push %1
  push result_message
  push result_message_size
  call Print_String
  add esp, 8 
  call Print_Int32
  NwLine
%endmacro

; Wait for user to press enter button
%macro WaitEnter 0
  push CHAR
  push CHAR_SIZE
  call Read_String
  add esp, 8
%endmacro


%macro Inc64 2
  add %2, 1         ; Add low order 32-bits
  adc %1, 0         ; Add high order 32-bits, and the carry if there was one
%endmacro



section .data
global _start

;  ============== Prebuilt Strings  ==============
;  ===============================================
NEGATIVE_BIT          EQU 1

SPACE                 db  " ", 0h
SPACE_SIZE            EQU $-SPACE

NL                    db  0dh, 0ah, 0h
NL_SIZE               EQU  $-NL

hello_message         db "Por favor digite seu nome:", 0h
hello_message_size    EQU $-hello_message

hello                 db "Olá, "
hello_size            EQU $-hello

welcome               db ", bem-vindo ao programa de CALC IA-32"
welcome_size          EQU $-welcome

NAME_SIZE             EQU 30

menu_message          db "ESCOLHA UMA OPÇÃO:", 0ah, 0dh,
                      db "- 1: SOMA", 0ah, 0dh,
                      db "- 2: SUBSTRAÇÃO", 0ah, 0dh,
                      db "- 3: MULTIPLICAÇÃO", 0ah, 0dh,
                      db "- 4: DIVISÂO", 0ah, 0dh,
                      db "- 5: MOD", 0ah, 0dh,
                      db "- 6: SAIR", 0ah, 0dh

menu_message_size     EQU $-menu_message

op1_message           db "Por favor digite o primeiro operando:", 0ah, 0dh
op1_message_size      EQU $-op1_message

op2_message           db "Por favor digite o segundo operando:", 0ah, 0dh
op2_message_size      EQU $-op2_message

result_message        db "Resultado:", 0ah, 0dh
result_message_size   EQU $-result_message

;  ============== Arguments Alias ==============
;  =============================================
%define PRINT_MESSAGE       [EBP+12]
%define PRINT_MESSAGE_SIZE  [EBP+8]

%define MESSAGE_ADDRESS     [EBP+12]
%define MESSAGE_SIZE        [EBP+8]

%define PRINT_INT           [EBP+8]

%define NUMBER              [EBP+8]

%define N64_H               [EBP+12]
%define N64_L               [EBP+8]

section .bss
NAME                  resb        30
DEBUG                 resd        1

CHAR                  resb        1
CHAR_SIZE             EQU         1

BUFFER32              resb        12
BUFFER32_SIZE         EQU         12

BUFFER64              resb        21
BUFFER64_SIZE         EQU         21

section .text
_start:
  ; Ask user name
  push hello_message
  push hello_message_size
  call Print_String
  add esp, 8  
  NwLine

  ; Read user name
  push NAME
  push NAME_SIZE
  call Read_String
  add esp, 4 

  ; Hello Message
  NwLine
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
  NwLine
  NwLine

Menu:
  push menu_message
  push menu_message_size
  call Print_String
  NwLine

  call Read_Int32
  cmp eax, 1 
  je Add
  cmp eax, 2
  je Sub
  cmp eax, 3
  je Mult
  cmp eax, 4
  je Div
  cmp eax, 5
  je Mod
  ; Default or option 6, exit
  jmp Return

Add:
  ReadOp eax, ebx
  add eax, ebx
  PrintResult eax
  WaitEnter
  jmp Menu

Sub:
  ReadOp eax, ebx
  sub eax, ebx
  PrintResult eax
  WaitEnter
  jmp Menu

Mult:

  ReadOp eax, ebx
  push eax
  push ebx
  push result_message
  push result_message_size
  call Print_String
  add esp, 8 
  pop ebx
  pop eax

  imul ebx
  
  push edx
  push eax
  call Print_Int64
  add esp, 8

  NwLine
  WaitEnter
  jmp Menu

Div:
  ReadOp eax, ebx
  cdq
  idiv ebx
  PrintResult eax
  WaitEnter
  jmp Menu

Mod:
  ReadOp eax, ebx
  cdq
  idiv ebx
  PrintResult edx
  WaitEnter
  jmp Menu

; Return 0
Return:
  mov eax, 1
  mov ebx, 0
  int 80h


;  ========= PRINT STRING FUNCTION =======================
;  ==  Params:                                          ==
;  ==   1. String beginning address(without newline)    ==
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

;  ========= READ STRING FUNCTION ========================
;  ==  Params:                                          ==
;  ==   1. String input beginning address(without       ==
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

;  ========= READ INT 32 FUNCTION ========================
;  ==  Return:                                          ==
;  ==   1. INT 32 value (EAX)                           ==
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
;  ==   1. INT 32 value                                 ==
;  =======================================================

Print_Int32:
  enter 0,0
  pusha

  xor eax, eax
  xor edx, edx
  xor ecx, ecx
  xor edi, edi
  mov ebx, BUFFER32
  mov eax, NUMBER

  ; Check if it's 0
  cmp eax, 0
  jne PI32_Negative
  mov dl, 0
  add dl, 0x30
  mov byte [ebx], dl
  mov dl, [ebx]
  inc ecx
  jmp PI32_Cont3

  ; Check if it's a negative number
PI32_Negative:  
  test eax, 0x80000000
  je PI32_Positive
  xor eax, eax
  ; Convert to positive
  sub eax, NUMBER
  ; Inserts the "-"
  mov byte [ebx], 0x2d 
  inc ebx
  ; Enter 1 to indicate negative number
  mov edi, 1
  jmp PI32_Conv_Loop

PI32_Positive:
  mov eax, NUMBER

; Convert from binary to decimal ASCII

PI32_Conv_Loop:

  xor edx, edx
  push ebx
  mov ebx, 10
  div ebx
  pop ebx

  ; Checks if the quotient is 0
  cmp eax, 0
  jne PI32_Cont
  ; Checks if the rest is 0
  cmp edx, 0
  je PI32_Cont3

PI32_Cont:  
  add edx, 0x30

  push ecx

; Shifts previous elements to the right 
PI32_Shift_R:
  cmp ecx, 0
  je PI32_Cont2
  mov byte dh, [ebx + ecx - 1]
  mov byte [ebx + ecx], dh 
  dec ecx
  jmp PI32_Shift_R

; Inserts the current element in the first position
PI32_Cont2:  
  mov byte [ebx], dl
  pop ecx
  inc ecx
  jmp PI32_Conv_Loop

PI32_Cont3:
  cmp edi, 1
  jne PI32_Print
  ; If it is a negative number, set the pointer to the "-"
  inc ecx
  dec ebx

PI32_Print:  
  push ebx
  push ecx
  call Print_String
  add esp, 8
  popa
  leave
  ret


;  ========= PRINT INT 64 FUNCTION =======================
;  ==  Params:                                          ==
;  ==   1. INT64 value                                  ==
;  =======================================================

Print_Int64:
  enter 0,0
  push eax
  push ebx
  push ecx
  push edx
  push edi
  push esi

  xor eax, eax
  xor edx, edx
  xor ecx, ecx
  xor edi, edi
  mov ebx, BUFFER64
  ; Check if it's 0
  mov eax, N64_H
  cmp eax, 0
  jne PI64_Negative
  mov eax, N64_L
  cmp eax, 0
  jne PI64_Negative
  mov dl, 0
  add dl, 0x30
  mov byte [ebx], dl
  mov dl, [ebx]
  inc ecx
  jmp PI64_Cont3
PI64_Negative:  
  mov eax, N64_H
  test eax, 0x80000000
  je PI64_Conv_Loop
  ; Convert to positive
  
  push edx
  push eax
  push dword N64_H
  push dword N64_L
  call ConvN2P64
  mov N64_H, edx
  mov N64_L, eax
  pop eax
  pop edx

  ; Inserts the "-"
  mov byte [ebx], 0x2d 
  inc ebx
  ; Enter 1 to indicate negative number
  mov edi, 1

PI64_Conv_Loop:

  mov esi, 10
  xor edx,edx
  mov eax,N64_H
  div esi
  mov N64_H,eax       
  mov eax,N64_L
  div esi
  mov N64_L,eax                    

  ; Checks if the quotient is 0
  cmp dword N64_H, 0
  jne PI64_Cont
  cmp dword N64_L, 0
  jne PI64_Cont

  ; Checks if the rest is 0
  cmp edx, 0
  je PI64_Cont3

PI64_Cont:  
  add edx, 0x30
  push ecx

; Shifts previous elements to the right 
PI64_Shift_R:
  cmp ecx, 0
  je PI64_Cont2
  mov byte dh, [ebx + ecx - 1]
  mov byte [ebx + ecx], dh 
  dec ecx
  jmp PI64_Shift_R

; Inserts the current element in the first position
PI64_Cont2:  
  mov byte [ebx], dl
  pop ecx
  inc ecx
  jmp PI64_Conv_Loop

PI64_Cont3:
  cmp edi, 1
  jne PI64_Print
  ; If it is a negative number, set the pointer to the "-"
  inc ecx
  dec ebx
PI64_Print:  
  push ebx
  push ecx
  call Print_String
  add esp, 8

  pop esi
  pop edi 
  pop edx
  pop ecx
  pop ebx
  pop eax

  leave
  ret 

;  ========= CONV NEG TO POS FUNCTION ====================
;  ==  Params:                                          ==
;  ==   1. Negative INT64 value                         ==
;  ==  Return:                                          ==
;  ==   1. Positive INT64 value  (EDX:EAX)              ==
;  =======================================================

ConvN2P64: 
  enter 0,0
  push edi
  push esi

  mov edx, [ebp+12]
  mov eax, [ebp+8]
  mov edi, 0
  mov esi, 0
  sub edi, eax          ; Subtract low order 32-bits, borrow reflected in CF
  sbb esi, edx          ; Subtract high order 32-bits, and the borrow if there was one
  mov edx, esi
  mov eax, edi

  pop esi
  pop edi
  leave
  ret


