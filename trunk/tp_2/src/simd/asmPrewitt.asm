global asmPrewitt
%define SRC [EBP+8]	;donde empieza la matriz de la imagen original
%define DST [EBP+12]	;donde empieza la matriz de los datos a guardar
%define WIDTH [EBP+16]	;el ancho de la imagen
%define HEIGHT [EBP+20]	;el alto de la imagen

section .text

section .data
asmPrewitt: 
	;hacemos los push basicos
	push ebp
	mov ebp, esp
	push esi
	push edi
	push ebx
	
comenzarRutina:
	;dec DWORD WIDTH	;hacemos que recorra hasta WIDHT-1
	dec DWORD HEIGHT;hacemos que recorra hasta HEIGHT-1

	xor ecx, ecx	;el acumulador de la fila
	inc ecx		;se pone en 1 para que salga una fila antes
	mov esi, SRC	;posicion 1 de la fila 1 del src
	mov edi, DST	;posicion 1 de la fila 1 del dst
	mov ebx, WIDTH	;ebx va a ser el width
	add esi, ebx	;esi empeiza en la seguna fila
	add edi, ebx	;edi empeiza en la segunda fila


;recordemos q esi+edx es la posicion a22 de la matriz actual (el centro)
cicloF:
	xor edx, edx 		;acumulador de la columna
	inc edx			;empieza en 1 para que salga una columna antes VER QUE ONDA
	cicloC:			;accesos a memoria
		mascaraX:
			;vamos a traer los datos para la mascaraX
			sub esi, ebx
			movdqu xmm5, [esi+edx-1]
			add esi, ebx
			movdqu xmm6, [esi+edx-1]
			add esi, ebx
			movdqu xmm7, [esi+edx-1]
			sub esi, ebx
			pxor xmm0, xmm0
			punpcklbw xmm0, xmm5 ;xmm0=[a1.1,a1.2,..,a1.8]
			pxor xmm1,xmm1
			punpcklbw xmm1, xmm6 ;xmm1=[a2.1,a2.2,..,a2.8]
			pxor xmm2, xmm2
			punpcklbw xmm2, xmm7 ;xmm2=[a3.1,a3.2,..,a3.8]
			pxor xmm3, xmm3
			punpckhbw xmm3, xmm5 ;xmm3=[a1.9,a1.10,..,a1.16]
			pxor xmm4, xmm4
			punpckhbw xmm4, xmm6 ;xmm4=[a2.9,a2.10,..,a2.16]
			pxor xmm5, xmm5
			punpckhbw xmm5, xmm7 ;xmm5=[a3.9,a3.10,..,a3.16]
			pxor xmm6,xmm6
			psubw xmm6, xmm0
			psubw xmm6, xmm1
			psubw xmm6, xmm2     ;restada la primer columna
			;aca ya quedan libres xmm0,1,2 MASO
			movdqu xmm7, xmm0
			psrldq xmm7, 2*2
			movdqu xmm0, xmm3
			pslldq xmm0, 2*6
			psrldq xmm0, 2*6
			paddw xmm7, xmm0
			paddw xmm6, xmm7

			movdqu xmm7, xmm1
			psrldq xmm7, 2*2
			movdqu xmm0, xmm4
			pslldq xmm0, 2*6
			psrldq xmm0, 2*6
			paddw xmm7, xmm0
			paddw xmm6, xmm7

			movdqu xmm7, xmm2
			psrldq xmm7, 2*2
			movdqu xmm0, xmm5
			pslldq xmm0, 2*6
			psrldq xmm0, 2*6
			paddw xmm7, xmm0
			paddw xmm6, xmm7     ;xmm6=[-a1.1-a2.1-a3.1+a1.3+a2.3+a3.3,...]
			;listo mascaraX de los primeros 4 pixeles, ahora quedan libre xmm0,1,2
			pxor xmm0, xmm0
			psubw xmm0, xmm3
			psubw xmm0, xmm4
			psubw xmm0, xmm5
			psrldq xmm3, 2*2
			paddw xmm0, xmm3
			psrldq xmm4, 2*2
			paddw xmm0, xmm4
			psrldq xmm5, 2*2
			paddw xmm0, xmm5     ;xmm0 la segunda parte ya hehco
			packuswb xmm6, xmm0  ;exn xmm6 esta todo hecho
			;movdqu [edi+edx], xmm6

		mascaraY:
			sub esi, ebx
			movdqu xmm6, [esi+edx-1] ;linea de arriba
			add esi, ebx
			add esi, ebx
			movdqu xmm7, [esi+edx-1] ;linea de abajo
			sub esi, ebx
			pxor xmm0, xmm0
			punpcklbw xmm0, xmm6 ;xmm0=[a1.1,a1.2,..,a1.8]
			pxor xmm1,xmm1
			punpcklbw xmm1, xmm7 ;xmm2=[a3.1,a3.2,..,a3.8]
			pxor xmm2, xmm2
			punpckhbw xmm2, xmm6 ;xmm3=[a1.9,a1.10,..,a1.16]
			pxor xmm3, xmm3
			punpckhbw xmm3, xmm7 ;xmm5=[a3.9,a3.10,..,a3.16]
			;ahora empeiza 
			movdqu xmm4, xmm1
			psubw xmm4, xmm0

			movdqu xmm5, xmm0
			psrldq xmm5, 2
			movdqu xmm6, xmm2
			pslldq xmm6, 7*2
			psrldq xmm6, 7*2
			paddw xmm5, xmm6
			psubw xmm4, xmm5

			movdqu xmm5, xmm0
			psrldq xmm5, 4
			movdqu xmm6, xmm2
			pslldq xmm6, 6*2
			psrldq xmm6, 7*2
			paddw xmm5, xmm6
			psubw xmm4, xmm5

			movdqu xmm5, xmm1
			psrldq xmm5, 2
			movdqu xmm6, xmm3
			pslldq xmm6, 7*2
			psrldq xmm6, 7*2
			paddw xmm5, xmm6
			paddw xmm4, xmm5

			movdqu xmm5, xmm1
			psrldq xmm5, 2
			movdqu xmm6, xmm3
			pslldq xmm6, 6*2
			psrldq xmm6, 7*2
			paddw xmm5, xmm6
			paddw xmm4, xmm5
			;queda libre el resto menos 2 y 3
			pxor xmm0, xmm0
			psubw xmm0, xmm2
			paddw xmm0, xmm3
			psrldq xmm2, 2
			psubw xmm0, xmm2
			psrldq xmm3, 2
			paddw xmm0, xmm3
			psrldq xmm2, 2
			psubw xmm0, xmm2
			psrldq xmm3, 2
			paddw xmm0, xmm3
			packuswb xmm4, xmm0

			movdqu xmm5, [edi+edx]
			paddusb xmm4, xmm5
			movdqu [edi+edx], xmm4


		add edx, 14
		cmp edx, ebx
		jl cicloC

	;aca sigue cicloF
	mov BYTE [edi+ebx-1], 0
	add esi, ebx 	;primer fila de la siguiente columna del src
	add edi, ebx	;primer fila de la siguiente columna del dst
	inc ecx
	cmp ecx, HEIGHT
	jne cicloF

fin:
	;hacemos los pop basicos
	pop ebx
	pop edi
	pop esi
	pop ebp
	ret ;vovlemos

