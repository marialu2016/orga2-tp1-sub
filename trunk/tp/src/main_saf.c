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
extern void asmPrewitt(const char* src, char* dst, int ancho, int alto, int xorder, int yorder);

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
    /**/IplImage * src = 0;
    /**/IplImage * dst = 0;
    
    if(argc <= 3) {
        mostrarUso();
        return 1;
    }
    
    const char* srcName = argv[1];
    const char* dstName = argv[2];
    
    char* prefix;
    char* extension;
    char* sufix;
    
    /**/src = cvLoadImage(srcName, CV_LOAD_IMAGE_GRAYSCALE);
    /**/if(!src) {
    /**/    printf("ERROR: no se pudo abrir la imagen fuente");
    /**/    return 1;
    /**/}
    
    
    char* dotIndex = strrchr(dstName, '.');
    if(dotIndex) {
        extension = malloc(strlen(dotIndex) + 1);
        extension = strcpy(extension, dotIndex);
        
        prefix = malloc(strlen(dstName) - strlen(extension) + 1);
        prefix = strncat(prefix, dstName, strlen(dstName) - strlen(extension));
    } else {
        extension = malloc(1);
        extension = "";
                
        prefix = malloc(strlen(dstName) + 1);
        prefix = strcpy(prefix, dstName);
    }
    
    int op;
    for(op = 3; op < argc; op = op + 1) {
        char* oper = argv[op];
        
        int tscl;
                     
        printf("---- Operador '%s'                                \n", oper);

        // Creo la imagen de OpenCV
        ////dst = cvCreateImage(cvGetSize(src), IPL_DEPTH_8U, 1);
                
        if(!strcmp(oper, "r1") || !strcmp(oper, "robxy")) {
            // Roberts XY
            sufix = "_robxy";
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            //////asmRoberts(src->imageData, dst->imageData, src->width, src->height);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
        /*    
        } else if(!strcmp(oper, "r2") || !strcmp(oper, "prexy")) {
            // Prewitt XY
            sufix = "_prexy";
            
        } else if(!strcmp(oper, "r3") || !strcmp(oper, "sobx")) {
            // Sobel X
            sufix = "_sobx";
            
        } else if(!strcmp(oper, "r4") || !strcmp(oper, "soby")) {
            // Sobel Y
            sufix = "_soby";
            
        } else if(!strcmp(oper, "r5") || !strcmp(oper, "sobxy")) {
            // Sobel XY
            sufix = "_sobxy";
        */
            
        } else if(!strcmp(oper, "s3") || !strcmp(oper, "sobxcv")) {
            // Sobel X (OPenCV)
            sufix = "_sobxcv";
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            ////cvSobel(src, dst, 1, 0, 3);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
        /*                
        } else if(!strcmp(oper, "s4") || !strcmp(oper, "sobycv")) {
            // Sobel Y (OPenCV)
            sufix = "_sobycv";
                        
        } else if(!strcmp(oper, "s5") || !strcmp(oper, "sobxycv")) {
            // Sobel XY (OPenCV)
            sufix = "_sobxycv";
            
        } else if(!strcmp(oper, "byn")) {
            // Escala de grises (sin efectos)
            sufix = "_byn";
        */    
        
        } else if(!strcmp(oper, "c3") || !strcmp(oper, "sobxc")) {
            // Sobel X (C)
            sufix = "_sobxc";
            ////tscl = cSobel(src->imageData, dst->imageData, src->width, src->height, 1, 0);
        
        } else {
                printf("  ERROR: No se reconoce el operador '%s'\n", oper);
                continue;
        }
        
        // Cantidad de clocks insumidos por el algoritmo.
        printf("El procesamiento tomó %d clocks", tscl); printf("\n");
        
        char* filename = malloc(strlen(prefix) + strlen(sufix) + strlen(extension) + 1);
        
        filename = strcat(filename, prefix);
        filename = strcat(filename, sufix);
        filename = strcat(filename, extension);
        
        printf("    Guardando en '%s'... ", filename);

        // Guardar resultado
        ////cvSaveImage(filename, dst);

        printf("OK\n");

        free(filename);
    }
    
    free(prefix);
    free(extension);
    
    return 0;
}

 
