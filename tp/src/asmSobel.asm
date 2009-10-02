;ALGORITMO DE DETECCION DE BORDES DE SOBEL
;---------------------------------------------
;PROTOTIPO: void asmSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder);
;PARA REFERENCIA EN LOS COMENTARIOS TENEMOS LA MASCARA
;m11|m12
;m21|m22
;Y LLAMAMOD DE IGAUL MANERA PERO CON a
;A LOS ELEMTOS DE LA IMAGEN
;---------------------------------------------
;para obtener el elemento Aij = j+i*width
;no se devuelve nada asi que podemos usar
;todos los registros: EAX, EBX, ECX, EDX, ESI, EDI

global asmSobel
%define SRC [EBP+8]	;donde empieza la matriz de la imagen original
%define DST [EBP+12]	;donde empieza la matriz de los datos a guardar
%define WIDTH [EBP+16]	;el ancho de la imagen
%define HEIGHT [EBP+20]	;el alto de la imagen

section .text

section .data
asmSobel:  ;funcion a la que se llama
	;hacemos los push basicos
	push ebp
	mov ebp, esp
	push esi
	push edi
	push ebx
	
	;aca empieza la posta
	;usamos ecx como contador de fila y ebx como contador de columnas
	;entotonces Aij = A(ecx)(ebx) = a[ebx + ecx*width]
	xor ecx, ecx	;fila = 0
	;xor ebx, ebx	;col = 0 

cicloF:
	xor ebx, ebx	;col = 0
	cicloC:
		;NO PODEMOS ACCEDER DIRECTO A Aij, necesitamos hacer DST+EBX+ECX*WIDTH
		;la multiplicacion se guarda implicitamente en eax, trabajamos segun eso
		;supongo q la multiplicacion entra en eax????? preguntar IMPORTANTE IMPORTANTE

		mov eax, ecx	;eax=fila
		mul DWORD WIDTH	;eax=fila*widht
		add eax, SRC	;eax = DST + WIDTH*FILA = POS FILA BIEN
		add eax, ebx	;eax=a11
		xor esi, esi	;esi va a ser el valor a poner
		mov esi, [eax]	;esi = (m11*a11)

		add eax, WIDTH	;eax=a21
		inc eax		;eax=a22
		sub esi, [eax]	;esi=a11-a22
		jns ponerPositivo  ;hacer modulo... 

	cont:
		mov eax, ecx
		mul DWORD WIDTH
		add eax, DST
		add eax, ebx

		mov [eax], esi
		
		;vemos si se repite el clicl
		inc ebx ;columna++
		cmp ebx, WIDTH	;ver si queda algun 
		jl cicloC	;hago el recorro la columna mientras este en rango

	inc ecx	;fila++
	cmp ecx, HEIGHT
	jl cicloF	;hago el recorrido de las filas mientras este en rango



fin:
	;hacemos los pop basicos
	pop ebx
	pop edi
	pop esi
	pop ebp
	ret ;vovlemos

ponerPositivo:
	neg esi
	jmp cont
