;ALGORITMO DE DETECCION DE IMAGENES DE PREWITT
;---------------------------------------------
;PROTOTIPO: void asmPrewitt(const char* src, char* dst, int ancho, int alto);

global asmPrewitt
%define SRC [EBP+8]	;donde empieza la matriz de la imagen original
%define DST [EBP+12]	;donde empieza la matriz de los datos a guardar
%define WIDTH [EBP+16]	;el ancho de la imagen
%define HEIGHT [EBP+20]	;el alto de la imagen
%define WIDTHSTEP [EBP-4];variable local donde se almacena el valor temporal

%macro saturar 0
	xor ebx, ebx
	cmp eax, 0
	cmovl eax, ebx
	mov ebx, 255
	cmp eax, 255
	cmovg eax,ebx
%endmacro

section .text

section .data
asmPrewitt:  ;funcion a la que se llama
	;hacemos los push basicos
	push ebp
	mov ebp, esp
	sub esp, 4
	push esi
	push edi
	push ebx
	
	dec DWORD WIDTH	;hacemos que recorra hasta WIDHT-1
	;rutina para calcualr WISTHSTEP
	mov eax, WIDTH
	test eax, 2
	je comenzarRutina
	shr eax, 2
	inc eax
	shl eax, 2
	mov DWORD WIDTHSTEP, eax

comenzarRutina:
	xor ecx, ecx	;fila actual
	inc ecx		;para q salga una fila antes
	mov esi, SRC	;pos fila actual src
	mov edi, DST	;pos fila dst

;recordemos q esi+edx es la posicion a22 de la matriz actual (el centro)
cicloF:
	xor edx, edx ;columna actual
	push ecx		;ACA VAMOS A HACER UNA MARAVILLA, ECX NO ACCEDE A MEMORIA EEEE
	mov ecx, WIDTHSTEP
	cicloC:
		mascaraX:
			xor eax, eax		;eax es el valor q queda
			;aca esi esta en la posicion 1 de la fila actual
			;vamos a ir cambiando esi y edx pero al final va a estar en elmismo lugar (invariante (?))
			sub esi, ecx

			dec edx			;esi+edx=a11
			xor ebx, ebx
			mov bl, [esi+edx]
			sub eax, ebx		;eax = -a11

			add esi, ecx		;esi+edx=a31
			xor ebx, ebx
			mov bl, [esi+edx]
			sub eax, ebx		;eax = -a11-a21

			add esi, ecx		;esi+edx=a31
			xor ebx, ebx
			mov bl, [esi+edx]
			sub eax, ebx		;eax= -a11-a21-a31

			add edx, 2		;esi+edx=a33
			xor ebx, ebx
			mov bl, [esi+edx]
			add eax, ebx		;eax+= a33

			sub esi, ecx		;esi+edx=a23
			xor ebx, ebx
			mov bl, [esi+edx]
			add eax, ebx		;eax+= a23

			sub esi, ecx		;esi+edx=a13
			xor ebx, ebx
			mov bl, [esi+edx]
			add eax, ebx		;eax+= a13
			saturar
			;volvemos el invariante
			add esi, ecx
			dec edx

		;ahora hay q poner en SRC[a11] a al
		mov [edi+edx], al

		inc edx
		cmp edx, WIDTH
		jne cicloC
	;aca sigue cilcoF
	add esi, ecx 
	add edi, ecx
	pop ecx
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
