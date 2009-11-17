;ALGORITMO DE DETECCION DE BORDES DE SOBEL
;---------------------------------------------
;PROTOTIPO: void asmSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder);
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
;SI Xorder=1 CALUCLA EN X
;SI Yoirder=1 CALCULA EN Y
;SI AMBOS SON 1 CALCULA EN AMBOS Y LO SUMA, SIEMPRE SATURANDO
;----------------------------------------
;A TENER EN CUENTA
;----------------------------------------
;LLAMAMOS m11 m12 m13
;         m21 m22 m23
;         m31 m32 m33 A CADA PUNTO DE LA MATRIZ
;POR LA CUAL SE CONVOLUCIONA, Y DE LA MISMA 
;FORMA PERO CON a A LA ACTUAL MATRIZ CONVOLUCIONADA
;POR CADA VALOR DE LA MATRIZ GUARDAMOS EL RESULTADO
;EN LA POSICION a22 Y LA MATRIZ SE RECORRE DESDE LA COLUMNA
;HASTA WIDTH-1 Y DESDE LA SEGUNDA FILA HASTA
; HEIGHT-1 DEBIDO A QUE EN LAS PUNTAS HAY RUIDO

global asmSobel
%define SRC [EBP+8]	;donde empieza la matriz de la imagen original
%define DST [EBP+12]	;donde empieza la matriz de los datos a guardar
%define WIDTH [EBP+16]	;el ancho de la imagen
%define HEIGHT [EBP+20]	;el alto de la imagen
%define XOrder [EBP+24] ;el XOrder
%define YOrder [EBP+28] ;el YOrder
%define WIDTHSTEP [EBP-4];variable local donde se almacena el WIDTHSTEP

%macro saturar 0	;satura el numero almacenado en eax
	xor ebx, ebx
	cmp eax, 0
	cmovl eax, ebx	;si eax<0 entoces eax=0
	mov ebx, 255
	cmp eax, 255
	cmovg eax,ebx	;si eax>255 entoces eax=255
%endmacro

%macro restaLocal 0		;se repite mucho esto
	xor ebx, ebx		;asi que le hicimos un macro
	mov bl, [esi+edx]	;simplemente hace eax=eax-ebx
	sub eax, ebx
%endmacro

%macro sumaLocal 0		;igual que lo anterior pero
	xor ebx, ebx		;hace eax=eax+ebx
	mov bl, [esi+edx]
	add eax, ebx
%endmacro

section .data
section .text

asmSobel: 
	;hacemos los push basicos
	push ebp
	mov ebp, esp
	sub esp, 4	;variable local que almacena el WIDTHSTEP
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
	dec DWORD HEIGHT;hacemos que recorra hasta HEIGHT-1

	xor ecx, ecx	;el acumulador de la fila
	inc ecx		;se pone en 1 para que salga de la fila uno antes
	mov esi, SRC	;posicion 1 de la fila 1 del SRC
	mov edi, DST	;posicion 1 de la fila 1 de DST

;recordemos q esi+edx es la posicion a22 de la matriz actual (el centro)
cicloF:
	xor edx, edx 		;acumulador de la columna
	inc edx			;empieza en 1 para que salga una columna antes
	push ecx		;como ecx solo se usa al final de los bucles
	mov ecx, WIDTHSTEP	;podemos usarlo como WIDTHSTEP para ahorrar
	cicloC:			;muchos accesos a memoria
		cmp DWORD XOrder, 1
		jne pasarX		;si XOrder!=1 saltea X
		mascaraX:
			xor eax, eax		;eax es el valor q queda

			sub esi, ecx
			dec edx			;esi+edx=&a11
			restaLocal		;eax=-a11

			add esi, ecx		;esi+edx=&a21
			restaLocal		;eax=-a11-a21
			restaLocal		;eax=-a11-2*a21

			add esi, ecx		;esi+edx=&a31
			restaLocal		;eax=-a11-2*a21-a31

			add edx, 2		;esi+edx=&a33
			sumaLocal		;eax=-a11-2*a21-a31+a33

			sub esi, ecx		;esi+edx=&a23
			sumaLocal		;eax=-a11-2*a21-a31+a33+a32
			sumaLocal		;eax=-a11-2*a21-a31+a33+2*a32

			sub esi, ecx		;esi+edx=&a13
			sumaLocal		;eax=-a11-2*a21-a31+a33+2*a32+a31

			saturar

			add esi, ecx
			dec edx			;esi+edx=&a22
			mov[edi+edx], al	;lo muevo al dest saturado
		pasarX:
			cmp DWORD YOrder, 1
			jne pY			;si Yorder!=1 lo saltea
			jmp mascaraY		;esta hehco asi xq sino tiraba
			pY: jmp pasarY		;que la etiqueta estaba lejos
		mascaraY:
			xor eax, eax		;el valor a guardar

			sub esi, ecx 
			dec edx  	;esi+edx = &a11
			restaLocal	;eax=-a11
			
			inc edx		;edx+esi = &a12
			restaLocal	;eax=-a11-a12
			restaLocal	;eax=-a11-2*a12
			
			inc edx		;esi+edx=&a13
			restaLocal	;eax=-a11-2*a12-a13

			add esi, ecx
			add esi, ecx	;esi+eax=&a33
			sumaLocal	;eax=-a11-2*a12-a13+a33
		
			dec edx		;esi+eax=&a32
			sumaLocal	;eax=-a11-2*a12-a13+a33+a32
			sumaLocal	;eax=-a11-2*a12-a13+a33+2*a32
			
			dec edx		;esi+eax=&a31
			sumaLocal	;eax=-a11-2*a12-a13+a33+2*a32+a31

			saturar		;saturo eax, maskY

			sub esi, ecx	
			inc edx		;esi+edx = &a22

			xor ebx, ebx
			mov bl, [edi+edx] ;maskX en el bl

			add eax,ebx	;sumo mascaras
			saturar		;saturo

			mov [edi+edx],al ;guardamos el valor final aca
		pasarY:

		inc edx
		cmp edx, WIDTH
		jne cicloC

	;aca sigue cicloF
	add esi, ecx 	;primera posicion de la fila siguiente del src
	add edi, ecx	;primera posicion de la fila siguiente del dst
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

