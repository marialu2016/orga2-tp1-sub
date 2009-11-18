;    Aplica el operador de Frei-chen a la imagen 'src' y almacena el
; resultado como una nueva imagen en 'dst', ambas del mismo tamaño.
;    Se asume que el ancho es múltiplo de 16.
;
;void simdFreichen(const char* src, char* dst, int ancho, int alto);

global simdFreichen

;;; Parámetros
%define SRC        [EBP+8]      ; donde empieza la matriz de la imagen original
%define DST        [EBP+12]     ; donde empieza la matriz de los datos a guardar
%define WIDTH_AUX  [EBP+16]     ; el ancho de la imagen
%define WIDTH      ebx          ; se usa ebx para WIDTH por razones de eficiencia
%define HEIGHT     [EBP+20]     ; el alto de la imagen

;;; Variables locales
%define RAIZ_2 [EBP-4]          ; constante raíz de dos

;;; Constantes XMM
%define XMM_ZERO xmm6
%define XMM_SQR2 xmm7

section .data

section .text

simdFreichen:
    ;;;
    ;;; Stack frame y convención C
    ;;;
    
    push ebp
    mov ebp, esp
    sub esp, 4

    push esi
    push edi
    push ebx
    
    ;;;
    ;;; Inicialización
    ;;;
    
    mov ebx, WIDTH_AUX        ; ebx = WIDTH

    mov esi, SRC         ; esi y edi apuntan a la fila actual de src y dst respectivamente
    mov edi, DST
    
    ; recorro (height-2) filas con ecx
    mov ecx, HEIGHT
    sub ecx, 2           ; aguante el grupo SUB
    
    emms
    
    ; XMM_ZERO tiene todos ceros
    pxor XMM_ZERO, XMM_ZERO
    
    ; XMM_SQR2 tiene cuatro raíces de dos en floats de precisión simple (32 bits)
    finit
    fld1
    fadd st0, st0
    fsqrt
    fstp dword RAIZ_2
    movss xmm7, RAIZ_2
    shufps XMM_SQR2, XMM_SQR2, 00000000b        ; XMM_SQR2 = [2^1/2|2^1/2|2^1/2|2^1/2]
    
    cicloFilas:
        ;;;
        ;;; Cálculo de la sumatoria de la primera columna fuera del ciclo
        ;;;
        ; TODO calcular valor de la columna 0 y guardarlo en xmm4_1
                
        ; recorro columnas desde 1 hasta width, de a 8 en 8
        ; en cada iteración se levanta un bloque de 3x8 pixeles (comenzando en
        ; la fila ecx, columna edx); con ello se calcula la derivada en X de
        ; la fila del medio entre (edx-1) y (edx+6) usando en cada paso los
        ; valores salvados en xmm2_0 y xmm_1 de la iteración anterior
        
        xor edx, edx         ; edx es el contador de columnas
        inc edx
     
        cicloColumnas:
            ;;;
            ;;; Derivada en X
            ;;;
            
            ;;; levanta la primera fila de 8 en xmm0:xmm1 como SP floats

            movdqu xmm0, [esi + edx]            ; xmm0 = [ | | | | | | | |0|1|2|3|4|5|6|7] (fila 1) (enteros 8-bit sin signo)
            
            punpcklbw xmm0, XMM_ZERO                ; xmm0 = [ 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 ] (fila 1) (enteros 16-bit con o sin signo)
            movdqu xmm1, xmm0                   ; xmm1 = xmm0
                                                
            punpcklwd xmm0, XMM_ZERO                ; xmm0 = [   0   |   1   |   2   |   3   ] (fila 1) (enteros 32-bit con o sin signo)
            punpckhwd xmm1, XMM_ZERO                ; xmm1 = [   4   |   5   |   6   |   7   ] (fila 1)                "
           
            cvtdq2ps xmm0, xmm0                 ;
            cvtdq2ps xmm1, xmm1                 ; convierto xmm0 y xmm1 a SP floats (32 bits)
            
            ;;; levanta la segunda fila de 8 en xmm2:xmm3 como SP floats
                        
            add esi, WIDTH                      ; avanza de fila
            
            movq xmm2, [esi + edx]              ; xmm2 = [ | | | | | | | |0|1|2|3|4|5|6|7] (fila 2)
            
            punpcklbw xmm2, XMM_ZERO            ; xmm2 = [ 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 ] (fila 2)
            movdqu xmm3, xmm2                   ; xmm3 = xmm2
                                                
            punpcklwd xmm2, XMM_ZERO            ; xmm2 = [   0   |   1   |   2   |   3   ] (fila 2)
            punpckhwd xmm3, XMM_ZERO            ; xmm3 = [   4   |   5   |   6   |   7   ] (fila 2)
           
            cvtdq2ps xmm2, xmm2                 ;
            cvtdq2ps xmm3, xmm3                 ; convierto xmm2 y xmm3 a SP floats (32 bits)
            
            ;;; hace f1 = f1 + f2 * sqr(2)
                        
            mulps xmm2, xmm7                    ; 
            mulps xmm3, xmm7                    ; multiplica segunda fila por sqr(2)
            
            addps xmm0, xmm2                    ; suma primera y segunda fila
            addps xmm1, xmm3                    ; en xmm0:xmm1 quedan las dos primeras filas ya comprimidas
            
            ;;; levanta la tercera fila de 8 en xmm2:xmm3 como SP floats
                        
            add esi, WIDTH                      ; avanza de fila
            
            movq xmm2, [esi + edx]              ; xmm2 = [ | | | | | | | |0|1|2|3|4|5|6|7] (fila 3)
            
            punpcklbw xmm2, XMM_ZERO            ; xmm2 = [ 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 ] (fila 3)
            movdqu xmm3, xmm2                   ; xmm3 = xmm2
                                                
            punpcklwd xmm2, XMM_ZERO            ; xmm2 = [   0   |   1   |   2   |   3   ] (fila 3)
            punpckhwd xmm3, XMM_ZERO            ; xmm3 = [   4   |   5   |   6   |   7   ] (fila 3)
           
            cvtdq2ps xmm2, xmm2                 ; 
            cvtdq2ps xmm3, xmm3                 ; convierto xmm2 y xmm3 a SP floats (32 bits)
            
            ;;; suma la tercera fila al resultado acumulado (f1 = f1 + f3)
            
            addps xmm0, xmm2                    ; suma tercera fila
            addps xmm1, xmm3
            
            ; En xmm0:xmm1 quedan 8 columnas comprimidas; además en xmm4 están
            ; los valores de las dos columnas anteriores salvados en el paso anterior
            
            
            
            ; xmm0 = [  (1)  |  (2)  |  (3)  |  (4)  ] 
            ; xmm1 = [  (5)  |  (6)  |  (7)  |  (8)  ]
            ; xmm4 = [ (-1)  |  (0)  |   ?   |   ?   ]    (de la iteración anterior)
            
            ;;; calcula en xmm0 el valor de la derivada en X para las primeras cuatro columnas
            
            movdqu xmm2, xmm0                   ; xmm2 = [  (1)  |  (2)  |  (3)  |  (4)  ]             
            shufps xmm4, xmm0, 01000100b        ; xmm4 = [ (-1)  |  (0)  |  (1)  |  (2)  ] 
            subps xmm0, xmm4                    ; xmm0 = [  [0]  |  [1]  |  [2]  |  [3]  ]
            
            ;;; IMPORTANTE: salva (7) y (8) en xmm4 para la próxima iteración (en donde se llamarán (-1) y (0))
            pshufd xmm4, xmm1, 11101110b        ; xmm4 = [  (7)  |  (8)  |   ?   |   ?   ]
            
            ;;; calcula en xmm1 el valor de la derivada en X para las últimas cuatro columnas
                        
            shufps xmm2, xmm1, 01001110b        ; xmm2 = [  (3)  |  (4)  |  (5)  |  (6)  ]
            subps xmm1, xmm2                    ; xmm1 = [  [4]  |  [5]  |  [6]  |  [7]  ]
            
            cvtps2dq xmm0, xmm0                 ; 
            cvtps2dq xmm1, xmm1                 ; convierte los resultados a enteros signados (32 bits)
            
            packssdw xmm0, xmm1                 ; xmm0 = [[0]|[1]|[2]|[3]|[4]|[5]|[6][7]]
            
            ;;; xmm0 contiene derivadas en x para los 8 pixeles
            
            ;;;
            ;;; Derivada en Y
            ;;; TODO
            
            ;;; TODO merge de X e Y
            
            packuswb xmm0, XMM_ZERO             ; pasa xmm0 a bytes y satura a 0 y 255 (sin signo)
            
            movdqu [edi + edx - 1], xmm0
            
            ;; TODO continuar
            ; punpcklbw xmm0, XMM_ZERO            ; vuelve a convertir xmm2 a words
            
            ; IMPORTANTE: retrocede las filas
            sub esi, WIDTH
            sub esi, WIDTH
                                                
            add edx, 8
            cmp edx, WIDTH
        jl cicloColumnas
        
        
        add esi, WIDTH
        add edi, WIDTH
        
        dec ecx
    jg cicloFilas
    
    pop ebx              ; restauro los registros
    pop edi    
    pop esi
    
    add esp, 4
    
    pop ebp              ; retorno
    xor eax, eax

ret
