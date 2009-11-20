#include "tss.h"

#define TSS_COUNT 3
/*
 * Arreglo de TSSs 
 * TODO: Completar el resto de las TSSs
 */
tss tsss[TSS_COUNT] = {
    //TAREA DUMMY
    (tss) {
        (unsigned short) 0,
        (unsigned short) 0,
        (unsigned int) 0,
        (unsigned short) 0,
        (unsigned short) 0,
        (unsigned int) 0,
        (unsigned short) 0,
        (unsigned short)  0,
        (unsigned int) 0,
        (unsigned short) 0,
        (unsigned short) 0,
        (unsigned int) 0,
        (unsigned int) 0,
        (unsigned int) 0,
        (unsigned int) 0,
        (unsigned int) 0,
        (unsigned int) 0,
        (unsigned int) 0,
        (unsigned int) 0,
        (unsigned int) 0,
        (unsigned int) 0,
        (unsigned int) 0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0,
        (unsigned short)  0
    },
    //TAREA DEL PINTOR
    (tss) {
        (unsigned short) 0,    //ptl
        (unsigned short) 0,    //unused0
        (unsigned int) 0,    //esp0
        (unsigned short) 0,    //ss0
        (unsigned short) 0,    //unused1
        (unsigned int) 0,    //esp1
        (unsigned short) 0,    //ss1
        (unsigned short)  0,    //unused2
        (unsigned int) 0,    //esp2
        (unsigned short) 0,    //ss2
        (unsigned short) 0,    //u3
        (unsigned int) 0xA000,    //cr3 //????
        (unsigned int) 0x8000,    //eip
        (unsigned int) 0x202,    //eflags
        (unsigned int) 0,    //eax
        (unsigned int) 0,    //ecx
        (unsigned int) 0,    //edx
        (unsigned int) 0,    //ebx
        (unsigned int) 0x15FFF,    //esp
        (unsigned int) 0x15FFF,    //ebp
        (unsigned int) 0,    //esi
        (unsigned int) 0,    //edi
        (unsigned short)  0x10,    //es
        (unsigned short)  0,
        (unsigned short)  0x8,    //cs
        (unsigned short)  0,
        (unsigned short)  0x10,    //ss
        (unsigned short)  0,
        (unsigned short)  0x10,    //ds
        (unsigned short)  0,
        (unsigned short)  0x10,    //fs
        (unsigned short)  0,
        (unsigned short)  0x10,    //gs
        (unsigned short)  0,
        (unsigned short)  0,    //ldt
        (unsigned short)  0,
        (unsigned short)  0,    //dtrap
        (unsigned short)  0xFFFF//iomap
    },
    //TAREA DEL TRADUCTOR
    (tss) {
        (unsigned short) 0,    //ptl
        (unsigned short) 0,    //unused0
        (unsigned int) 50000,    //esp0
        (unsigned short) 0,    //ss0
        (unsigned short) 0,    //unused1
        (unsigned int) 0,    //esp1
        (unsigned short) 0,    //ss1
        (unsigned short)  0,    //unused2
        (unsigned int) 0,    //esp2
        (unsigned short) 0,    //ss2
        (unsigned short) 0,    //u3
        (unsigned int) 0xB000,    //cr3 //????
        (unsigned int) 0x9000,    //eip
        (unsigned int) 0x202,    //eflags
        (unsigned int) 0,    //eax
        (unsigned int) 0,    //ecx
        (unsigned int) 0,    //edx
        (unsigned int) 0,    //ebx
        (unsigned int) 0x16FFF,    //esp
        (unsigned int) 0x16FFF,    //ebp
        (unsigned int) 0,    //esi
        (unsigned int) 0,    //edi
        (unsigned short)  0x10,    //es
        (unsigned short)  0,
        (unsigned short)  0x8,    //cs
        (unsigned short)  0,
        (unsigned short)  0x10,    //ss
        (unsigned short)  0,
        (unsigned short)  0x10,    //ds
        (unsigned short)  0,
        (unsigned short)  0x10,    //fs
        (unsigned short)  0,
        (unsigned short)  0x10,    //gs
        (unsigned short)  0,
        (unsigned short)  0,    //ldt
        (unsigned short)  0,
        (unsigned short)  0,    //dtrap
        (unsigned short)  0xFFFF//iomap
    }
    
};
