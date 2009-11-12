
%define PINTOR_PAGE_DIR   0xA000
%define TRADUC_PAGE_DIR   0xB000

%define PINTOR_PAGE_TABLE 0xC000
%define TRADUC_PAGE_TABLE 0xD000

BITS 32


; Directorio de paginas del pintor (0xA000)
    dd PINTOR_PAGE_TABLE | 3
    
    %rep 0x400 - 1
        dd 0                ; 1023 paginas en blanco
    %endrep

; Directorio de paginas del traductor (0xB000)
    dd TRADUC_PAGE_TABLE | 3
    
    %rep 0x400 - 1
        dd 0                ; 1023 paginas en blanco
    %endrep


; Tabla de paginas del pintor (0xC000)
    dd 0x0000 | 3            ; kernel
    dd 0x1000 | 3            ;
    dd 0x2000 | 3            
    dd 0x3000 | 3
    dd 0x4000 | 3
    dd 0x5000 | 3
    dd 0x6000 | 3
    dd 0x7000 | 3
    
    dd 0x8000 | 3            ; tarea del pintor
    
    dd 0x0000            ; 0x9000
    dd 0x0000            ; 0xA000
    dd 0x0000            ; 0xB000
    dd 0x0000            ; 0xC000
    dd 0x0000            ; 0xD000
    
    dd 0xE000 | 3            ; 0xE000   GDT, IDT, TSS
    dd 0xF000 | 3        ; 0xF000   GDT, IDT, TSS
    
    dd 0x0000            ; 0x10000
    dd 0x0000            ; 0x11000
    dd 0x0000            ; 0x12000
    
    dd 0xb8000 | 3      ; 0x13000     (mapeado a video)
    
    dd 0x0000            ; 0x14000
    
    dd 0x15000 | 3        ; 0x15000
    
    %rep 0xB8 - 0x16    ; (desde 0x16 hasta 0xB8...)
        dd 0x0000
    %endrep
    
    dd 0x10000 | 3        ; 0xB8000
    
    %rep 0x400 - 0xB9    ; (desde 0xB9 hasta 0x400...)
        dd 0x0000
    %endrep

; Tabla de paginas del traductor (0xC000)

    dd 0x0000 | 3            ; kernel
    dd 0x1000 | 3            ;
    dd 0x2000 | 3            
    dd 0x3000 | 3
    dd 0x4000 | 3
    dd 0x5000 | 3
    dd 0x6000 | 3
    dd 0x7000 | 3
    
    dd 0                   ; 0x8000
    
    dd 0x9000 | 3            ; tarea de traductor
    dd 0xA000 | 3            ; dir y tablas
    dd 0xB000 | 3            ;
    dd 0xC000 | 3            ;
    dd 0xD000 | 3            ; /
    dd 0xE000 | 3            ; GDT, IDT, TSS
    dd 0xF000 | 3            ; /
    dd 0x10000 | 3           ; Espacio de lectura del traductor
    
    dd 0                   ; 0x11000
    dd 0                   ; 0x12000
    
    dd 0xB8000 | 3         ; 0x13000 a video
    
    dd 0                   ; 0x14000
    dd 0                   ; 0x15000
    
    dd 0x16000 | 3         ; 0x16000    pila del traductor
    
    dd 0                   ; 0x17000
    dd 0xB8000 | 3         ; 0x18000 a video
    
    %rep 0xA0 - 0x19       ;desde 0x19 hasta 0xA0...
        dd 0    
    %endrep
    
    %assign i 0xA0000
    %rep 0xC0 - 0xA0       ; desde 0xA0000 a 0xC0000 identity
        dd i | 3
        %assign i i + 0x1000
    %endrep
    
    ;Completamos con cero hasta el final!
    %rep 0x400 - 0xC0 + 1   ; (desde 0xC1 hasta 0x400...)
        dd 0x0000
    %endrep
