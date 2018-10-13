.data
message: .asciiz "Bienvenido "
is_prime_message: .asciiz "El número es primo"
is_not_prime_message: .asciiz "El número NO es primo"

.text
main:
	li	$v0, 5					# Entero para leer un entero
	syscall						# Llamada al sistema para leer el entero
	add	$t5, $zero, $v0				# Guarda el numero en t5
	
	addi	$t0, $zero, 2				# int x = 2
	
is_prime_test:
	slt	$t1, $t0, $t5					
	bne	$t1, $zero, is_prime_loop		# if (x > num)
	addi	$v0, $zero, 1				# El numero es primo!!
	b return					# y en $v0 almacena 1 

is_prime_loop:						# else
	div	$t5, $t0					
	mfhi	$t3					# c = (num % x)
	slti	$t4, $t3, 1				
	beq	$t4, $zero, is_prime_loop_cont		# if (c == 0)
	add	$v0, $zero, $zero			# 
	b 	return					# en $v0 almacena  0 si
							# el numero no es primo
is_prime_loop_cont:		
	addi 	$t0, $t0, 1				# x++
	j	is_prime_test				# continua verificando si  
							# es primo o no

return:
	bne	$zero, $v0, is_prime_result		# if (0 != v0) (v0 almacena 1 si el numero es primo
	la	$a0, is_not_prime_message		# guarda la direccion del mensaje
	b	result
	
is_prime_result:
	la	$a0, is_prime_message			# guarda la direccion del mensaje

result:
							# Escribe el resultado en la 
	li	$v0, 4					# salida estandar
	syscall						# 1 para numero primo
							# 0 para no primo
	

	li	$v0, 10					# Finaliza la ejecucion
	syscall