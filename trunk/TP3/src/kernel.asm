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
		cli					;no me interrumpan por ahora, estoy ocupado
		jmp 	bienvenida

;aca ponemos todos los mensajes		
iniciando: db 'Iniciando el kernel mas inutil del mundo'
iniciando_len equ $ - iniciando		


bienvenida:
	IMPRIMIR_MODO_REAL iniciando, iniciando_len, 0x07, 0, 0
	; Ejercicios AQUI


		; TODO: Habilitar A20
		CALL enable_A20
		CALL check_A20

		; TODO: Dehabilitar Interrupciones
		cli


	; Ejercicio 1
		
		; Cargamos el descriptor de la GDT
		lgdt [GDT_DESC]
		
		; Pasamos a modo protegido
		mov 	eax, cr0
		or  	eax, 01h
		mov 	cr0, eax
		jmp 0x08:modoprotegido
BITS 32
		modoprotegido:
                        ;Apuntamos 'es' a la memoria de video y los demas al segmento de datos

			mov ax, 0x10	; segmento de datos
			mov bx, 0x18	; memoria de video
			mov ds, ax
			mov fs, ax
			mov gs, ax
			mov ss, ax
			mov es, bx	; es apunta a la memoria de video
	                       
                        ; Pintamos de negro la pantalla
			mov ecx, 80*25	;toda la pantalla
			xor esi, esi

			mov ax, 0x0000	; negro, ningun caracter
			cleanPantalla:
				mov [es:esi], ax         
				add esi, 2	; avanza al siguiente caracter
				loop cleanPantalla


                        ; Dibujamos bordes horizontales
			mov ah, 0x0F		; blanco brillante, fondo negro
			mov al, 0x02		; caracter carita
			xor esi, esi 
			mov edi, 80*24*2
			mov ecx, 80
			bordeHor:
				mov [es:esi], ax
				mov [es:edi], ax
				add esi, 2
				add edi, 2
				loop bordeHor
			
			xchg ebx,ebx

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
	; Ejercicio 2

		; TODO: Habilitar paginacion
		mov eax, 0xA000		;cargo la direccion del directorio en cr3
		mov cr3, eax
	
		mov eax, cr0
		or  eax, 0x80000000		;habilito paginacion
		mov cr0, eax

		jmp $
	
	; Ejercicio 3
	
		; TODO: Inicializar la IDT
		; TODO: Resetear la pic

		
; 	pic_reset:
; 		mov al, 11h
; 		out 20h, al
; 
; 		mov al, 20h
; 		out 21h, al
; 
; 		mov al, 04h
; 		out 21h, al
; 
; 		mov al, 01h
; 		out 21h, al
; 
; 		mov al, 0xFF
; 		out 21h, al
; 
; 		mov al, 0x11
; 		out 0xA1, al
; 
; 		mov al, 0x28
; 		out 0xA1, al
; 
; 		mov al, 0x02
; 		out 0xA1, al
; 
; 		mov al, 0x01
; 		out 0xA1, al
; 
; 		mov al, 0xFF
; 		out 0xA1, al
; 	pic_enable:
; 		mov al, 0x00
; 		out 0x21, al
; 		mov al, 0x00
; 		out 0xA1, al
; 
; 		; TODO: Cargar el registro IDTR
; 		sti
; 	jmp $
	; Ejercicio 4
	
		; TODO: Inicializar las TSS
		
		; TODO: Inicializar correctamente los descriptores de TSS en la GDT
		
		; TODO: Cargar el registro TR con el descriptor de la GDT de la TSS actual
		
		; TODO: Habilitar la PIC
		
		; TODO: Habilitar Interrupciones
		
		; TODO: Saltar a la primer tarea
		
		
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
