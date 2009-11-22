#ifndef __ISR_H__
#define __ISR_H__

/*
 * Interrupt Service Routines
 * TODO: Agregar el resto de las ISR
 */
void _isr0(); //DIVIDE ERROR
void _isr1(); //RESERVED
void _isr2(); //NMI INTERRUPT
void _isr3(); //BREAKPOINT
void _isr4(); //OVERFLOW
void _isr5(); //BOUND RANGE EXCEEDED
void _isr6(); //INVALID OPCODE
void _isr7(); //DEVICE NOT AVAILABLE
void _isr8(); //DOUBLE FAULT
void _isr9(); //COPROCESSOR SEGMENT OVERRUN
void _isr10();//INVALID TSS
void _isr11();//SEGMENT NOT PRESENT
void _isr12();//STACK-SEGMENT FAULT
void _isr13();//GENERAL PROTECTION
void _isr14();//PAGE FAULT
void _isr15();//INTEL RESERVERD
void _isr16();//FPU ERROR
void _isr17();//ALIGNMENT CHEHCK
void _isr18();//MACHINE CHECHK
void _isr19();//SIMD FLOATING-POINT
void _isr32(); //RELOJ
//void _isr33();//TECLADO
/* **************************************************************
 * Funciones Auxiliares
 * **************************************************************
 */ 

/*
 * Funcion para dibujar el reloj
 */
void next_clock(void); 
#endif // __ISR_H__
