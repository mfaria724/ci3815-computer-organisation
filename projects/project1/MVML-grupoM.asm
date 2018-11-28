# Juan Oropeza 15-11041
# Manuel Oropeza 15-10463

.data

################# File reader ###############

# Prints message to user.
user: .asciiz "Introduzca el nombre del archivo:\n"
# Saves file's name
file: .space 12
# Buffer to read line
buffer: .space 9

.align 2 # Align to words.
# Program translated.
programa: .space 400

################# Translator ###############

# Array of operations
operaciones: .space 1024
# Array of types of operations
tipos: .space 1024

# Asciiz used for output

error: .asciiz "\n Formato de archivo incorrecto."
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

################# Resgistries Planification ###############
# $v0 --> Syscall codes
# $a0 --> Load addresses, registers and offset
# $a1 --> Syscalls parameters, iterator, buffer address, and address to operation string
# $t0 --> Load bytes, and addresses of operations and types arrays
# $a2 --> Syscall parameters, buffer address, and type of operation
# $s0 --> Load the current line of the program
# $s1 --> Load the address of the operations array
# $s2 --> Load the address of the operation types array
# $s3 --> Load the value of rt
# $s4 --> Load the value of rs
# $s5 --> Load the value of rd
# $s6 --> Temporal file descriptor saver, Load address of programa array to iterate over it
# $t6 --> Program pointer
# $t4 --> Iterator

.text

################# File reader ###############

	# Prints message to user
	li $v0, 4 	   # Syscall to read string from user.
	la $a0, user	   # Addres were string will be loaded.
	syscall

	# Read file name
	li $v0, 8 	   # Syscall to read string from user.
	la $a0, file	   # Addres were string will be loaded.
	li $a1, 19	   # Maximun number of characters.
	syscall
	
	# Quits next line caracter at the end of the file name.
	li   $a1, 0 # Initialize iterator
	lb   $t0, 0($a0) # Loads first byte.
	lb   $t1, nextLine # Loads breakpoint
loop1:	beq  $t0, $t1, cont1 # while (byte != breakpoint)

	lb   $t0, 1($a0) # Loads next byte.
	la   $a0, 1($a0) # Increments direction
	b    loop1 # Loop
	
cont1:	# Breaks loop
	# Quits next line caracter
	sb   $zero, 0($a0)

	# Opens file
	li $v0, 13 # Syscall code
	la $a0, file # File name
	li $a1, 0 # Flags: Only for read
	li $a2, 0 # Maximun number of characters to be read.
	syscall
	
	move $s6, $v0 # Saves pointer to file.
	
	
	la   $t6, programa # Loads address to store program.
loop2: 	beq  $v0, $zero, cont2 # while ($v0 != null)
	
	# Reads file line.
	li   $v0, 14
	move $a0, $s6
	la   $a1, buffer # Saves it to buffer.
	li   $a2, 9 # Number of characters.
	syscall
	
	# Quits new line character at the end of the line.
	sb   $zero, 8($a1)
	
	
	li   $t4, 0 # Initialize iterator
	la   $a2, buffer # Loads buffer address.
	
loop3:  bge  $t4, 8, cont3 # while (iterator >= 8)
	
	sll  $t5, $t5, 4 # Prepares pending line to be used.
	lb   $t0, 0($a2) # First character
	lb   $t3, 1($a2) # Second character
	
	bge  $t0, 0x60, let1 # if (Character1 > 0x60)
	# Number case
	andi $t0, 0x0f # Mask to get number
	b num1
	
	# Letter case
let1:	addi $t0, $t0, 9 # Adds 9 to get letter in first position.
	andi $t0, $t0, 0x0f # Mask to get only first letter.
num1:
	add  $t5, $t0, $t5 # Adds number to line container

	la   $a2, 1($a2) # Moves address to next character.
	addi $t4, $t4, 1 # Increments iterator
	b    loop3 
	
cont3: 

	sw   $t5, 0($t6) # Saves line in memory program.
	la   $t6, 4($t6) # Increments program pointer.
	
	b loop2
cont2:  
	# Close the file 
  	li   $v0, 16       # system call for close file
  	move $a0, $s6      # file descriptor to close
  	syscall            # close file
  
# Stores operations in the corresponding index in programa array

	la $t0, operaciones	# Load address of the array to store operations

	la $t1, _add		# Load address of the operation asciiz 
	sw $t1, 128($t0)	# Store then in the corresponding index of the array

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

# Stores types of operation, 0 for R, 1 por I (without lw neither sw), 2 for lw and sw, and -1 for halt

	la $t0, tipos		# Load address of the array to store types

	li $t1, 0 		# Load in $t1 0 to store it in the corresponding indexes

	sw $t1, 128($t0)
	sw $t1, 160($t0)
	sw $t1, 96($t0)
	sw $t1, 148($t0)
	sw $t1, 16($t0)
	sw $t1, 136($t0)

	li $t1, 1		# Load in $t1 1 to store it in the corresponding indexes

	sw $t1, 32($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)

	li $t1, 2		# Load in $t1 2 to store it in the corresponding indexes
	
	sw $t1, 140($t0)
	sw $t1, 172($t0)


	li $t1, -1		# Load in $t1 -1 to store it in the corresponding indexes
	sw $t1, ($t0)
	
#############################################################################################################################

	la $s6, programa	# Load the address of array programa to iterate over it
	la $s1, operaciones	# Load the address of array operaciones to use them
	la $s2, tipos		# Load the address of array tipos to use them to know what type of operation is each one

# Iteracion

loop:	lw $s0, ($s6)		# Load the current line that is going to be read
	
# Operacion
	li $v0, 34		# Syscall to print hexadecimal
	move $a0, $s0		# Load the line that is going to be read
	syscall

	li $v0, 4		# Syscall to print string
	la $a0, espacio		# Load space string
	syscall

	andi $a1, $s0, 0xfc000000	# Turn off the bits that aren't needed to read the operation code
	srl $a1, $a1, 24		# Shift right of 24 to take the operation code by 4

	add $a2, $a1, $s2		# Add address of tipos array plus the operation code by 4 to have the position of the operation type in the array
	add $a1, $a1, $s1		# Add address of operaciones array plus the operation code by 4 to have the position of the operation in the array


	lw $a1, 0($a1)		# Load the address of the operation string
	lw $a2, 0($a2)		# Load the type of the operation

	bnez $a1, salto		# Checks there aren't operations with operation code given
	li $v0, 4
	la $a0, error		# Prints error message
	syscall
	
	li $v0, 10		# Close the program
	syscall
	
salto:

# rt
	andi $s3, $s0, 0x001f0000	# Trun off the bits that aren't needed to read the rt
	srl $s3, $s3, 16		# Shift right of 16 bits to take the rt
# rs
	andi $s4, $s0, 0x03e00000	# Trun off the bits that aren't needed to read the rs
	srl $s4, $s4, 21		# Shift right of 21 bits to take the rs
# rd
	andi $s5, $s0, 0x0000f800	# Trun off the bits that aren't needed to read the rd
	srl $s5, $s5, 11		# Shift right of 11 bits to take the rd

	beq $a2, -1, salir		# Checks if the operation given is halt
	bnez $a2, I			# Checks if the operation type is I (1)

R:	la $a0, _R			# Prints R
	syscall

	la $a0, espacio			# Prints space
	syscall

	move $a0, $a1			# Prints operation's string
	syscall

	la $a0, espacio			# Prints space
	syscall
	
	la $a0, dolar			# Prints dollar sign
	syscall
	
	# rd
	move $a0, $s5			# Prints rd
	li $v0, 1			# Syscall to print a integerdecimal integer
	syscall

	li $v0, 4			# Syscall to print strings
	la $a0, espacio			# Prints space
	syscall

	la $a0, dolar			# Prints dollar sign
	syscall
	
	# rs
	move $a0, $s4			# Prints rs
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, espacio			# Prints space
	syscall

	la $a0, dolar			# Prints dollar sign
	syscall
	
	# rt
	move $a0, $s3			# Prints rt
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, nextLine		# Prints \n to make the next print in the next line
	syscall
		
	addi $s6, $s6, 4		# Adds 4 to the address of programa array to continue iterating

	b loop				# Start the next iteration


I:	la $a0, _I			# Prints I
	syscall

	la $a0, espacio			# Prints space
	syscall
	
	beq $a2, 2, lw_sw		# Checks if the operation is lw or sw, (type 2)

	move $a0, $a1			# Prints operation's string
	syscall

	la $a0, espacio			# Prints space
	syscall
	
	la $a0, dolar			# Prints dollar sign
	syscall

	# rt
	move $a0, $s3			# Prints rt
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, espacio			# Prints space
	syscall

	la $a0, dolar			# Prints dollar sign
	syscall

	# rs
	move $a0, $s4			# Prints rs
	li $v0, 1
	syscall

	li $v0, 4
	la $a0, espacio			# Prints space
	syscall
	
	# Offset
	andi $a0, $s0, 0x0000ffff	# Turn off bits that aren't needed to read the offset
	li $v0, 1			# Prints the offset
	syscall

	li $v0, 4
	la $a0, nextLine		# Prints \n to make the next print in the next line
	syscall
	
	addi $s6, $s6, 4		# Adds 4 to the address of programa array to continue iterating

	b loop				# Starts the new iteration

lw_sw:	move $a0, $a1			# Prints operation's string
	syscall

	la $a0, espacio			# Prints space
	syscall
	
	la $a0, dolar			# Prints dolar sign
	syscall
	
	# rt
	move $a0, $s3			# Prints rt
	li $v0, 1
	syscall
	
	la $a0, espacio			# Prints space
	li $v0, 4
	syscall
	
	# Offset
	andi $a0, $s0, 0x0000ffff	# Turn off the bits that aren't needed to read the offset
	li $v0, 1			# Prints the offset
	syscall
	
	la $a0, parentesis1		# Prints (
	li $v0, 4
	syscall
	
	la $a0, dolar			# Prints dollar sign
	syscall
	
	# rs
	move $a0, $s4			# Prints rs
	li $v0, 1
	syscall
	
	la $a0, parentesis2		# Prints )
	li $v0, 4
	syscall
	
	la $a0, nextLine
	syscall

	addi $s6, $s6, 4		# Adds 4 to the address of programa array to continue iterating

	b loop				# Starts the new iteration

	
salir:	la $a0, _R			# Prints R
	syscall

	la $a0, espacio			# Prints Space
	syscall
	
	move $a0, $a1			# Prints operation string, in this case halt
	syscall
	
	li $v0, 10			# Exits the program
	syscall
