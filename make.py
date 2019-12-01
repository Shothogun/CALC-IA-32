import sys
import os
import os.path

if len(sys.argv) < 2:
  print("Invalid number of arguments!")
else:
  name = sys.argv[1]
  name = name.split(".")

  nasm = "nasm -f elf -o " + name[0] + ".o" + " " + name[0] + ".asm"
  ld = "ld -m elf_i386 -o " + name[0] + " " + name[0] + ".o"

  os.system(nasm)
  os.system(ld)
  
  # Run
  if "-r" in sys.argv and os.path.isfile(name[0]):
    run = "./" + name[0]
    os.system(run)

  # Clear object file
  if "-c" in sys.argv and os.path.isfile(name[0] + ".o"):
    clear = "rm " + name[0] + ".o"
    os.system(clear)



