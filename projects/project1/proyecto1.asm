.data

null: .ascii "\n"
user: .asciiz "Introduzca el nombre del archivo:\n"

file: .space 12
buffer: .space 9

.align 2 # En caso de que antes de programa tenga 
	 # otras reservas de espacio de memoria.

operaciones: .space 1024
tipos: .space 1024

espacio: .asciiz " "
dolar: .asciiz "$"
parentesis1: .asciiz "("
parentesis2: .asciiz ")"
_R: .asciiz "R"
_I: .asciiz "I"

_add: .asciiz "add"
_addi: .asciiz "addi"
_and: .asciiz "and"
_andi: .asciiz "andi"
_mult: .asciiz "mult"
_or: .asciiz "or"
_ori: .asciiz "ori"
_sllv: .asciiz "sllv"
_sub: .asciiz "sub"

_lw: .asciiz "lw"
_sw: .asciiz "sw"

_bne: .asciiz "bne"
_beq: .asciiz "beq"

_halt: .asciiz "halt"
nextLine: .asciiz "\n"

.align 2 # En caso de que antes de programa tenga 
	 # otras reservas de espacio de memoria.
programa: .space 400

.text

	# Prints message to user
	li $v0, 4 	   # Syscall to read string from user.
	la $a0, user	   # Addres were string will be loaded.
	syscall


	# Read file name
	li $v0, 8 	   # Syscall to read string from user.
	la $a0, file	   # Addres were string will be loaded.
	li $a1, 19	   # Maximun number of caracters.
	syscall
	
	# Quita caracter nulo al final del nombre de archivo
	li   $a1, 0
	lb   $t0, 0($a0)
	lb   $t1, null
loop1:	beq  $t0, $t1, cont1
	lb   $t0, 1($a0)
	la   $a0, 1($a0)
	b    loop1
cont1:	
	sb   $zero, 0($a0)

	# Abre el archivo
	li $v0, 13
	la $a0, file
	li $a1, 0
	li $a2, 0
	syscall
	move $s6, $v0
	
	la   $t6, programa
	
loop2: 	beq  $v0, $zero, cont2
	# Lee linea del archivo
	li   $v0, 14
	move $a0, $s6
	la   $a1, buffer
	li   $a2, 9
	syscall
	
	# Quita caracter nulo al final de cada linea.
	sb   $zero, 8($a1)
	
	li   $t4, 0
	
	# Leo la linea del archivo en buffer.
	la   $a2, buffer
	
loop3:  bge  $t4, 4, cont3
	
	sll  $t5, $t5, 8
	lb   $t0, 0($a2) # Primer caracter
	lb   $t3, 1($a2) # Segundo caracter
	
	# Reviso en que caso estoy (Letra o numero).
	# Caracter 1
	bge  $t0, 0x60, let1
	# Caso Numero
	andi $t0, 0x0f
	
	b num1
	# Caso Letra
let1:	addi $t0, $t0, 9
	andi $t0, $t0, 0x0f
num1:
	# Caracter 2
	bge  $t3, 0x60, let2
	# Caso Numero
	andi $t3, 0x0f
	
	b num2
	# Caso Letra
let2:	addi $t3, $t3, 9
	andi $t3, $t3, 0x0f
num2: 
	# Uno y añado a la palabra
	sll  $t0, $t0, 4
	or   $t0, $t0, $t3
	add  $t5, $t0, $t5

	la   $a2, 2($a2)
	addi $t4, $t4, 1
	b    loop3
cont3: 
	sw   $t5, 0($t6)
	la   $t6, 4($t6)
	
	b loop2
cont2:  
	
	# Close the file 
  	li   $v0, 16       # system call for close file
  	move $a0, $s6      # file descriptor to close
  	syscall            # close file
  	
# Almaceno las operaciones en el puesto correspondiente a su codigo de operacion
la $t0, operaciones

la $t1, _add
la $t7, 128($t0)
sw $t1, 128($t0)

la $t1, _addi
sw $t1, 32($t0)

la $t1, _and
sw $t1, 160($t0)

la $t1, _andi
sw $t1, 48($t0)

la $t1, _mult
sw $t1, 96($t0)

la $t1, _or
sw $t1, 148($t0)

la $t1, _ori
sw $t1, 52($t0)

la $t1, _sllv
sw $t1, 16($t0)

la $t1, _sub
sw $t1, 136($t0)

la $t1, _lw
sw $t1, 140($t0)

la $t1, _sw
sw $t1, 172($t0)

la $t1, _bne
sw $t1, 20($t0)

la $t1, _beq
sw $t1, 24($t0)

la $t1, _halt
sw $t1, ($t0)

li $v0, 10
syscall

# Almaceno los tipos de cada operacion 0 para R, 1 para I (sin lw ni sw) y 2 para lw y sw
la $t0, tipos

li $t1, 0 

sw $t1, 128($t0)
sw $t1, 160($t0)
sw $t1, 96($t0)
sw $t1, 148($t0)
sw $t1, 16($t0)
sw $t1, 136($t0)

li $t1, 1

sw $t1, 32($t0)
sw $t1, 48($t0)
sw $t1, 52($t0)
sw $t1, 20($t0)
sw $t1, 24($t0)

li $t1, 2

sw $t1, 140($t0)
sw $t1, 172($t0)


li $t1, -1
sw $t1, ($t0)

###############

la $s6, programa
la $s1, operaciones
la $s2, tipos

# Iteracion

loop:

lw $s0, ($s6)
	
# Operacion
li $v0, 34
move $a0, $s0
syscall

li $v0, 4
la $a0, espacio
syscall

andi $a1, $s0, 0xfc000000
srl $a1, $a1, 24

add $a2, $a1, $s2
add $a1, $a1, $s1

li $v0, 10
syscall

lw $a1, 0($a1)
lw $a2, 0($a2)

li $v0, 10
syscall

# rt
	andi $s3, $s0, 0x001f0000
	srl $s3, $s3, 16
# rs
	andi $s4, $s0, 0x03e00000
	srl $s4, $s4, 21
# rd
	andi $s5, $s0, 0x0000f800
	srl $s5, $s5, 11

beq $a2, -1, salir
bnez $a2, I

R:	la $a0, _R
	syscall

	la $a0, espacio
	syscall

	move $a0, $a1
	syscall

	la $a0, espacio
	syscall
	
	la $a0, dolar
	syscall
	
	# rd
	move $a0, $s5
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, espacio
	syscall

	la $a0, dolar
	syscall
	
	# rs
	move $a0, $s4
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, espacio
	syscall

	la $a0, dolar
	syscall
	
	# rt
	move $a0, $s3
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, nextLine
	syscall
		
	addi $s6, $s6, 4

	b loop


I:	la $a0, _I
	syscall

	la $a0, espacio
	syscall
	
	beq $a2, 2, lw_sw

	move $a0, $a1
	syscall

	la $a0, espacio
	syscall
	
	la $a0, dolar
	syscall

	# rt
	move $a0, $s3
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, espacio
	syscall

	la $a0, dolar
	syscall

	# rs
	move $a0, $s4
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, espacio
	syscall
	
	# Offset
	andi $a0, $s0, 0x0000fff
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, nextLine
	syscall
	
	addi $s6, $s6, 4

	b loop

lw_sw:
	move $a0, $a1
	syscall

	la $a0, espacio
	syscall
	
	la $a0, dolar
	syscall
	
	# rt
	move $a0, $s3
	li $v0, 1
	syscall
	
	la $a0, espacio
	li $v0, 4
	syscall
	
	# Offset
	andi $a0, $s0, 0x0000fff
	li $v0, 1
	syscall
	
	la $a0, parentesis1
	li $v0, 4
	syscall
	
	la $a0, dolar
	syscall
	
	# rs
	move $a0, $s4
	li $v0, 1
	syscall
	
	la $a0, parentesis2
	li $v0, 4
	syscall
	
	la $a0, nextLine
	syscall

	addi $s6, $s6, 4

	b loop
	
salir:	
	la $a0, _R
	syscall

	la $a0, espacio
	syscall
	
	move $a0, $a1
	syscall
	
	li $v0, 10
	syscall
