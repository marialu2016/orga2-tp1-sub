#ifndef __IDT_H__
#define __IDT_H__

/*
 * Interrupt Descriptor Table
 * Definicion de las estructuras de la IDT.
 */


/* 
 * Struct de descriptor de IDT 
 */
typedef struct str_idt_descriptor {
	unsigned short idt_length;
	unsigned int idt_addr;
} __attribute__((__packed__)) idt_descriptor;

/* 
 * Struct de una entrada de la IDT 
 */
typedef struct str_idt_entry_fld {
		unsigned short offset_0_15;
		unsigned short segsel;
		unsigned short attr;
		unsigned short offset_16_31;
} __attribute__((__packed__, aligned (8))) idt_entry;

/*
 * La IDT
 */
extern idt_entry idt[];

/*
 * El descriptor de la IDT
 */
extern idt_descriptor IDT_DESC;


/*
 * Metodo para inicializar los descriptores de la IDT 
 */
void idtFill();

#endif //__IDT_H__
