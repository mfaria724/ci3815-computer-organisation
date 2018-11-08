.data
programa: .word 0x80a45000, 0x3464000a, 0x00000000
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


.text
# Almaceno las operaciones en el puesto correspondiente a su codigo de operacion
la $t0, operaciones

la $t1, _add
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

lw $a1, ($a1)
lw $a2, ($a2)

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
