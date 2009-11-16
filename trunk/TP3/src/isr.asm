BITS 32
%include "macrosmodoprotegido.mac"
extern pic1_intr_end


; ----------------------------------------------------------------
; Interrupt Service Routines
; TODO: Definir el resto de las ISR
; ----------------------------------------------------------------

; global _isr0, _isr4, _isr6, _isr7, _isr8, _isr10, _isr11, _isr12, _isr13, _isr14, _isr16, _isr32
global _isr0, _isr32, _isr33
msgisr0: db 'EXCEPCION: Division por cero'
msgisr0_len equ $-msgisr0

_isr0:
; _isr4:
; _isr6:
; _isr7:
; _isr8:
; _isr10:
; _isr11:
; _isr12:
; _isr13:
; _isr14:
; _isr16:
	mov edx, msgisr0
	IMPRIMIR_TEXTO edx, msgisr0_len, 0x0C, 0, 0, 0x13000
    iret
	
_isr32:
    cli
    call next_clock
    sti
    iret


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
        mov al, 0x20 ;AGREAGMOS ESTO PORQUE SINO NO ANDA!
        out 0x20, al
	popad
	ret

isrmessage: db 'Clock:'
isrnumero: dd 0x00000000
isrmessage1: db '|'
isrmessage2: db '/'
isrmessage3: db '-'
isrmessage4: db '\'

_isr33:
        cli
        pushad
        in al, 0x60

        test al, 0x80
        jnz .saltar

        mov ebx, letra_null
        inc ebx
        cmp al, [scan_a]
        jz .cont
        inc ebx
        cmp al, [scan_c]
        jz .cont
        inc ebx
        cmp al, [scan_r]
        jz .cont
        inc ebx
        cmp al, [scan_e]
        jz .cont
        mov ebx, letra_null
    .cont:
        mov ecx, [columna]
        IMPRIMIR_TEXTO ebx, 1, 0x0A, 23, ecx, 0x13000

        inc dword [columna]
    .saltar:
        mov al, 0x20
        out 0x20, al

        popad
        sti
        iret

columna: dd 0x0000000A
letra_null: db ' '
letra_a: db 'a'
letra_c: db 'c'
letra_r: db 'r'
letra_e: db 'e'
scan_a: db 0x1E
scan_c: db 0x2E
scan_r: db 0x13
scan_e: db 0x12