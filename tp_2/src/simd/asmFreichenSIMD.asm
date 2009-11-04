;    Aplica el operador de Frei-chen a la imagen 'src' y almacena el
; resultado como una nueva imagen en 'dst', ambas de 'ancho' x 'alto' píxels. 
;    Se asume que 'ancho' es múltiplo de  16.
;
;void asmFreichenSIMD(const char* src, char* dst, int ancho, int alto);

global asmFreichenSIMD

%define SRC        [EBP+8]      ; donde empieza la matriz de la imagen original
%define DST        [EBP+12]     ; donde empieza la matriz de los datos a guardar
%define WIDTH_AUX  [EBP+16]     ; el ancho de la imagen
%define WIDTH      ebx          ; se usa ebx para WIDTH por razones de eficiencia;
%define HEIGHT     [EBP+20]     ; el alto de la imagen

%define RAIZ_2 [EBP-4]          ; constante raíz de dos


section .data

section .text

asmFreichenSIMD:
    
    ;;;; tiene mmx?
    mov eax, 1
    cpuid
    test edx, 0x4000000
    jnz hay_mmx
    
    inc edx          ; NO HAY sse2
    jmp sigue
    
    hay_mmx: inc edx ; HAY sse2
    sigue:
    ;;;;;;;;;;;;;;,
    
    
    
    push ebp        
    mov ebp, esp    ; creo el stack frame

    sub esp, 4

    push esi    ; salvo los registros según convencion c
    push edi    
    push ebx
    
    emms

    ;;;
    ;;; CONSTANTES XMM
    ;;;
    pxor xmm7, xmm7   ; xmm7 todo ceros
    
    ; xmm6 tiene raíces de dos precisión simple
    ;;movd xmm6, TWO                      ; xmm6 = [  0  |  0  |  0  |  2  ] (entero)
    ;;cvtdq2ps xmm6, xmm6                 ; castea a SP
    ;;sqrtss xmm6, xmm6                   ; xmm6 = [  0  |  0  |  0  |2^1/2] (entero)
    ;;shufps xmm6, xmm6, 00000000b        ; xmm6 = [2^1/2|2^1/2|2^1/2|2^1/2] (entero)
    
    finit
    fld1
    fadd st0, st0
    fsqrt
    ;movss xmm6, st0
    
    fstp dword RAIZ_2
    
    movss xmm6, RAIZ_2
    
    shufps xmm6, xmm6, 00000000b        ; xmm6 = [2^1/2|2^1/2|2^1/2|2^1/2] (entero)    
    
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;
    
    mov ebx, WIDTH_AUX        ; ebx = WIDTH

    ; Vamos a recorrer desde 0 hasta width - 2 y desde 0 hasta height - 2
    dec dword WIDTH
    dec dword WIDTH
    dec dword HEIGHT
    dec dword HEIGHT
    
    mov esi, SRC         ; esi y edi apuntan a la fila actual de src y dst respectivamente
    mov edi, DST
    
    xor ecx, ecx         ; ecx es el contador de filas
    

    cicloFilas:
        xor edx, edx         ; edx es el contador de columnas
        

        ;;; se levantará un bloque de 3x8 pixeles (comenzando en la fila ecx, columna edx, mem[esi+edx])
        ;;; con ello se calculará la derivada en X de la fila del medio
       
        cicloColumnas:

            ;;;
            ;;; LEVANTA LA PRIMERA FILA
            ;;;

            movdqu xmm0, [esi + edx]            ; xmm0 = [ | | | | | | | |0|1|2|3|4|5|6|7] (fila 1)
            
            punpcklbw xmm0, xmm7                ; xmm0 = [ 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 ] (fila 1)
            movdqu xmm1, xmm0                   ; xmm1 = xmm0
                                                
            punpckhwd xmm0, xmm7                ; xmm0 = [   0   |   1   |   2   |   3   ] (fila 1)
            punpcklwd xmm1, xmm7                ; xmm1 = [   4   |   5   |   6   |   7   ] (fila 1)
           
            cvtdq2ps xmm0, xmm0                 ; todos son bytes metidos en dwords: los convierto a SP
            cvtdq2ps xmm1, xmm1                 ; 
            
            ;;;
            ;;; LEVANTA LA SEGUNDA FILA
            ;;;
            
            add esi, WIDTH                      ; avanza de fila
            add esi, 2

            movq xmm2, [esi + edx]              ; xmm2 = [ | | | | | | | |0|1|2|3|4|5|6|7] (fila 2)
            
            punpcklbw xmm2, xmm7                ; xmm2 = [ 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 ] (fila 2)
            movdqu xmm3, xmm2                   ; xmm3 = xmm2
                                                
            punpckhwd xmm2, xmm7                ; xmm2 = [   0   |   1   |   2   |   3   ] (fila 2)
            punpcklwd xmm3, xmm7                ; xmm3 = [   4   |   5   |   6   |   7   ] (fila 2)
           
            cvtdq2ps xmm2, xmm2                 ; convierte las dwords enteras signadas a SP
            cvtdq2ps xmm3, xmm3                 ; 
            
            ;;;
            ;;; HACE f1 = f1 + f2 * sqr(2)
            ;;;
            
            mulps xmm2, xmm6                    ; multiplica segunda fila por sqr(2)
            mulps xmm3, xmm6                    ;
            
            addps xmm0, xmm2                    ; suma primera y segunda fila
            addps xmm1, xmm3                    ; en xmm0:xmm1 quedan las dos primeras filas ya comprimidas
            
            ;;;
            ;;; LEVANTA LA TERCERA FILA
            ;;;
            
            add esi, WIDTH                      ; avanza de fila
            add esi, 2

            movq xmm2, [esi + edx]              ; xmm2 = [ | | | | | | | |0|1|2|3|4|5|6|7] (fila 3)
            
            punpcklbw xmm2, xmm7                ; xmm2 = [ 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 ] (fila 3)
            movdqu xmm3, xmm2                   ; xmm3 = xmm2
                                                
            punpckhwd xmm2, xmm7                ; xmm2 = [   0   |   1   |   2   |   3   ] (fila 3)
            punpcklwd xmm3, xmm7                ; xmm3 = [   4   |   5   |   6   |   7   ] (fila 3)
           
            cvtdq2ps xmm2, xmm2                 ; convierte las dwords enteras signadas a SP
            cvtdq2ps xmm3, xmm3                 ; 
            
            ;;;
            ;;; SUMA LA FILA QUE FALTA (f1 = f1 + f3)
            ;;;
            
            addps xmm0, xmm2                    ; suma tercera fila
            addps xmm1, xmm3                    ; en xmm0:xmm1 quedan las tres filas comprimidas
            
            sub esi, WIDTH                      ; 
            sub esi, WIDTH                      ; IMPORTANTE: retrocede las filas
            sub esi, 4
                                    
            add edx, 8
            cmp edx, WIDTH
        jl cicloColumnas
        
        
        add esi, WIDTH
        add esi, 2
        
        add edi, WIDTH
        add edi, 2
        
        inc ecx
        cmp ecx, HEIGHT
    jl cicloFilas
    
    
    pop ebx              ; restauro los registros
    pop edi    
    pop esi
    
    add esp, 4
    
    pop ebp              ; retorno
    xor eax, eax

ret