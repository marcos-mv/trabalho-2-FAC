###

Trabalho 2 FAC Implementação do ALgoritmo de Booth

Aluno: Marcos Vinícius Rodrigues da Conceicao
Matricula: 170150747

###


###

# Registradores	:
# -----------------------
# $s0 = contador do laço
# $s1 = X (multiplicador) 
# $s2 = Y (multiplicando)
# $s3 = U --> guarda o resultado em cada passo do algoritmo
# $s4 = V --> guarda o valor do overflow do U, depois de realizar o desvio pra direita
# $s5 = X-1 --> guarda o valor do menor bit do do multiplicador antes de realizar o desvio pra direita
# $s6 = N --> bit extar a esquerda no caso do multiplicando ser o maior número negativo. -2147483648
#
###

.data	
multiplicando:		.asciiz "\nEntre com o valor do multiplicando : "
multiplicador:		.asciiz "\nEntre com o valor do multiplicador : "
mostra_resultado:	.asciiz "O resultado é : "

.text

main:
	# inicializando os contadores = 0, U=0, V=0, X-1=0, N=0

	addi 		$s0, $zero, 0
	addi 		$s3, $zero, 0
	addi 		$s4, $zero, 0
	addi 		$s5, $zero, 0
	addi 		$s6, $zero, 0

	# pergunta pelo multiplicador

	li   		$v0, 4
	la   		$a0, multiplicador
	syscall

	# coloca o valor no $s1
	li   		$v0, 5
	syscall
	add  		$s1, $zero, $v0

	# pergunta pelo multiplicando
	li   		$v0, 4
	la   		$a0, multiplicando
	syscall

	# coloca o valor no $s2
	li   		$v0, 5
	syscall
	add  		$s2, $zero, $v0

exit:

	# Mostra o resultado
	li   		$v0, 4
	la   		$a0, mostra_resultado
	syscall
	
	# Chama U
	li   		$v0, 35
	add  		$a0, $zero, $t1
	syscall

	# Chama V
	li   		$v0, 35
	add  		$a0, $zero, $t2
	syscall
	
	# Sai
	li   		$v0, 10
	syscall
