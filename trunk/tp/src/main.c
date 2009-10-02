/**/#include <cv.h>
/**/#include <highgui.h>

#include "bordes.c"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * Implementación en assembly del operador de Roberts en X y en Y.
 */
extern void asmRoberts(const char* src, char* dst, int ancho, int alto);

/**
 * Implementación en assembly del operador de Prewitt en X, Y o ambos.
 */
extern void asmPrewitt(const char* src, char* dst, int ancho, int alto);

/**
 * Implementación en assembly del operador de Sobel en X, Y o ambos.
 */
extern void asmSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder);

/**
 * Implementación en C del operador de Sobel en X, Y o ambos.
 * Devuelve la cantidad de clocks insumidos por el algoritmo.
 */
int cSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder);

void mostrarUso() {
    printf("                                                                      "); printf("\n");
    printf(" Uso (si el ejecutable se llama 'bordes'):                            "); printf("\n");
    printf("                                                                      "); printf("\n");
    printf("            ./bordes ${src} ${dest} ${lista de operadores}            "); printf("\n");
    printf("                                                                      "); printf("\n");
    printf("    - ${src}: nombre del archivo de origen                            "); printf("\n");
    printf("    - ${dest}: nombre del archivo de salida                           "); printf("\n");
    printf("    - ${lista de operadores}: una o más de las siguientes expresiones:"); printf("\n");
    printf("                                                                      "); printf("\n");
    printf("        -'r1' o 'robxy': operador de Roberts (XY)                     "); printf("\n");
    printf("        -'r2' o 'prexy': operador de Prewitt (XY)                     "); printf("\n");
    printf("        -'r3' o 'sobx':  operador de Sobel (X)                        "); printf("\n");
    printf("        -'r4' o 'soby':  operador de Sobel (Y)                        "); printf("\n");
    printf("        -'r5' o 'sobxy': operador de Sobel (XY)                       "); printf("\n");
    printf("                                                                      "); printf("\n");
    printf("        -'cv3' o 'sobxcv':  como 'r3' pero usando OpenCV              "); printf("\n");
    printf("        -'cv4' o 'sobycv':  como 'r4' pero usando OpenCV              "); printf("\n");
    printf("        -'cv5' o 'sobxycv': como 'r5' pero usando OpenCV              "); printf("\n");
    printf("                                                                      "); printf("\n");
    printf("        -'c3' o 'sobxc':  como 'r3' pero implementado en C            "); printf("\n");
    printf("        -'c4' o 'sobyc':  como 'r3' pero implementado en C            "); printf("\n");
    printf("        -'c5' o 'sobxyc': como 'r3' pero implementado en C            "); printf("\n");
    printf("                                                                      "); printf("\n");
    printf("     El programa generará una imagen por cada operador solicitado. Si "); printf("\n");
    printf(" se especifica más de uno se agregará al nombre de destino un sufijo  "); printf("\n");
    printf(" indicando el operador utilizado para generar cada archivo, justo     "); printf("\n");
    printf(" antes de la extensión (por ejemplo '_sobxy').                        "); printf("\n");
    printf("                                                                      "); printf("\n");
}

/**
 * Dado el nombre de un archivo con una imagen, la transforma a escala de grises y genera imágenes
 * con sus bordes destacados usando los operadores especificados.
 * Ver contenido de la función mostrarUso() para más detalles.
 */
int main(int argc, char** argv) {
    /**/IplImage * src;
    /**/IplImage * dst;
    /**/IplImage * tmp;
    
    //char* srcName, dstName, oper;
    
    const char* srcName;
    const char* dstName;
    const char* oper;
    
    int tscl;
    
    if(argc != 4) {
        mostrarUso();
        return 1;
    }
    
    srcName = argv[1];
    dstName = argv[2];
    oper    = argv[3];
    
    /**/src = cvLoadImage(srcName, CV_LOAD_IMAGE_GRAYSCALE);
    /**/if(!src) {
    /**/    printf("ERROR: no se pudo abrir la imagen fuente");
    /**/    return 1;
    /**/}
    /**/if(src->origin != 0) {
    /**/    printf("Formato no reconocido: el 'origin' de OpenCV dio distinto a cero");
    /**/    return 1;
    /**/}
    
    printf("---- Operador '%s'                                \n", oper);

    // Creo la imagen de OpenCV
    /**/dst = cvCreateImage(cvGetSize(src), IPL_DEPTH_8U, 1);
                
    if(!strcmp(oper, "r1") || !strcmp(oper, "robxy")) {
        // Roberts XY
        __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
        /**/asmRoberts(src->imageData, dst->imageData, src->width, src->height);
        __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
        
    } else if(!strcmp(oper, "r2") || !strcmp(oper, "prexy")) {
        // Prewitt XY
        __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
        /**/asmPrewitt(src->imageData, dst->imageData, src->width, src->height);
        __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
        
    } else if(!strcmp(oper, "r3") || !strcmp(oper, "sobx")) {
        // Sobel X
        __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
        /**/asmSobel(src->imageData, dst->imageData, src->width, src->height, 1, 0);
        __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
    
    } else if(!strcmp(oper, "r4") || !strcmp(oper, "soby")) {
        // Sobel Y
        __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
        /**/asmSobel(src->imageData, dst->imageData, src->width, src->height, 0, 1);
        __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
    
    } else if(!strcmp(oper, "r5") || !strcmp(oper, "sobxy")) {
        // Sobel XY
        __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
        /**/asmSobel(src->imageData, dst->imageData, src->width, src->height, 1, 1);
        __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
    
       
    } else if(!strcmp(oper, "cv3") || !strcmp(oper, "sobxcv")) {
        // Sobel X (OPenCV)
        __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
        /**/cvSobel(src, dst, 1, 0, 3);
        __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
    
    } else if(!strcmp(oper, "cv4") || !strcmp(oper, "sobycv")) {
        // Sobel Y (OPenCV)
        __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
        /**/cvSobel(src, dst, 0, 1, 3);
        __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
    
    } else if(!strcmp(oper, "cv5") || !strcmp(oper, "sobxycv")) {
        // Sobel XY (OPenCV)
        __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
        /**/cvSobel(src, dst, 1, 1, 3);
        __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
    
    } else if(!strcmp(oper, "byn")) {
        // Escala de grises (sin efectos)
        tmp = src;
        src = dst;
        dst = tmp;
      
    } else if(!strcmp(oper, "c3") || !strcmp(oper, "sobxc")) {
        // Sobel X (C)
        /**/tscl = cSobel(src->imageData, dst->imageData, src->width, src->height, 1, 0);
    
    } else if(!strcmp(oper, "c4") || !strcmp(oper, "sobyc")) {
        // Sobel Y (C)
        /**/tscl = cSobel(src->imageData, dst->imageData, src->width, src->height, 0, 1);
    
    } else if(!strcmp(oper, "c5") || !strcmp(oper, "sobxyc")) {
        // Sobel XY (C)
        /**/tscl = cSobel(src->imageData, dst->imageData, src->width, src->height, 1, 1);
    
    } else {
        printf("    ERROR: No se reconoce el operador '%s'\n", oper);
        return 1;
    }
        
    // Cantidad de clocks insumidos por el algoritmo.
    printf("    El procesamiento tomó %d clocks", tscl); printf("\n");
        
    printf("    Guardando en '%s'...\n", dstName);

    // Guardar resultado
    /**/cvSaveImage(dstName, dst);

    printf("    OK\n");
  
    return 0;
}
