# CALC-IA-32

This repository is the 2nd from the discipline from the discipline System Software 2/2019 at Universidade de Brasilia. In this project, a Calculator program in assembly x86-IA-32, based on Intel syntax, is developed to perform basic operations taking two parameters.

All possible operations are:

- 1: SUM
- 2: SUBTRACTION
- 3: MULTIPLICATION
- 4: DIVISION
- 5: MOD
- 6: EXIT

After input two parameters (signed integers), the program will output the result and wait for the user's command by clicking ENTER, to return back at the main menu.

## Details

This project was developed in Linux distro Ubuntu 18.04 LTS, using Intel syntax and NASM compiler.

## Compilation

At terminal, at the same directory from the project, type:

> $ nasm -f elf -o Calc_IA_32.o Calc_IA_32.asm

## Link

> $ ld -m elf_i386 -o Calc_IA_32 Calc_IA_32.o