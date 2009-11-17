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
    
    ; xmm5 tiene cuatro 0's enteros signados (32 bits)
    pxor xmm5, xmm5
    
    ; xmm6 tiene cuatro 255's enteros signados (32 bits)
    ; TODO hacer
    
    ;xmm7 tiene cuatro raíces de dos en floats de precisión simple (32 bits)
    finit
    fld1
    fadd st0, st0
    fsqrt
    fstp dword RAIZ_2
    movss xmm7, RAIZ_2
    shufps xmm7, xmm7, 00000000b        ; xmm7 = [2^1/2|2^1/2|2^1/2|2^1/2]
    
    ;;;
    ;;; Derivada en X
    ;;;
    
    cicloFilas:
        ;;;
        ;;; Cálculo de la sumatoria de la primera columna fuera del ciclo
        ;;;
        ; TODO calcular valor de la columna 0 y guardarlo en xmm4_1
        ; el resto de xmm4 debería tener ceros en float... ceros en bits?
        
        ; recorro columnas desde 1 hasta width, de a 8 en 8
        ; en cada iteración se levanta un bloque de 3x8 pixeles (comenzando en
        ; la fila ecx, columna edx); con ello se calcula la derivada en X de
        ; la fila del medio entre (edx-1) y (edx+6) usando en cada paso los
        ; valores salvados en xmm2_0 y xmm_1 de la iteración anterior
        
        xor edx, edx         ; edx es el contador de columnas
        inc edx
     
        cicloColumnas:
            ;;; levanta la primera fila de 8 en xmm0:xmm1 como SP floats

            movdqu xmm0, [esi + edx]            ; xmm0 = [ | | | | | | | |0|1|2|3|4|5|6|7] (fila 1) (enteros 8-bit sin signo)
            
            punpcklbw xmm0, xmm5                ; xmm0 = [ 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 ] (fila 1) (enteros 16-bit con o sin signo)
            movdqu xmm1, xmm0                   ; xmm1 = xmm0
                                                
            punpcklwd xmm0, xmm5                ; xmm0 = [   0   |   1   |   2   |   3   ] (fila 1) (enteros 32-bit con o sin signo)
            punpckhwd xmm1, xmm5                ; xmm1 = [   4   |   5   |   6   |   7   ] (fila 1)                "
           
            cvtdq2ps xmm0, xmm0                 ;
            cvtdq2ps xmm1, xmm1                 ; convierto xmm0 y xmm1 a SP floats (32 bits)
            
            ;;; levanta la segunda fila de 8 en xmm2:xmm3 como SP floats
                        
            add esi, WIDTH                      ; avanza de fila
            
            movq xmm2, [esi + edx]              ; xmm2 = [ | | | | | | | |0|1|2|3|4|5|6|7] (fila 2)
            
            punpcklbw xmm2, xmm5                ; xmm2 = [ 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 ] (fila 2)
            movdqu xmm3, xmm2                   ; xmm3 = xmm2
                                                
            punpcklwd xmm2, xmm5                ; xmm2 = [   0   |   1   |   2   |   3   ] (fila 2)
            punpckhwd xmm3, xmm5                ; xmm3 = [   4   |   5   |   6   |   7   ] (fila 2)
           
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
            
            punpcklbw xmm2, xmm5                ; xmm2 = [ 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 ] (fila 3)
            movdqu xmm3, xmm2                   ; xmm3 = xmm2
                                                
            punpcklwd xmm2, xmm5                ; xmm2 = [   0   |   1   |   2   |   3   ] (fila 3)
            punpckhwd xmm3, xmm5                ; xmm3 = [   4   |   5   |   6   |   7   ] (fila 3)
           
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
            
            ; TODO borrar            
            movdqu xmm4, xmm2
            
            ;;; calcula en xmm4 el valor de la derivada en X para las primeras cuatro columnas
           
            shuf:
            shufps xmm4, xmm0, 01000100b        ; xmm4 = [ (-1)  |  (0)  |  (1)  |  (2)  ] 
            subps xmm4, xmm0                    ; xmm4 = [ -[0]  | -[1]  | -[2]  | -[3]  ]
            
            ;;; calcula en xmm0 el valor de la derivada en X para las últimas cuatro columnas
                        
            shufps xmm0, xmm1, 01001110b        ; xmm0 = [  (3)  |  (4)  |  (5)  |  (6)  ]
            subps xmm0, xmm1                    ; xmm0 = [ -[4]  | -[5]  | -[6]  | -[7]  ]
            
            pxor xmm2, xmm2
            pxor xmm3, xmm3
            
            subps xmm2, xmm4
            subps xmm3, xmm0
            
            cvtps2dq xmm2, xmm2
            cvtps2dq xmm3, xmm3
            
            packssdw xmm2, xmm2
            packssdw xmm3, xmm3
            
            packuswb xmm2, xmm2
            packuswb xmm3, xmm3
            
            
            ;
            ;
            ;
            ; TODO insertar algo útil aquí
            ;
            ;
            ;
            
            
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
