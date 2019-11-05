###

# Trabalho 2 FAC Implementação do ALgoritmo de Booth

# Aluno: Marcos Vinícius Rodrigues da Conceicao
# Matricula: 170150747

###


###

# Registradores	:

# $s0 = contador do laço
# $s1 = X (multiplicador) 
# $s2 = Y (multiplicando)
# $s3 = Hi --> guarda o resultado em cada passo do algoritmo
# $s4 = Lo --> guarda o valor do overflow do Hi, depois de realizar o desvio pra direita
# $s5 = X-1 --> guarda o valor do menor bit do do multiplicador antes de realizar o desvio pra direita
# $s6 = N --> bit extra a esquerda no caso do multiplicando ser o maior número negativo. -2147483648

###

.data

multiplicando:			.asciiz "\nEntre com o valor do multiplicando : "
multiplicador:			.asciiz "\nEntre com o valor do multiplicador : "
mostra_resultado_Hi:		.asciiz "\nHI : "
mostra_resultado_Lo:		.asciiz "\nLOW : "
mostra_resultado:		.asciiz "\nO resultado é : "

.text

main:
	# inicializando os contadores = 0, Hi=0, Lo=0, X-1=0, N=0

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

loop_start:

	# verificação do contador de loops
	beq  $s0, 33, exit

	andi 		$t0, $s1, 1		                # $t0 = bit menos significativo de X
	beq  		$t0, $zero, x_lsb_0	            # se ($t0 == 0) então vai pra x_lsb_0
	j    		x_lsb_1			                # se ($t1 == 1) então vai pra x_lsb_1

x_lsb_0: 				                        # quando o valor do bit menos significativo for igual a zero X = 0
	beq  		$s5, $zero, case_00	            # se (X-1 == 0) vai pra case_00
	j    		case_01			                # se (X-1 == 1) então vai pra case_01

x_lsb_1:				                        # quando o valor do bit menos significativo for igual a um X = 1
	beq  		$s5, $zero, case_10	            # se (X-1 == 0) então vai pro case_10
	j    		case_11			                # se (X-1 == 1) então vai pro case_11

case_00:
	andi 		$t0, $s3, 1		                # bit menos significativo de Hi pra verificar overflow
	bne  		$t0, $zero, Lo	            	# se o bit menos siginificativo do Lo é 1 vai pro Lo e Hi tem um overflow
	srl  		$s4, $s4, 1		                # desvio de 1 bit pra direita no Lo
	j    		shift			                # shift

case_01:
	# verificador pro maior número negativo

	beq  		$s2, -2147483648, do_special_add

	# realiza a soma e o desvio pra direita
	add 		$s3, $s3, $s2					# soma Y pro Hi
	andi 		$s5, $s5, 0		    			# X=0, pra na próxima vez X-1=0
	andi 		$t0, $s3, 1		    			# checo se ouve overflow no menor bit significativo do Hi
	bne  		$t0, $zero, Lo					# se o bit menos siginificativo do Hi é 1 vai pro Lo e Hi tem um overflow
	srl  		$s4, $s4, 1		    			# desvio a direita do Lo de 1-bit
	j    		shift			    			# shift

case_10:
	# verificador pro maior número negativo
	beq  		$s2, -2147483648, do_special_sub

	# realiza a subtração e o shift
	sub  		$s3, $s3, $s2			# subtracao Y de Hi
	ori  		$s5, $s5, 1				# X=1, pra na proxima vez X-1=1
	andi 		$t0, $s3, 1				# checo se ouve overflow no menor bit significativo do Hi
	bne  		$t0, $zero, Lo			# se o bit menos siginificativo do Hi é 1 vai pro Lo e Hi tem um overflow
	srl  		$s4, $s4, 1				# desvio a direita do Lo de 1-bit
	j    		shift					# shift

case_11:
	andi 		$t0, $s3, 1				# menor bit significativo de Hi pra verificar overflow
	bne  		$t0, $zero, Lo			# se o menor bit significativo de Hi é == 1, atualizo
	srl  		$s4, $s4, 1				# desvio a direita do Lo de 1-bit
	j    		shift 					# shift

Lo:
	andi 		$t0, $s4, 0x80000000	# qual o valor do bit mais significativo do Lo?
	bne  		$t0, $zero, Lo_msb_1	# se o valor do bit mais significativo do Lo == 1, vai pra Lo_msb_1
	srl  		$s4, $s4, 1				# se o valor do bit mais significativo do Lo == 0, desvio a direita do Lo de 1-bit
	ori  		$s4, $s4, 0x80000000	# então o valor do bit mais significativo do Lo = 1
	j    		shift					# shift

Lo_msb_1:
	srl  		$s4, $s4, 1				# desvio à direita do Lo de 1-bit
	ori  		$s4, $s4, 0x80000000	# valor mais significativo de Lo = 1
	j    		shift					# shift

shift:
	sra  		$s3, $s3, 1		   		# desvio à direita do Hi de 1-bit
	ror  		$s1, $s1, 1		   		# rotacao à direita de X de 1-bit
	addi 		$s0, $s0, 1		   		# decrementa contador de loop
	beq  		$s0, 32, save			# se for o ultimo passo salva o valor dos registradores para o resultado
	j    		loop_start				# recomeca o loop

save:
	add  		$t1, $zero, $s3		    # salva Hi no $t1
	add  		$t2, $zero, $s4		    # salva Lo no $t2
	j    		loop_start			    # recomeca o loop	

do_special_sub:				            # para ignorar o overflow no Hi adicionando a variavel N como bit mais significativo de Hi
	subu 		$s3, $s3, $s2		    # subtração Y de Hi
	andi 		$s6, $s6, 0		        # set N=0
	ori  		$s5, $s5, 1		        # X=1, e no proximo loop X-1=1
	andi 		$t0, $s3, 1		        # pega o bit menos significativo do Hi pra verificar se houve overflow
	bne  		$t0, $zero, Lo		    # se o bit menos siginificativo do Hi é 1 vai pro Lo e Hi tem um overflow
	srl  		$s4, $s4, 1		        # desvio à direita do Lo de 1-bit
	j    		shift_special		    # vai pra shift_special, e verificamos se o valor de N para atualizar Hi

do_special_add:				            # para ignorar o overflow no Hi adicionando a variavel N como bit mais significativo de Hi
	addu 		$s3, $s3, $s2	    	# soma Y em Hi
	ori  		$s6, $s6, 1		        # set N=1
	andi 		$s5, $s5, 0		        # X=0, so next time X-1=0
	andi 		$t0, $s3, 1		        # pega o bit menos significativo do Hi pra verificar se houve overflow
	bne  		$t0, $zero, Lo		    # se o bit menos siginificativo do Hi é 1 vai pro Lo e Hi tem um overflow
	srl  		$s4, $s4, 1		        # desvio à direita do Lo de 1-bit
	j    		shift_special		    # vai pra shift_special, e verificamos o valor de N para atualizar Hi
	
	
shift_special:
	beq  		$s6, $zero, n_0	    	# se (N==0) então vai pra n_0
	sra  		$s3, $s3, 1		    	# desvio à direita do Hi de 1-bit
	ror  		$s1, $s1, 1		    	# rotacao a direita de X de 1-bit
	addi 		$s0, $s0, 1		    	# contador do loop -1
	beq  		$s0, 32, save			# se for o ultimo passo salva o valor dos registradores para o resultado
	j    		loop_start				# recomeca o loop

n_0:
	srl  		$s3, $s3, 1		    	# desvio pra direita de 1 bit no Hi, porque o N=0
	ror  		$s1, $s1, 1		    	# rotacao a direita de X de 1-bit
	addi 		$s0, $s0, 1		    	# decrementa o contador do loop
	beq  		$s0, 32, save			# se for o ultimo passo salva o valor dos registradores para o resultado
	j    		loop_start				# recomeca o loop

exit:	
	# Chama Hi
	li   		$v0, 4
	la   		$a0, mostra_resultado_Hi
	syscall
	
	li   		$v0, 35
	add  		$a0, $zero, $t1
	syscall
	
	# Chama Lo
	li   		$v0, 4
	la   		$a0, mostra_resultado_Lo
	syscall
	
	li   		$v0, 35
	add  		$a0, $zero, $t2
	syscall

	# Mostra o resultado
	li   		$v0, 4
	la   		$a0, mostra_resultado
	syscall
	
	li   		$v0, 35
	add  		$a0, $zero, $t1
	syscall
	
	li   		$v0, 35
	add  		$a0, $zero, $t2
	syscall
	
	# Sai
	li   		$v0, 10
	syscall