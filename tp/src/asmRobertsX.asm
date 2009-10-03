;ALGORITMO DE DETECCION DE IMAGENES DE ROBERTS
;---------------------------------------------
;PROTOTIPO: void asmRoberts(const char* src, char* dst, int ancho, int alto);
;PARA REFERENCIA EN LOS COMENTARIOS TENEMOS LA MASCARA
;m11|m12
;m21|m22
;Y LLAMAMOD DE IGAUL MANERA PERO CON a
;A LOS ELEMTOS DE LA IMAGEN
;---------------------------------------------
;para obtener el elemento Aij = j+i*width
;no se devuelve nada asi que podemos usar
;todos los registros: EAX, EBX, ECX, EDX, ESI, EDI

global asmRoberts
%define SRC [EBP+8]	;donde empieza la matriz de la imagen original
%define DST [EBP+12]	;donde empieza la matriz de los datos a guardar
%define WIDTH [EBP+16]	;el ancho de la imagen
%define HEIGHT [EBP+20]	;el alto de la imagen
%define VAL [EBP-4]	;variable local donde se almacena el valor temporal
%define WIDTHSTEP WIDTH

section .text

section .data
asmRoberts:  ;funcion a la que se llama
	;hacemos los push basicos
	push ebp
	mov ebp, esp
	sub esp, 4
	push esi
	push edi
	push ebx
	
	dec DWORD WIDTH	;hacemos que recorra hasta WIDHT-1

	xor ecx, ecx	;fila actual
	inc ecx		;para q salga una fila antes
	mov esi, SRC	;pos fila actual src
	mov edi, DST	;pos fila dst
	
cicloF:
	xor edx, edx ;columna actual
	cicloC:
		mascaraX:
			xor eax, eax		;eax es el valor q queda
			;aca esi esta en la posicion 1 de la fila actual
			mov al, [esi+edx]	;al = a11

			add esi, WIDTHSTEP	;esi = pos de (fila acutal+1)
			inc edx
	
			xor ebx, ebx
			mov bl, [esi+edx]	;bl = a22

			sub eax, ebx		;eax=a11-a22
			jl pasarA0
		sigue1: cmp eax, 255
			jg pasarA255
		sigue2:
			sub esi, WIDTHSTEP
		;ahora hay q poner en SRC[a11] a al
		mov [edi+edx-1], al
		cmp edx, WIDTH
		jne cicloC
	;aca sigue cilcoF
	add esi, WIDTHSTEP
	add edi, WIDTHSTEP
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

pasarA0:
	mov eax,0
	jmp sigue1
pasarA255:
	mov eax, 255
	jmp sigue2
