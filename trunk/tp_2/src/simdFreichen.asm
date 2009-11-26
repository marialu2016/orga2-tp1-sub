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

; Macro LOAD.
;
; Recibe dos registros xmm como parámetros y carga en ellos una fila de 8px de
; la imagen fuente como SP floats (cuatro en cada uno) desde [esi + edx].
;
%macro LOAD 2
    
    ; %1 = [ | | | | | | | |0|1|2|3|4|5|6|7] (enteros 8-bit sin signo)
    movq %1, [esi + edx]
    
    ; %1 = [ 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 ] (enteros 16-bit con o sin signo, pues valen entre 0 y 255)
    punpcklbw %1, XMM_ZERO              
    
    ; %2 = %1
    movdqu %2, %1
    
    ; %1 = [   0   |   1   |   2   |   3   ] (enteros 32-bit con o sin signo)
    punpcklwd %1, XMM_ZERO              
    
    ; %2 = [   4   |   5   |   6   |   7   ] (enteros 32-bit con o sin signo)
    punpckhwd %2, XMM_ZERO
   
    cvtdq2ps %1, %1                     ;
    cvtdq2ps %2, %2                     ; convierto %1 y %2 a SP floats (32 bits)    

%endmacro

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
    
    mov WIDTH, WIDTH_AUX ; ebx = WIDTH

    mov esi, SRC         ; esi apunta a la fila actual de src, donde se empieza a leer
    mov edi, DST         
    add edi, WIDTH       ; edi apunta a la fila siguiente de dst, donde se escribe
    
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
    movss XMM_SQR2, RAIZ_2
    shufps XMM_SQR2, XMM_SQR2, 00000000b        ; XMM_SQR2 = [2^1/2|2^1/2|2^1/2|2^1/2]
    
    cicloFilas:
        ;;;
        ;;; Cálculo de la sumatoria de la primera columna fuera del ciclo
        ;;;
        ; TODO calcular valor de la columna 0 y guardarlo en xmm5_1
                
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
            ; xmm5 contiene de la iteración anterior los valores de las dos
            ; columnas anteriores comprimidas en X y en Y
            ; xmm5 = [ (-1)x |  (0)x | (-1)y |  (0)y ]
            
            
            LOAD xmm0, xmm1                     ; carga primera fila en xmm0:xmm1
            add esi, WIDTH                      ; avanza de fila
            LOAD xmm2, xmm3                     ; carga segunda fila en xmm2:xmm3
            
            mulps xmm2, XMM_SQR2                ; 
            mulps xmm3, XMM_SQR2                ; multiplica segunda fila por sqr(2)
            
            addps xmm0, xmm2                    ; suma primera y segunda fila
            addps xmm1, xmm3                    ; en xmm0:xmm1 quedan las dos primeras filas ya comprimidas
            
            add esi, WIDTH                      ; avanza de fila
            LOAD xmm2, xmm3                     ; carga tercera fila en xmm2:xmm3
            
            sub esi, WIDTH                      ;
            sub esi, WIDTH                      ; retrocede las filas avanzadas
            
            addps xmm0, xmm2                    ;
            addps xmm1, xmm3                    ; suma tercera fila al resultado acumulado
            
            ; En xmm0:xmm1 quedan 8 columnas comprimidas; además en xmm5 están
            ; los valores de las dos columnas anteriores en X e Y salvados del
            ; paso anterior
            
            ; xmm0 = [  (1)  |  (2)  |  (3)  |  (4)  ] 
            ; xmm1 = [  (5)  |  (6)  |  (7)  |  (8)  ]
            ; xmm5 = [ (-1)  |  (0)  | (-1)y |  (0)y ]    (xmm5 de la iteración anterior)
            
            ; Guarda en xmm2 los futuros valores de xmm5 para la próxima iteración.
            ; Como se ve salva las derivadas en Y y actualiza las derivadas en X
            ; con los nuevos valores, (7) y (8) (que luego serán (-1) y (0)).
            movdqu xmm2, xmm1                   ; xmm2 = [  (5)  |  (6)  |  (7)  |  (8)  ]
            shufps xmm2, xmm5, 11101110b        ; xmm2 = [  (7)  |  (8)  | (-1)y |  (0)y ]
            
            
            ;;; calcula en xmm4 el valor de la derivada en X para las primeras cuatro columnas
            
            movdqu xmm4, xmm0                   ; xmm4 = [  (1)  |  (2)  |  (3)  |  (4)  ]             
            shufps xmm5, xmm4, 01000100b        ; xmm5 = [ (-1)  |  (0)  |  (1)  |  (2)  ] 
            subps xmm4, xmm5                    ; xmm4 = [  [0]  |  [1]  |  [2]  |  [3]  ]
            
            movdqu xmm5, xmm2                   ; restaura xmm5
                        
            ;;; calcula en xmm1 el valor de la derivada en X para las últimas cuatro columnas
                        
            shufps xmm0, xmm1, 01001110b        ; xmm0 = [  (3)  |  (4)  |  (5)  |  (6)  ]
            subps xmm1, xmm0                    ; xmm1 = [  [4]  |  [5]  |  [6]  |  [7]  ]
            
            cvtps2dq xmm4, xmm4                 ; 
            cvtps2dq xmm1, xmm1                 ; convierte los resultados a enteros signados (32 bits)
            
            ; empaqueta y convierte los resultados a enteros signados (16 bits)
            packssdw xmm4, xmm1                 ; xmm4 = [[0]|[1]|[2]|[3]|[4]|[5]|[6]|[7]]
            
            ; xmm4 contiene derivadas en x para los 8 pixeles
            ; xmm5 tiene los valores de X para la próxima iteración y conserva
            ;      los de Y de la iteración anterior
            
            ;;;
            ;;; Derivada en Y
            ;;;
            
            LOAD xmm0, xmm1                     ; carga primera fila en xmm0:xmm1
            add esi, WIDTH
            add esi, WIDTH
            LOAD xmm2, xmm3                     ; carga tercera fila en xmm2:xmm3
            
            sub esi, WIDTH                      ;
            sub esi, WIDTH                      ; retrocede las filas avanzadas
            
            subps xmm2, xmm0
            subps xmm3, xmm1                    ; deja en xmm2:xmm3 la diferencia entre las filas
            
            ; xmm2 = [  (1)  |  (2)  |  (3)  |  (4)  ] 
            ; xmm3 = [  (5)  |  (6)  |  (7)  |  (8)  ]
            ; xmm5 = [  (7)x |  (8)x | (-1)  |  (0)  ]    (de la iteración anterior)
            
            movdqu xmm0, xmm5                   ; xmm0 = [  (7)x |  (8)x | (-1)  |  (0)  ]
            
            ; Guarda en xmm5 los valores para la próxima iteración
            shufps xmm5, xmm3, 11100100b        ; xmm5 = [  (7)x |  (8)x |  (7)  |  (8)  ]
            
            shufps xmm0, xmm2, 01001110b        ; xmm0 = [ (-1)  |  (0)  |  (1)  |  (2)  ]
            
            movdqu xmm1, xmm0                   ; xmm1 = [ (-1)  |  (0)  |  (1)  |  (2)  ]
            shufps xmm1, xmm2, 10011001b        ; xmm1 = [  (0)  |  (1)  |  (2)  |  (3)  ]
            
            mulps xmm1, XMM_SQR2
            addps xmm0, xmm1
            addps xmm0, xmm2                    ; xmm0 = [  [0]  |  [1]  |  [2]  |  [3]  ]
            
            shufps xmm2, xmm3, 01001110b        ; xmm2 = [  (3)  |  (4)  |  (5)  |  (6)  ] 
            movdqu xmm1, xmm2                   ; xmm1 = [  (3)  |  (4)  |  (5)  |  (6)  ] 
            shufps xmm1, xmm3, 10011001b        ; xmm1 = [  (4)  |  (5)  |  (6)  |  (7)  ] 
            
            mulps xmm1, XMM_SQR2
            addps xmm1, xmm2
            addps xmm1, xmm3                    ; xmm1 = [  [4]  |  [5]  |  [6]  |  [7]  ]
            
            cvtps2dq xmm0, xmm0                 ; 
            cvtps2dq xmm1, xmm1                 ; convierte los resultados a enteros signados (32 bits)
            
            ; empaqueta y convierte los resultados a enteros signados (16 bits)
            packssdw xmm0, xmm1                 ; xmm0 = [[0]|[1]|[2]|[3]|[4]|[5]|[6]|[7]]
            
            ; xmm4 = [[0]|[1]|[2]|[3]|[4]|[5]|[6]|[7]] (en X)
            ; xmm0 = [[0]|[1]|[2]|[3]|[4]|[5]|[6]|[7]] (en Y)
            
            ;;;
            ;;; Suma de X e Y
            ;;;
            
            pmaxsw xmm0, XMM_ZERO               ;
            pmaxsw xmm4, XMM_ZERO               ; satura las derivadas a cero
                        
            paddw xmm0, xmm4                    ; suma las derivadas
            
            packuswb xmm0, XMM_ZERO             ; pasa los valores a bytes y satura a 0 y 255
            movq [edi + edx - 1], xmm0          ; vuelca los 8 resultados en el destino
            
            add edx, 8                          ; avanza a la siguiente columna de 8
            cmp edx, WIDTH                  
            
        jl cicloColumnas
        
        ; borro con negro la "basura" de las columnas borde
        mov word [edi], 0                       ; dos primeras columnas
        mov byte [edi + edx - 2], 0             ; última columna
        
        add esi, WIDTH                          ;
        add edi, WIDTH                          ; avanzan los punteros a la fila actual
        
        dec ecx
    jg cicloFilas
    
    pop ebx              ; restauro los registros
    pop edi    
    pop esi
    
    add esp, 4
    
    pop ebp              ; retorno
    xor eax, eax

ret

