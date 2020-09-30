.data
	spatiu: .byte ' ' 							# Caracterul ' '
	n: .word 8									# Lungimea vectorului
	v: .word 4, 3, 5, 1, 7, 9, 0, -3 			# Vectorul
	# Pentru exemplul de aici va afisa ->  14 5 30 0 91 204 0 0 
.text

# Voi salva in $t0 lungimea vectorului si in $t1 adresa primului element

main:

	lw $t0, n									# Initializarea lungimii vectorului
	subu $sp, $sp, 4							# Alocam memorie in stack
	sw $t0, 0($sp)								# Si salvam lungimea
	la $t1, v									# Incarcam in $t1 adresa vectorului si o salvam pe stack
	subu $sp, $sp, 4
	sw $t1, 0($sp)								# $sp:(*v, n)
	
	jal modifica								# Apelam procedura
	addu $sp, $sp, 8
	
	lb $t5, spatiu								# Pun in $t5 caracterul ' '
	li $t7, 0									# Folosesc $t7 pentru a parcurge vectorul word cu word
	afisare:
		beqz $t0 exit_afisare					# Cum $t0 retine lungimea vectorului, nu trebuie sa declaram alta variabila pentru a face parcurgerea
		lw $t6, v($t7)							# ci doar sa scadem lungimea cu 1 de fiecare data cand afisam un element, pana cand aceasta va fi 0
		move $a0, $t6
		li $v0, 1
		syscall
		addi $t7, $t7, 4						# Ma mut din 4 in 4 pozitii
		subi $t0, $t0, 1						# 'i++'
		move $a0, $t5
		li $v0, 11
		syscall
		j afisare
	exit_afisare:
	li $v0, 10									# Iesirea din program
	syscall


suma_patrate:
	subu $sp, $sp, 4							# Aloc spatiu pentru a salva frame pointerul
	sw $fp, 0($sp)								# Il salvez pe stiva
	addi $fp, $sp, 4							# Dau adresa din memorie
	subu $sp, $sp, 4							# Aloc spatiu pe stiva
	sw $ra, 0($sp)								# Salvez si adresa registrului $ra deoarece este o functie recursiva
	subu $sp, $sp, 4
	sw $s0, 0($sp)								# Salvez valoarea initiala a lui $s0
	lw $s0, 0($fp)

	ble $s0, 1 exit_suma_patrate				# Conditia de iesire, daca $s0 <= 1
	
	addi $s0, $s0, -1							# Scadem 1 din $s0 pentru a trece mai departe in procedura si in recursivitate
	
	move $t4, $s0								# Pun in registrul $t4, $s0
	mul $t5, $t4, $t4							# $t5 = $t4 * $t4 = patratul lui n - 1
	add $v0, $v0, $t5
	
	subu $sp, $sp, 4
    sw $s0, 0($sp)								# Salvez pe stack
	
	jal suma_patrate							# Apelez recursiv procedura
	addu $sp, $sp, 4
	
	exit_suma_patrate:
	lw $s0, -12($fp)							# Restaurez valorile initiale
	lw $ra, -8($fp)
	lw $fp, -4($fp)
	addu $sp, $sp, 12							# Sterg valorile de pe stack
	jr $ra										# Iesire din nivel/procedura
	

modifica:
	subu $sp, $sp, 4							# Aloc spatiu pentru a salva frame pointerul
	sw $fp, 0($sp)								# Il salvez pe stiva
	addi $fp, $sp, 4							# Dau adresa din memorie
	subu $sp, $sp, 4							# Aloc spatiu pe stiva
	sw $ra, 0($sp)								# Salvez adresa $ra
	subu $sp, $sp, 4
	sw $s1, 0($sp)								# Salvez valoarea initiala a lui $s1 (lungimea vectorului)
	subu $sp, $sp, 4
	sw $s0, 0($sp)								# Salvez valoarea initiala a lui $s0 (adresa lui)
	
	lw $s0, 0($fp)
	lw $s1, 4($fp)
	
	ble $s1, 0 exit_modifica					# Conditia de iesire, daca $s1 <= 0 (n == 0)
	
	subu $sp, $sp, 4							# Aloc memorie
	lw $s3, 0($s0)								# Salvam in $s3 *valoarea* de pe adresa salvata in $s0
	sw $s3, 0($sp)								# Salvez pe stack valoarea lui $s3 (v[i]) pentru a putea apela cealalta procedura
	jal suma_patrate							# Apelez procedura 
	addu $sp, $sp, 4
	li $s3, 0									# Restauram $s3
	
	sw $v0, 0($s0)								# Salvam ce a returnat functia si overwrite valoarea de pe pozitia corespunzatoare din vector
	li $v0, 0
	
	addi $s0, $s0, 4							# Mergem din word in word pe adrese
	subi $s1, $s1, 1							# n--
	
	subu $sp, $sp, 4
	sw $s1, 0($sp)								# Salvez valoarea initiala a lui $s1 (lungimea vectorului)
	subu $sp, $sp, 4
	sw $s0, 0($sp)								# Salvez valoarea initiala a lui $s0 (adresa lui)
	
	jal modifica								# Continuam recursia
	addu $sp, $sp, 8
	
	exit_modifica:
	lw $s0, -16($fp)
	lw $s1, -12($fp)							# Restaurez valorile initiale
	lw $ra, -8($fp)
	lw $fp, -4($fp)
	addu $sp, $sp, 16							# Sterg valorile de pe stack
	jr $ra										# Iesire din nivel/procedura
