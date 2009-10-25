;ALGORITMO DE DETECCION DE IMAGENES DE ROBERTS - versión SIMD!
;---------------------------------------------
;PROTOTIPO: void asmRoberts(const char* src, char* dst, int ancho, int alto);

global asmRoberts
%define SRC [EBP+8]	;donde empieza la matriz de la imagen original
%define DST [EBP+12]	;donde empieza la matriz de los datos a guardar
%define WIDTH [EBP+16]	;el ancho de la imagen
%define HEIGHT [EBP+20]	;el alto de la imagen
%define WIDTHSTEP [EBP-4];variable local donde se almacena el WIDTHSTEP


section .text

section .data
	mask: dd 0xffff_ffff,0xffff_ffff,0xffff_ffff,0xfff_ff00

asmRoberts:
	;hacemos los push basicos
	push ebp
	mov ebp, esp
	sub esp, 20 	;variable local para el WIDTHSTEP
	push esi
	push edi
	push ebx
	

comenzarRutina:
	mov esi, SRC	; posicion 1 de la fila 1 de la imagen src
	mov edi, DST	; posicion 1 de la fila 1 de la imagen dst
	
	mov edx, WIDTH	; como el ancho es multiplo de 16, es igual al widthstep, uso width entonces
	mov eax,edx	; me copio el width en eax
	sar edx, 4	; divido por dos 4 veces = divido x 16 (voy a traer de 16 elementos)
	mov ecx, HEIGHT ; cantidad de filas	
	dec ecx
	pxor xmm7,xmm7 	; registro acumulador del resultado de la matriz
	;voy a volcar todo a xmm7 antes de grabarlo en el destino
	dec edx
cicloF:
	xor ebx,ebx ;acumulador de columna
	cmp ecx, 0
	je fin
	
	cicloC:

		pxor xmm7, xmm7 	; flasheo el acumulador	
		cmp edx, ebx
		je ultCol

		;mascaraX:
		
		movdqu	xmm0, [esi]	; cargo 16 elementos de la fila "actual" (x0,x1,...,x15)
		inc esi			; muevo esi uno más "adelante"
		movdqu	xmm1,[esi+eax]	; carga los 16 elementos de abajo de la fila actual desplazados uno
					; osea (y1,...,y15,16)
		dec esi			; restauro el invariante (esi siempre sigue a la fila actual)

		pxor xmm6,xmm6

		movdqu xmm2,xmm0	; copio xmm0 a xmm2
		movdqu xmm3,xmm2 	; copio xmm2 a xmm3

		punpckhbw xmm2, xmm6	; extiendo de bytes a words (parte alta)
		punpcklbw xmm3,xmm6	; id (parte baja)

		movdqu xmm4, xmm1	; hago lo mismo con la fila siguiente
		movdqu xmm5, xmm4

		punpckhbw xmm4, xmm6	; parte alta
		punpcklbw xmm5, xmm6	; parte baja

		psubusw xmm3,xmm5 	;resta partes bajas
		psubusw xmm2, xmm4	;resta partes altas	
		
			

		;resultado en xmm2:xmm3
		;empaqueto resultados (vuelvo a saturar y a tener bytes en vez de words)
			
		packuswb xmm3,xmm2
		
		movdqu xmm7,xmm3	; muevo el resultado al acumulador

		
		;máscaraY
		;;;;;;;;;;;;;;;;;;;;;;;;

		inc esi			; muevo esi uno más "adelante"
		movdqu	xmm0, [esi]	; cargo 16 elementos de la fila "actual" (x0,x1,...,x15) despl uno
		dec esi			; "restauro" el esi
		movdqu	xmm1,[esi+eax]	; carga los 16 elementos de abajo de la fila actual sin desplazamiento
					 

		pxor xmm6,xmm6

		movdqu xmm2,xmm0	; copio xmm0 a xmm2
		movdqu xmm3,xmm2 	; copio xmm2 a xmm3

		punpckhbw xmm2, xmm6	; extiendo de bytes a words (parte alta)
		punpcklbw xmm3,xmm6	; id (parte baja)

		movdqu xmm4, xmm1	; hago lo mismo con la fila siguiente
		movdqu xmm5, xmm4

		punpckhbw xmm4, xmm6	; parte alta
		punpcklbw xmm5, xmm6	; parte baja

		psubusw xmm3,xmm5 	;resta partes bajas
		psubusw xmm2, xmm4	;resta partes altas	
	
		
			
		;resultado en xmm2:xmm3
		;empaqueto resultados (vuelvo a saturar y a tener bytes en vez de words)
			
		packuswb xmm3,xmm2
		
		paddusb xmm7,xmm3	; sumo el resultado al acumulador

		movdqu [edi], xmm7 ; muevo el resultado del acum al destino		


		add esi, 16
		add edi, 16	; muevo los punteros para la próxima iter
		inc ebx		; aumento el contador de col
		jmp cicloC

	ultCol:
		;maskX
		
		movdqu	xmm0, [esi]	;cargo 16 elementos de la fila "actual" (x0,x1,...,x15)
		movdqu	xmm1,[esi+eax]	;carga los 16 elementos de abajo de la fila actual sin desplazarlos
		
;		pslldq xmm1, 1		; hago un shift a la izq en xmm1 tq queda y2,...y15,0
;		movdqu xmm6, [mask]
;		pand xmm0, xmm6		; hago x1,x2,...,x14,0 el último byte no lo proceso (borde)
		pxor xmm6,xmm6

		movdqu xmm2,xmm0	; copio xmm0 a xmm2
		movdqu xmm3,xmm2 	; copio xmm2 a xmm3

		punpckhbw xmm2, xmm6	; extiendo de bytes a words (parte alta)
		punpcklbw xmm3,xmm6	; id (parte baja)

		movdqu xmm4, xmm1	; hago lo mismo con la fila siguiente
		movdqu xmm5, xmm4

		punpckhbw xmm4, xmm6	; parte alta
		punpcklbw xmm5, xmm6	; parte baja

		psubusw xmm3,xmm5 	; resta partes bajas
		psubusw xmm2, xmm4	; resta partes altas	
	
		
		;resultado en xmm2:xmm3
		;empaqueto resultados (vuelvo a saturar y a tener bytes en vez de words)
			
		packuswb xmm3,xmm2
		
		movdqu xmm7,xmm3	; muevo el resultado al acumulador
		
	;	movdqu xmm6, [mask]
	;	pand xmm7, xmm6		; hago x1,x2,...,x14,0 el último byte no lo proceso (borde)
	;	movdqu [edi], xmm7			
		pxor xmm6,xmm6

		;máscaraY
		;;;;;;;;;;;;;;;;;;;;;;;;

		movdqu	xmm0, [esi]	; cargo 16 elementos de la fila "actual" (x0,x1,...,x15) sin despl
		movdqu	xmm1,[esi+eax]	; carga los 16 elementos de abajo de la fila actual sin desplazamiento
					

		movdqu xmm6, [mask]
		;pand xmm1, xmm6		; hago y1,x2,...,y14,0 el último byte no lo proceso (borde)
		;pslldq xmm0, 1		; hago un shift a la izq en xmm0 tq queda x2,...x15,0
		pxor xmm6,xmm6

		movdqu xmm2,xmm0	; copio xmm0 a xmm2
		movdqu xmm3,xmm2 	; copio xmm2 a xmm3

		punpckhbw xmm2, xmm6	; extiendo de bytes a words (parte alta)
		punpcklbw xmm3,xmm6	; id (parte baja)

		movdqu xmm4, xmm1	; hago lo mismo con la fila siguiente
		movdqu xmm5, xmm4

		punpckhbw xmm4, xmm6	; parte alta
		punpcklbw xmm5, xmm6	; parte baja

		psubusw xmm3,xmm5 	;resta partes bajas
		psubusw xmm2, xmm4	;resta partes altas	
			

		;resultado en xmm2:xmm3
		;empaqueto resultados (vuelvo a saturar y a tener bytes en vez de words)
			
		packuswb xmm3,xmm2
		
		paddusb xmm7,xmm3	; muevo el resultado al acumulador


	;	movdqu xmm6, [mask]
		;pand xmm7, xmm6		; hago x1,x2,...,x14,0 el último byte no lo proceso (borde)
		movdqu [edi], xmm7			
		;ebx no lo necesito más a esta altura...
		
		shl ebx, 4	; ebx * 16 me tiene que devolver al incio de la fila
		sub esi, ebx	; re apunto esi, al inicio de la fila
		sub edi, ebx	; lo mismo con el destino
		add esi, eax	; les sumo el ancho de la fila entonces ahora los dejé para la próximo ciclo
		add edi, eax	; osea, una fila más abajo
		dec ecx
		jmp cicloF	

		
	

fin:
	
	pop ebx
	pop edi
	pop esi
	add esp, 20
	pop ebp
	ret
	
