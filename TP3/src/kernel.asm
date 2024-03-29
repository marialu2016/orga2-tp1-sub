BITS 16

%include "macrosmodoreal.mac"

global start
extern GDT_DESC
extern gdt;
extern IDT_DESC
extern idtFill
extern tsss;


;Aca arranca todo, en el primer byte.
start:
        cli                    ;no me interrumpan por ahora, estoy ocupado
        jmp     bienvenida

;aca ponemos todos los mensajes        
iniciando: db 'Iniciando el kernel mas inutil del mundo'
iniciando_len equ $ - iniciando        


bienvenida:
    IMPRIMIR_MODO_REAL iniciando, iniciando_len, 0x07, 0, 0

        CALL enable_A20             ; activamos A20
        CALL check_A20

        cli                         ; Deshabilitamos interrupciones


    ; Ejercicio 1
        
        ; Cargamos el descriptor de la GDT
        lgdt [GDT_DESC]
        
        ; Pasamos a modo protegido
        mov     eax, cr0
        or      eax, 01h
        mov     cr0, eax
        
        jmp 0x08:modoprotegido

BITS 32
        modoprotegido:
            ;Apuntamos 'es' a la memoria de video y los demas al segmento de datos
            mov ax, 0x10    ; segmento de datos
            mov bx, 0x18    ; memoria de video
            mov ds, ax
            mov fs, ax
            mov gs, ax
            mov ss, ax
            mov es, bx    ; es apunta a la memoria de video
                           
            ; Pintamos de negro la pantalla
            mov ecx, 80*25    ;toda la pantalla
            xor esi, esi

            mov ax, 0x0000    ; negro, ningun caracter
            
            cleanPantalla:
                mov [es:esi], ax         
                add esi, 2    ; avanza al siguiente caracter
            loop cleanPantalla

            ; Dibujamos bordes horizontales
            mov ah, 0x0F        ; blanco brillante, fondo negro
            mov al, 0x02        ; caracter carita
            xor esi, esi 
            mov edi, 80*24*2
            mov ecx, 80
            bordeHor:
                mov [es:esi], ax
                mov [es:edi], ax
                add esi, 2
                add edi, 2
            loop bordeHor

            ; Dibujamos bordes verticales
            xor esi, esi
            mov edi, 79*2
            mov ecx, 25
            bordeVer:
                mov [es:esi], ax
                mov [es:edi], ax
                add esi, 80*2
                add edi, 80*2
            loop bordeVer

            ; BREAKPOINT
            xchg bx, bx

    ; Ejercicio 2
        ; 2a - Mapeo de la memoria con paginas
        mov eax, 0xA000        ;cargo la direccion del directorio en cr3
        mov cr3, eax
        
        mov eax, cr0
        or  eax, 0x80000000        ;habilito paginacion
        mov cr0, eax
        
        ; 2b - Escribir "Orga2   SUB!!!" en la pantalla
        mov     ecx, mensaje_len
        
        ; Usamos 0x13000 porque apunta a la memoria de video
        mov     edi, 0x13000 + 80 * 2 + 2   ; escribimos desde la posicion (1,1) (segunda fila y columna)
        
        mov     ah, 0x1A                    ; letras verdes, fondo azul
        mov     esi, mensaje
        
        .ciclo:
            mov al, [esi]
            mov [edi], ax
            inc esi
            add edi, 2
        loop .ciclo
        
        jmp fin_mensaje
        mensaje: db "Orga 2   SUB!!!"
        mensaje_len equ $ - mensaje
        fin_mensaje:

        ; BREAKPOINT
        xchg bx, bx        

    ; Ejercicio 3
    
        ; TODO: Inicializar la IDT
        call idtFill
        ; TODO: Resetear la pic
        pic_reset:
            mov al, 11h
            out 20h, al

            mov al, 20h
            out 21h, al

            mov al, 04h
            out 21h, al

            mov al, 01h
            out 21h, al

            mov al, 0xFF
            out 21h, al

            mov al, 0x11
            out 0xA1, al

            mov al, 0x28
            out 0xA1, al

            mov al, 0x02
            out 0xA1, al

            mov al, 0x01
            out 0xA1, al

            mov al, 0xFF
            out 0xA1, al
       

            ; TODO: Cargar el registro IDTR
            lidt[IDT_DESC]
            
    ; Ejercicio 4
    
        ; TODO: Inicializar las TSS
        
        ; TODO: Inicializar correctamente los descriptores de TSS en la GDT
        xchg bx, bx
        mov eax, gdt
        add eax, 0x20

        mov ebx, tsss
 
        mov [eax+2], bx
        shr ebx, 16
        mov [eax+4], bl
        mov [eax+7], bh

        add eax, 8 

        mov ebx, tsss
        add ebx, 104

        mov [eax+2], bx
        shr ebx, 16
        mov [eax+4], bl
        mov [eax+7], bh

        add eax, 8 

        mov ebx, tsss
        add ebx, 104
        add ebx, 104

        mov [eax+2], bx
        shr ebx, 16
        mov [eax+4], bl
        mov [eax+7], bh


        ; TODO: Cargar el registro TR con el descriptor de la GDT de la TSS actual
        ; BREAKPOINT
        xchg bx, bx 


        mov ax, 0x20
        ltr ax
        ; TODO: Habilitar la PIC
         pic_enable:
            mov al, 0x00
            out 0x21, al
            mov al, 0x00
            out 0xA1, al
        ; TODO: Habilitar Interrupciones
        sti
        ; TODO: Saltar a la primer tarea
        jmp 0x28:0
        
%include "a20.asm"

%define TASK1INIT 0x8000
%define TASK2INIT 0x9000
%define KORG 0x1200

TIMES TASK1INIT - KORG - ($ - $$) db 0x00

; 0x8000
incbin "pintor.tsk"

; 0x9000
incbin "traductor.tsk"
TIMES 0xA000 - KORG - ($ - $$) db 0x00

; 0xA000
%include "paging.asm"
