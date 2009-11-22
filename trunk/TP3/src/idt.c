#include "isr.h"
#include "idt.h"

#define IDT_ENTRY(numero) \
	idt[numero].offset_0_15 = (unsigned short) ((unsigned int)(&_isr ## numero) & (unsigned int) 0xFFFF); \
	idt[numero].segsel = (unsigned short) 0x0008; \
	idt[numero].attr = (unsigned short) 0x8E00; \
	idt[numero].offset_16_31 = (unsigned short) ((unsigned int)(&_isr ## numero) >> 16 & (unsigned int) 0xFFFF);

/*
 * Metodo para inicializar los descriptores de la IDT 
 */
void idtFill() {
	/*
	 * TODO: Completar inicializacion de la IDT aqui
	 * 
	 */
    IDT_ENTRY(0) //DIVISION POR CERO
    IDT_ENTRY(1) //RESERVED
    IDT_ENTRY(2) //NMI INTERRUPT
    IDT_ENTRY(3) //BREAKPOINT
    IDT_ENTRY(4) //OVERFLOW
    IDT_ENTRY(5) //BOUND RANGE EXCEEDED
    IDT_ENTRY(6) //INVALID OPCODE
    IDT_ENTRY(7) //DEVICE NOT AVAILABLE
    IDT_ENTRY(8) //DOUBLE FAULT
    IDT_ENTRY(9) //COPROCESSOR SEGMENT OVERRUN
    IDT_ENTRY(10)//INVALID TSS
    IDT_ENTRY(11)//SEGMENT NOT PRESENT
    IDT_ENTRY(12)//STACK-SEGMENT FAULT
    IDT_ENTRY(13)//GENERAL PROTECTION
    IDT_ENTRY(14)//PAGE FAULT
    IDT_ENTRY(15)//INTEL RESERVERD
    IDT_ENTRY(16)//FPU ERROR
    IDT_ENTRY(17)//ALIGNMENT CHEHCK
    IDT_ENTRY(18)//MACHINE CHECHK
    IDT_ENTRY(19)//SIMD FLOATING-POINT
    IDT_ENTRY(32)//RELOJ
    //IDT_ENTRY(33)//TECLADO 
}

/*
 * IDT
 */ 
idt_entry idt[255] = {};

/*
 * Descriptor de la IDT (para cargar en IDTR)
 */
idt_descriptor IDT_DESC = {sizeof(idt)-1, (unsigned int)&idt};

