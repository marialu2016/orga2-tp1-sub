#include "isr.h"
#include "idt.h"


/*
 * Metodo para inicializar los descriptores de la IDT 
 */
void idtFill() {
	idt[0].offset_0_15 = (unsigned short) ((unsigned int)(&_isr0) & (unsigned int) 0xFFFF); \
	idt[0].segsel = (unsigned short) 0x0008; \
	idt[0].attr = (unsigned short) 0x8E00; \
	idt[0].offset_16_31 = (unsigned short) ((unsigned int)(&_isr0) >> 16 & (unsigned int) 0xFFFF);
	/*
	 * TODO: Completar inicializacion de la IDT aqui
	 * 
	 */
}

/*
 * IDT
 */ 
idt_entry idt[255] = {};

/*
 * Descriptor de la IDT (para cargar en IDTR)
 */
idt_descriptor IDT_DESC = {sizeof(idt)-1, (unsigned int)&idt};

