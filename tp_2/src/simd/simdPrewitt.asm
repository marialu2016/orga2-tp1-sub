global simdPrewitt
%define SRC [EBP+8]	;donde empieza la matriz de la imagen original
%define DST [EBP+12]	;donde empieza la matriz de los datos a guardar
%define WIDTH [EBP+16]	;el ancho de la imagen
%define HEIGHT [EBP+20]	;el alto de la imagen

section .data

section .text

simdPrewitt: 
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
    mov BYTE [edi], 0   ;pongo en 0 el primero de cada fila
	inc edx			;empieza en 1 para que salga una columna antes VER QUE ONDA
	cicloC:			;accesos a memoria
		mascaraX:
			;vamos a traer los datos para la mascaraX
			sub esi, ebx
			movdqu xmm5, [esi+edx-1] ;fila de arriba
			add esi, ebx
			movdqu xmm6, [esi+edx-1] ;fila actual
			add esi, ebx
			movdqu xmm7, [esi+edx-1] ;fila de abajo
			sub esi, ebx
			;entoces en 	XMM5 tenemos 16 bytes de la fila de arriba (fila 1)
			;	   	XMM6 tenemos 16 bytes de la fila central (fila 2)
			;		XMM7 tenemos 16 bytes de la fila de abajo (fila 3)
			;		esi quedo en la fila central
			pxor xmm4, xmm4
			movdqu xmm0,xmm5
			punpcklbw xmm0, xmm4 ;xmm0=[a1.1,a1.2,..,a1.8]
			movdqu xmm1,xmm6
			punpcklbw xmm1, xmm4 ;xmm1=[a2.1,a2.2,..,a2.8]
			movdqu xmm2,xmm7
			punpcklbw xmm2, xmm4 ;xmm2=[a3.1,a3.2,..,a3.8]
			movdqu xmm3,xmm5
			punpckhbw xmm3, xmm4 ;xmm3=[a1.9,a1.10,..,a1.16]
			movdqu xmm4,xmm6
			pxor xmm5, xmm5
			punpckhbw xmm4, xmm5 ;xmm4=[a2.9,a2.10,..,a2.16]
			movdqu xmm5,xmm7
			pxor xmm6, xmm6
			punpckhbw xmm5, xmm6 ;xmm5=[a3.9,a3.10,..,a3.16]
			pxor xmm6,xmm6
			psubw xmm6, xmm0 ;xmm6 = -xmm0
			psubw xmm6, xmm1 ;xmm6 = -xmm0-xmm1
			psubw xmm6, xmm2 ;xmm6 = -xmm0-xmm1-xmm2

			;ahora voy por la suma de las otras partes
			movdqu xmm7, xmm0
			psrldq xmm7, 2*2  ;xmm7 = xmm0>>4B=[a1.3,..,a1.8,0,0]
			movdqu xmm0, xmm3 ;xmm0 = xmm3
			pslldq xmm0, 2*6  ;xmm0 = [0,..,a1.9,a1.10]
			paddw xmm7, xmm0  ;xmm7 = [a1.3,..,a.10] = suma1
			paddw xmm6, xmm7  ;xmm6 = -xmm0-xmm1-xmm2+suma1

			movdqu xmm7, xmm1
			psrldq xmm7, 2*2  ;xmm7 = xmm1>>4B = [a2.3,..,a2.8,0,0]
			movdqu xmm0, xmm4 ;xmm0 = xmm4
			pslldq xmm0, 2*6  ;xmm0 = [0,..,0,a2.9,a2.10]
			paddw xmm7, xmm0  ;xmm7 = [a2.3,..,a2.10] = suma2
			paddw xmm6, xmm7  ;xmm6 = -xmm0-xmm1-xmm2+suma1+suma2

			movdqu xmm7, xmm2
			psrldq xmm7, 2*2  ;xmm7 = xmm2>>4B = [a3.3,..,a.8,0,0]
			movdqu xmm0, xmm5 ;xmm0 = xmm5
			pslldq xmm0, 2*6  ;xmm0 = [0,..,0,a3.9,a3.10]
			paddw xmm7, xmm0  ;xmm7 = [a3.3,..,a3.10] = suma3
			paddw xmm6, xmm7  ;xmm6= -xmm0-xmm1-xmm2+suma1+suma2+suma3
			
			;ahora hay que hacer el calculo de los proxomos 6 (con 8 datos)
			pxor xmm0, xmm0  ;xmm0 = 0 aca se va a guardar estos datos
			psubw xmm0, xmm3 ;xmm0 = -xmm3
			psubw xmm0, xmm4 ;xmm0 = -xmm3-xmm4
			psubw xmm0, xmm5 ;xmm0 = -xmm3-xmm4-xmm5
			psrldq xmm3, 2*2 ;xmm3>>4B = [a1.11,..,a1,.16,0,0] = suma1
			paddw xmm0, xmm3 ;xmm0 = -xmm3-xmm4-xmm5+suma1
			psrldq xmm4, 2*2 ;xmm4>>4B = [a2.11,..,a2.16,0,0] = suma2
			paddw xmm0, xmm4 ;xmm0 = -xmm3-xmm4-xmm5+suma1+suma2
			psrldq xmm5, 2*2 ;xmm5>>4B = [a3.11,..,a3.16,0,0] = suma3
			paddw xmm0, xmm5 ;xmm0 = -xmm3-xmm4-xmm4+suma1+suma2+suma3 = lo que queremos
			packuswb xmm6, xmm0
			;xmm6 = los primeros 14 bytes son los que nos improta, tiene todo los datos
			;bien guardados (cuando ande) y los ultimos 2 los vamos apisar asi que no importa 
			movdqu [edi+edx], xmm6

		mascaraY:
			sub esi, ebx
			movdqu xmm6, [esi+edx-1] ;linea de arriba
			add esi, ebx
			add esi, ebx
			movdqu xmm7, [esi+edx-1] ;linea de abajo
			sub esi, ebx
			movdqu xmm0, xmm6
			pxor xmm5, xmm5
			punpcklbw xmm0, xmm5 ;xmm0=[a1.1,a1.2,..,a1.8]
			movdqu xmm1, xmm7
			punpcklbw xmm1, xmm5 ;xmm2=[a3.1,a3.2,..,a3.8]
			movdqu xmm2, xmm6
			punpckhbw xmm2, xmm5 ;xmm3=[a1.9,a1.10,..,a1.16]
			movdqu xmm3, xmm7
			punpckhbw xmm3, xmm5 ;xmm5=[a3.9,a3.10,..,a3.16]
			;ahora empeiza 
			movdqu xmm4, xmm1
			psubw xmm4, xmm0

			movdqu xmm5, xmm0
			psrldq xmm5, 2
			movdqu xmm6, xmm2
			pslldq xmm6, 7*2
			paddw xmm5, xmm6
			psubw xmm4, xmm5

			movdqu xmm5, xmm0
			psrldq xmm5, 4
			movdqu xmm6, xmm2
			pslldq xmm6, 6*2
			paddw xmm5, xmm6
			psubw xmm4, xmm5

			movdqu xmm5, xmm1
			psrldq xmm5, 2
			movdqu xmm6, xmm3
			pslldq xmm6, 7*2
			paddw xmm5, xmm6
			paddw xmm4, xmm5

			movdqu xmm5, xmm1
			psrldq xmm5, 4
			movdqu xmm6, xmm3
			pslldq xmm6, 6*2
			paddw xmm5, xmm6
			paddw xmm4, xmm5

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

