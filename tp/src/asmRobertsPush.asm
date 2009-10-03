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

global asmRobertsPush
%define SRC [EBP+8]	;donde empieza la matriz de la imagen original
%define DST [EBP+12]	;donde empieza la matriz de los datos a guardar
%define WIDTH [EBP+16]	;el ancho de la imagen
%define HEIGHT [EBP+20]	;el alto de la imagen

section .text

section .data
asmRobertsPush:  ;funcion a la que se llama
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
		xor esi, esi
		mov esi, ecx	;esi=fila
		
		mov eax, esi
		mul DWORD WIDTH	;esi=fila*widht
		mov esi, eax

		add esi, SRC	;esi = DST + WIDTH*FILA = POS FILA BIEN
		add esi, ebx	;esi=&a11
		xor eax, eax	;eax va a ser el valor a poner
		mov al, [esi]	;eax = (m11*a11) , m11=1!

		add esi, WIDTH	;esi=&a21
		inc esi		;esi=&a22
		push ebx
		xor ebx, ebx
		mov bl, [esi]
		sub eax, ebx	;eax=a11-a22
		pop ebx
		;creo q aca tenemos que saturar
		jl pasarAPositivo 
	sigue1:
; 		cmp eax, 255
; 		jg pasarA255
; 	sigue2:

	cont:
		mov esi, ecx ;ecx=fila

		push eax
		mov eax, esi
		mul DWORD WIDTH ;esto esta mal
		mov esi, eax
		pop eax

		add esi, DST 
		add esi, ebx

		mov [esi], al
		
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

pasarAPositivo:
	xor al, al
	jmp sigue1

; pasarA255:
; 	mov eax, 255
; 	jmp sigue2
