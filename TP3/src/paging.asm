
%define PINTOR_PAGE_DIR   0xA000
%define TRADUC_PAGE_DIR   0xB000


%define PINTOR_PAGE_TABLE 0xC000
%define TRADUC_PAGE_TABLE 0xD000


BITS 32


; Directorio de paginas del pintor (0xA000)
dd PINTOR_PAGE_TABLE | 3

%rep 0x400 - 1
	dd 0				; 1023 paginas en blanco
%endrep

; Directorio de paginas del traductor (0xB000)
dd TRADUC_PAGE_TABLE | 3

%rep 0x400 - 1
	dd 0				; 1023 paginas en blanco
%endrep


; Tabla de paginas del pintor (0xC000)
%assign i 0x0000
%rep    0x400
	dd 	i | 3			;supervisor, read/write, present
	%assign i i+4096
%endrep

; Tabla de paginas del traductor (0xC000)
%assign i 0x0000
%rep    0x400
	dd 	i | 3			;supervisor, read/write, present
	%assign i i+4096
%endrep
