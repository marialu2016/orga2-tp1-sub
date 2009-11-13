;ALGORITMO DE DETECCION DE IMAGENES DE ROBERTS
;---------------------------------------------
;PROTOTIPO: void asmRoberts(const char* src, char* dst, int ancho, int alto);
;IDEA DEL ALGORITMO
;----------------------------------------
;CALCULAMOS EL ANCHO REAL DE LA IMAGEN
;QUE ES BASICAMENTE EL PRIMER MULTIPLO DE 4 DEL ANCHO DADO.
;EMPEZAMOS A RECORRER AMBAS MATRICES A LA VES
;TENEMOS EN UN REGISTRO LA POSICION 1 DE LA FILA ACTUAL, DE CADA MATRIZ
;EN OTRO LA COLUMA ACTUAL, DE TAL FORMA QUE LA
;POSICION ACTUAL ES POS1FILA+COLUMA
;VAMOS RECORRIENDO CON DOS BUCLES ANIDADOS PARA PASAR POR TODO
;EL ANCHO Y ALTO DE LA IMAGEN, UNA VEZ QUE SE CACLULA EL VALOR
;LO PONEMOS EN LA IMAGEN NUEVA
;CALCULAMOS LA DERIVADA DE X e Y DENTRO DEL MISMO CICLO
;----------------------------------------
;A TENER EN CUENTA
;----------------------------------------
;LLAMAMOS m11, m12
;	  m21, m22 A CADA PUNTO DE LA MATRIZ
;POR LA CUAL SE CONVOLUCIONA, Y DE LA MISMA 
;FORMA PERO CON a A LA ACTUAL MATRIZ CONVOLUCIONADA
;POR CADA VALOR DE LA MATRIZ GUARDAMOS EL RESULTADO
;EN LA POSICION a11 Y LA MATRIZ SE RECORRE
;HASTA WIDTH-1 Y HEIGHT-1 DEBIDO A QUE EN LAS PUNTAS HA RUIDO

global asmRoberts
%define SRC [EBP+8]	;donde empieza la matriz de la imagen original
%define DST [EBP+12]	;donde empieza la matriz de los datos a guardar
%define WIDTH [EBP+16]	;el ancho de la imagen
%define HEIGHT [EBP+20]	;el alto de la imagen
%define WIDTHSTEP [EBP-4];variable local donde se almacena el WIDTHSTEP

%macro saturar 0	;satura el numero acutal almacenado en eax
	xor ebx, ebx
	cmp eax, 0
	cmovl eax, ebx ;si eax<0 entoces pone 0
	mov ebx, 255
	cmp eax, 255
	cmovg eax,ebx	;si eax>255 entoces pone 255
%endmacro

section .text

section .data
asmRoberts:
	;hacemos los push basicos
	push ebp
	mov ebp, esp
	sub esp, 4	;variable local para el WIDTHSTEP
	push esi
	push edi
	push ebx
	
	;rutina para calcualr WISTHSTEP
	mov eax, WIDTH
	test eax, 2
	je iniWithS
	shr eax, 2
	inc eax
	shl eax, 2
	mov DWORD WIDTHSTEP, eax
	jmp comenzarRutina
iniWithS:
	mov WIDTHSTEP, eax


comenzarRutina:
	dec DWORD WIDTH	;hacemos que recorra hasta WIDHT-1
	xor ecx, ecx	;el acumulador de la fila
	inc ecx		;se pone en 1 para q salga una fila antes
	mov esi, SRC	;posicion 1 de la fila 1 de la imagen src
	mov edi, DST	;posicion 1 de la fila 1 de la imagen dst
	
cicloF:
	xor edx, edx ;acumulador de columna
	
	push ecx		;como a ecx la usamos solo al final de los bucles
	mov ecx, WIDTHSTEP	;podemos poner ahi el WIDTHSTEP y ahorrarnos varios
				;accesos a memoria
	
	cicloC:
		mascaraX:
			xor eax, eax		;eax es el valor q queda
			;aca esi esta en la posicion 1 de la fila actual
			mov al, [esi+edx]	;al = a11

			add esi, ecx
			inc edx			;esi+edx=a22
	
			xor ebx, ebx		;reg auxiliar para cuantas
			mov bl, [esi+edx]	;bl = a22
			sub eax, ebx		;eax=a11-a22i
			saturar
			sub esi, ecx		;esi+edx=a12

		mov [edi+edx-1], al		;guardamos en el dst el valor de eax
						;ahi queda guardada la derivada en x

		mascaraY:
			xor eax, eax		;eax=0
			mov al, [esi+edx]	;eax = a12

			add esi, ecx
			dec edx			;edi+edx=a21

			xor ebx, ebx
			mov bl, [esi+edx]

			sub eax, ebx	;eax = a21-a12
			saturar
			sub esi, ecx	;esi = fila en la que entro y edx en la col necesaria (a11)

		;aca hacemos la suma entre ambas mascaras
		xor ebx, ebx
		mov bl, [edi+edx]
		add eax, ebx	;eax=mascY + mascX
		saturar	
		mov [edi+edx], al

		inc edx
		cmp edx, WIDTH
		jne cicloC
	;aca sigue cilcoF
	add esi, ecx	;esi=primera posicion de la siguiente fila del src
	add edi, ecx	;edi=primera posicion de la siguiente fila del dst
	pop ecx		;ecx=numero de fila actual

	inc ecx
	cmp ecx, HEIGHT
	jne cicloF

fin:
	;hacemos los pop basicos
	pop ebx
	pop edi
	pop esi
	add esp, 4
	pop ebp
	ret ;vovlemos

