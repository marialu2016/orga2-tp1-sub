BITS 32
%include "macrosmodoprotegido.mac"
extern pic1_intr_end


; ----------------------------------------------------------------
; Interrupt Service Routines
; TODO: Definir el resto de las ISR
; ----------------------------------------------------------------

global _isr0, _isr4, _isr6, _isr7, _isr8, _isr10, _isr11, _isr12, _isr13, _isr14, _isr16, _isr32
;global _isr0, _isr32, _isr33
msgisr0: db 'EXCEPCION: Division por cero'
msgisr0_len equ $-msgisr0
_isr0:
	mov edx, msgisr0
	IMPRIMIR_TEXTO edx, msgisr0_len, 0x0C, 0, 0, 0x13000
	jmp $
    iret

msgisr4: db 'EXCEPCION: OVERFLOW'
msgisr4_len equ $-msgisr4
_isr4:
    mov edx, msgisr4
    IMPRIMIR_TEXTO edx, msgisr4_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

msgisr6: db 'EXCEPCION: INVALID OPCODE'
msgisr6_len equ $-msgisr6
_isr6:
    mov edx, msgisr6
    IMPRIMIR_TEXTO edx, msgisr6_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret
	
msgisr7: db 'EXCEPCION: DEVICE NOT AVAILABLE'
msgisr7_len equ $-msgisr7
_isr7:
    mov edx, msgisr7
    IMPRIMIR_TEXTO edx, msgisr7_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

msgisr8: db 'EXCEPCION: DOUBLE FAULT'
msgisr8_len equ $-msgisr8
_isr8:
    mov edx, msgisr8
    IMPRIMIR_TEXTO edx, msgisr8_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

msgisr10: db 'EXCEPCION: INVALID TSS'
msgisr10_len equ $-msgisr10
_isr10:
    mov edx, msgisr10
    IMPRIMIR_TEXTO edx, msgisr10_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

msgisr11: db 'EXCEPCION: SEGMENT NOT PRESENT'
msgisr11_len equ $-msgisr11
_isr11:
    mov edx, msgisr11
    IMPRIMIR_TEXTO edx, msgisr11_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

msgisr12: db 'EXCEPCION: STACK-SEGMENT FAULT'
msgisr12_len equ $-msgisr12
_isr12:
    mov edx, msgisr12
    IMPRIMIR_TEXTO edx, msgisr12_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

msgisr13: db 'EXCEPCION: GENERAL PROTECTION'
msgisr13_len equ $-msgisr13
_isr13:
    mov edx, msgisr13
    IMPRIMIR_TEXTO edx, msgisr13_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

msgisr14: db 'EXCEPCION: PAGE FAULT'
msgisr14_len equ $-msgisr14
_isr14:
    xchg bx, bx
    mov edx, msgisr14
    IMPRIMIR_TEXTO edx, msgisr14_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

msgisr16: db 'EXCEPCION: FPU ERROR'
msgisr16_len equ $-msgisr16
_isr16:
    mov edx, msgisr16
    IMPRIMIR_TEXTO edx, msgisr16_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret


; Interrupción del reloj
_isr32:    
    cli
    ;xchg bx, bx
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