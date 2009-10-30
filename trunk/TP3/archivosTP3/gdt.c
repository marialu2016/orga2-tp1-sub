#include "gdt.h"
#include "tss.h"


/*
 * Definicion de la GDT
 */
gdt_entry gdt[GDT_COUNT] = {
	/* Descriptor nulo*/
	(gdt_entry){ 
		(unsigned short) 0x0000, 
		(unsigned short) 0x0000,
		(unsigned char) 0x00, 
		(unsigned char) 0x0, 
		(unsigned char) 0, 
		(unsigned char) 0, 
		(unsigned char) 0, 
		(unsigned char) 0x0000,
		(unsigned char) 0,  
		(unsigned char) 0,  
		(unsigned char) 0,  
		(unsigned char) 0, 
		(unsigned char) 0x00 
	},

	/*
	* EL DESCRIPTOR DE CODIGO
	*/

	(gdt_entry){
		(unsigned short) 0xFFFF,	//limite [0:15]
		(unsigned short) 0x0000,	//base [16:31]
		(unsigned char) 0x00,		//base [16:23]
		(unsigned char) 0xA,		//tipo [24]
		(unsigned char) 1,		//S [25]
		(unsigned char) 0, 		//DPL [26:27]
		(unsigned char) 1,		//P [28]
		(unsigned char) 0xF,		//limite [16:19]
		(unsigned char) 0,		//AVL [20]
		(unsigned char) 0,		//L [21]
		(unsigned char) 1,		//DB [22]
		(unsigned char) 1,		//G [23]
		(unsigned char) 0x00		//BASE [24:31]
	},

	/*
	* EL DESCRIPTOR DE DATO
	*/
	(gdt_entry){
		(unsigned short) 0xFFFF,	//limite [0:15]
		(unsigned short) 0x0000,	//base [16:31]
		(unsigned char) 0x00,		//base []
		(unsigned char) 0x2,		//tipo [24]
		(unsigned char) 1,		//S [25]
		(unsigned char) 0, 		//DPL [26:27]
		(unsigned char) 1,		//P [28]
		(unsigned char) 0xF,		//limite [16:19]
		(unsigned char) 0,		//AVL [20]
		(unsigned char) 0,		//L [21]
		(unsigned char) 1,		//DB [22]
		(unsigned char) 1,		//G [23]
		(unsigned char) 0x00		//BASE [24:31]
	},
	/* EL DESC DE VIDEO */
	(gdt_entry){
		(unsigned short) 0x0F9F,	//limite [0:15]
		(unsigned short) 0x8000,	//base [16:31]
		(unsigned char) 0x0B,		//base []
		(unsigned char) 0x2,		//tipo [24]
		(unsigned char) 1,		//S [25]
		(unsigned char) 0, 		//DPL [26:27]
		(unsigned char) 1,		//P [28]
		(unsigned char) 0x0,		//limite [16:19]
		(unsigned char) 0,		//AVL [20]
		(unsigned char) 0,		//L [21]
		(unsigned char) 1,		//DB [22]
		(unsigned char) 0,		//G [23]
		(unsigned char) 0x00		//BASE [24:31]
	}
};

/*
 * Definicion del GDTR
 */ 
gdt_descriptor GDT_DESC = {sizeof(gdt)-1, (unsigned int)&gdt};
