BITS 32
%include "macrosmodoprotegido.mac"
extern pic1_intr_end


; ----------------------------------------------------------------
; Interrupt Service Routines
; TODO: Definir el resto de las ISR
; ----------------------------------------------------------------

global _isr0
msgisr0: db 'EXCEPCION: Division por cero'
msgisr0_len equ $-msgisr0
_isr0:
	mov edx, msgisr0
	IMPRIMIR_TEXTO edx, msgisr0_len, 0x0C, 0, 0, 0x13000
	jmp $
	



; Funcion para dibujar el reloj.
; void next_clock(void)
next_clock:
	pushad
	inc DWORD [isrnumero]
	mov ebx, [isrnumero]
	cmp ebx, 0x4
	jl .ok
		mov DWORD [isrnumero], 0x0
		mov ebx, 0
	.ok:
		add ebx, isrmessage1
		mov edx, isrmessage
		IMPRIMIR_TEXTO edx, 6, 0x0A, 23, 1, 0x13000
		IMPRIMIR_TEXTO ebx, 1, 0x0A, 23, 8, 0x13000
	popad
	ret

isrmessage: db 'Clock:'
isrnumero: dd 0x00000000
isrmessage1: db '|'
isrmessage2: db '/'
isrmessage3: db '-'
isrmessage4: db '\'
