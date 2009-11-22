BITS 32
%include "macrosmodoprotegido.mac"
extern pic1_intr_end


; ----------------------------------------------------------------
; Interrupt Service Routines
; TODO: Definir el resto de las ISR
; ----------------------------------------------------------------

global _isr0, _isr1, _isr2, _isr3, _isr4, _isr5, _isr6, _isr7, _isr8, _isr9, _isr10, _isr11, _isr12, _isr13, _isr14, _isr15, _isr16, _isr17, _isr18, _isr19, _isr32

msgisr0: db 'EXCEPCION: Division por cero'
msgisr0_len equ $-msgisr0
_isr0:
	mov edx, msgisr0
	IMPRIMIR_TEXTO edx, msgisr0_len, 0x0C, 0, 0, 0x13000
	jmp $
    iret

msgisr1: db 'EXCEPCION: RESERVED'
msgisr1_len equ $-msgisr1
_isr1:
	mov edx, msgisr1
	IMPRIMIR_TEXTO edx, msgisr1_len, 0x0C, 0, 0, 0x13000
	jmp $
    iret

msgisr2: db 'EXCEPCION: NMI INTERRUPT'
msgisr2_len equ $-msgisr2
_isr2:
	mov edx, msgisr2
	IMPRIMIR_TEXTO edx, msgisr2_len, 0x0C, 0, 0, 0x13000
	jmp $
    iret

msgisr3: db 'EXCEPCION: BREAKPOINT'
msgisr3_len equ $-msgisr3
_isr3:
	mov edx, msgisr3
	IMPRIMIR_TEXTO edx, msgisr3_len, 0x0C, 0, 0, 0x13000
	jmp $
    iret

msgisr4: db 'EXCEPCION: OVERFLOW'
msgisr4_len equ $-msgisr4
_isr4:
    mov edx, msgisr4
    IMPRIMIR_TEXTO edx, msgisr4_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

msgisr5: db 'EXCEPCION: BOUND RANGE EXCEEDED'
msgisr5_len equ $-msgisr5
_isr5:
    mov edx, msgisr5
    IMPRIMIR_TEXTO edx, msgisr5_len, 0x0C, 0, 0, 0x13000
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

msgisr9: db 'EXCEPCION: COPROCESSOR SEGMENT OVERRUN'
msgisr9_len equ $-msgisr9
_isr9:
    mov edx, msgisr9
    IMPRIMIR_TEXTO edx, msgisr9_len, 0x0C, 0, 0, 0x13000
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

msgisr15: db 'EXCEPCION: INTEL RESERVERD'
msgisr15_len equ $-msgisr15
_isr15:
    xchg bx, bx
    mov edx, msgisr15
    IMPRIMIR_TEXTO edx, msgisr15_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

msgisr16: db 'EXCEPCION: FPU ERROR'
msgisr16_len equ $-msgisr16
_isr16:
    mov edx, msgisr16
    IMPRIMIR_TEXTO edx, msgisr16_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

msgisr17: db 'EXCEPCION: ALIGNMENT CHEHCK'
msgisr17_len equ $-msgisr17
_isr17:
    mov edx, msgisr17
    IMPRIMIR_TEXTO edx, msgisr17_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

msgisr18: db 'EXCEPCION: MACHINE CHECHK'
msgisr18_len equ $-msgisr18
_isr18:
    mov edx, msgisr18
    IMPRIMIR_TEXTO edx, msgisr18_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

msgisr19: db 'EXCEPCION: SIMD FLOATING-POINT'
msgisr19_len equ $-msgisr19
_isr19:
    mov edx, msgisr19
    IMPRIMIR_TEXTO edx, msgisr19_len, 0x0C, 0, 0, 0x13000
    jmp $
    iret

; Interrupción del reloj
_isr32:    
    cli
    call next_clock
    ;paso de tarea
    cmp BYTE [isrTarea], 0x0
    jne pasarAPintor    
    pasarATraductor:
    	mov BYTE [isrTarea], 0x1
    	xchg bx, bx
        jmp 0x30:0
        sti
        iret
    pasarAPintor:
    	mov BYTE [isrTarea], 0x0
    	xchg bx, bx
        jmp 0x28:0
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
isrTarea: db 0x0
