#include <cv.h>
#include <highgui.h>

//#include "gpr/bordes.c"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**************** Implementaciones SIMD *****************/
/* 
 * Todas usan registros XMM con el formato de 8 enteros empaquetados de 16 bits
 * con signo, salvo asmFreichenSIMD(...) que los utiliza como 4 flotantes de
 * precisión sencilla.
 */

/* Roberts en X e Y. */
extern void simdRoberts(const char* src, char* dst, int ancho, int alto);

/* Prewitt en X e Y. */
extern void simdPrewitt(const char* src, char* dst, int ancho, int alto);

/* Sobel en X, Y o ambos. */
extern void simdSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder);

/* Frei-chen en X e Y. */
extern void simdFreichen(const char* src, char* dst, int ancho, int alto);


/**************** Implementaciones GPR *****************/
/* Implementaciones realizadas en la parte 1 del trabajo con IA-32 básica. */

/* Roberts en X e Y. */
extern void asmRoberts(const char* src, char* dst, int ancho, int alto);

/* Prewitt en X e Y. */
extern void asmPrewitt(const char* src, char* dst, int ancho, int alto);

/* Sobel en X, Y o ambos. */
extern void asmSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder);

/**************** Implementaciones en C *****************/

int cSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder);

int cFreichen(const char* src, char* dst, int ancho, int alto, int xorder, int yorder);

int cRoberts(const char* src, char* dst, int ancho, int alto, int xorder, int yorder);

int cPrewitt(const char* src, char* dst, int ancho, int alto, int xorder, int yorder);


/**************** Utilidades ********************/
/** Devuelve true si los strings son iguales. */
int cmp(const char* s1, const char* s2);

void mostrarUso() {
    printf("                                                                      "); printf("\n");
    printf("    USO:    ./bordes $src $dest ${lista de operadores}                "); printf("\n");
    printf("                                                                      "); printf("\n");
    printf("    - $src: nombre del archivo de origen                              "); printf("\n");
    printf("    - $dest: nombre del archivo de salida SIN EXTENSIÓN               "); printf("\n");
    printf("    - ${lista de operadores}: una o más de las siguientes claves:     "); printf("\n");
    printf("                                                                      "); printf("\n");
    printf("             CLAVE | OPERADOR  | DIRECCION | IMPLEMENTACIÓN           "); printf("\n");
    printf("            -------+-----------+-----------+----------------          "); printf("\n");
    printf("              r1   |  Roberts  |    XY     |  asm + sse               "); printf("\n");
    printf("              r2   |  Prewitt  |    XY     |      \"                  "); printf("\n");
    printf("              r3   |   Sobel   |    X      |      \"                  "); printf("\n");
    printf("              r4   |   Sobel   |    Y      |      \"                  "); printf("\n");
    printf("              r5   |   Sobel   |    XY     |      \"                  "); printf("\n");
    printf("              r6   | Frei-chen |    XY     |      \"                  "); printf("\n");
    printf("                   |           |           |                          "); printf("\n");
    printf("              a1   |  Roberts  |    XY     |asm g. purpose            "); printf("\n");
    printf("              a2   |  Prewitt  |    XY     |      \"                  "); printf("\n");
    printf("              a3   |   Sobel   |    X      |      \"                  "); printf("\n");
    printf("              a4   |   Sobel   |    Y      |      \"                  "); printf("\n");
    printf("              a5   |   Sobel   |    XY     |      \"                  "); printf("\n");
    printf("                   |           |           |                          "); printf("\n");
    printf("              cv3  |   Sobel   |    X      |    OpenCV                "); printf("\n");
    printf("              cv4  |   Sobel   |    Y      |      \"                  "); printf("\n");
    printf("              cv5  |   Sobel   |    XY     |      \"                  "); printf("\n");
    printf("                   |           |           |                          "); printf("\n");
    printf("            c1...c6|   (idem)  |   (idem)  |      C                   "); printf("\n");
    printf("                   |           |           |                          "); printf("\n");
    printf("              byn  |   Escala de grises    |                          "); printf("\n");
    printf("                   |           |           |                          "); printf("\n");
    printf("     El programa generará una imagen por cada operador solicitado. El "); printf("\n");
    printf(" nombre de los archivos de salida será $dest más un guión bajo más el "); printf("\n");
    printf(" operador utilizado más la extensión (obtenida del archivo fuente).   "); printf("\n");
}

/**
 * Dado el nombre de un archivo con una imagen, la transforma a escala de grises y genera imágenes
 * con sus bordes destacados usando los operadores especificados.
 * Ver contenido de la función mostrarUso() para más detalles.
 */
int main(int argc, char** argv) {
    IplImage * src;
    IplImage * dst;
        
    const char* srcName;
    const char* dstName;
    const char* oper;
    
    //char* sufijo;
    char* extension;
    char* filename;
    
    int dotIndex;
    int tscl;
    int op;
    int usarSrc;
    
    // Operadores que ingresa el usuario
    const char* robertsSIMD_XY =  "r1";
    const char* prewittSIMD_XY =  "r2";
    const char* sobelSIMD_X =     "r3";
    const char* sobelSIMD_Y =     "r4";
    const char* sobelSIMD_XY =    "r5";
    const char* freichenSIMD_XY = "r6";
    
    const char* robertsASM_XY =   "a1";
    const char* prewittASM_XY =   "a2";
    const char* sobelASM_X =      "a3";
    const char* sobelASM_Y =      "a4";
    const char* sobelASM_XY =     "a5";
   
    const char* sobelCV_X =       "cv3";
    const char* sobelCV_Y =       "cv4";
    const char* sobelCV_XY =      "cv5";

    const char* robertsC_XY =     "c1";
    const char* prewittC_XY =     "c2";
    const char* sobelC_X =        "c3";
    const char* sobelC_Y =        "c4";
    const char* sobelC_XY =       "c5";
    const char* freichenC_XY =    "c6";

    const char* byn = "byn";
    
    if(argc < 4) {
        mostrarUso();
        return 1;
    }
    
    srcName = argv[1];
    dstName = argv[2];
    
    extension = strrchr(srcName, '.');
        
    src = cvLoadImage(srcName, CV_LOAD_IMAGE_GRAYSCALE);
    if(!src) {
        printf("ERROR: no se pudo abrir la imagen fuente");
        return 1;
    }
    if(src->origin != 0) {
        printf("Formato no reconocido: el 'origin' de OpenCV dio distinto a cero");
        return 1;
    }
    
    // Por cada operador solicitado...
    for(op = 3; op < argc; op++) {
        
        oper = argv[op];
        usarSrc = 0;
        
        printf("---- Operador '%s'                                \n", oper);
        
        // Creo la imagen de OpenCV
        dst = cvCreateImage(cvGetSize(src), IPL_DEPTH_8U, 1);
                    
        if(cmp(oper, robertsASM_XY)) {
            // Roberts XY
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            asmRoberts(src->imageData, dst->imageData, src->width, src->height);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
            
        } else if(cmp(oper, prewittASM_XY)) {
            // Prewitt XY
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            asmPrewitt(src->imageData, dst->imageData, src->width, src->height);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
            
        } else if(cmp(oper, sobelASM_X)) {
            // Sobel X
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            asmSobel(src->imageData, dst->imageData, src->width, src->height, 1, 0);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
        
        } else if(cmp(oper, sobelASM_Y)) {
            // Sobel Y
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            asmSobel(src->imageData, dst->imageData, src->width, src->height, 0, 1);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
        
        } else if(cmp(oper, sobelASM_XY)) {
            // Sobel XY
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            asmSobel(src->imageData, dst->imageData, src->width, src->height, 1, 1);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
               
        } else if(cmp(oper, sobelCV_X)) {
            // Sobel X (OPenCV)
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            cvSobel(src, dst, 1, 0, 3);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
        
        } else if(cmp(oper, sobelCV_Y)) {
            // Sobel Y (OPenCV)
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            cvSobel(src, dst, 0, 1, 3);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
        
        } else if(cmp(oper, sobelCV_XY)) {
            // Sobel XY (OPenCV)
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            cvSobel(src, dst, 1, 1, 3);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
        
        } else if(cmp(oper, robertsC_XY)) {
            // Roberts XY (C)
            tscl = cRoberts(src->imageData, dst->imageData, src->width, src->height, 1, 1);
        
        } else if(cmp(oper, prewittC_XY)) {
            // Prewitt XY (C)
            tscl = cPrewitt(src->imageData, dst->imageData, src->width, src->height, 1, 1);
        
        } else if(cmp(oper, sobelC_X)) {
            // Sobel X (C)
            tscl = cSobel(src->imageData, dst->imageData, src->width, src->height, 1, 0);
        
        } else if(cmp(oper, sobelC_Y)) {
            // Sobel Y (C)
            tscl = cSobel(src->imageData, dst->imageData, src->width, src->height, 0, 1);
        
        } else if(cmp(oper, sobelC_XY)) {
            // Sobel XY (C)
            tscl = cSobel(src->imageData, dst->imageData, src->width, src->height, 1, 1);
            
        } else if(cmp(oper, freichenC_XY)) {
            // Frei-chen XY (C)
            tscl = cFreichen(src->imageData, dst->imageData, src->width, src->height, 1, 1);
        
        } else if(cmp(oper, byn)) {
            // Escala de grises (sin ninguna detección de bordes)
            tscl = 0;
            usarSrc = 1;
        
        } else if(cmp(oper, robertsSIMD_XY)) {
            // Roberts usando SIMD
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            simdRoberts(src->imageData, dst->imageData, src->width, src->height);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));

        } else if(cmp(oper, prewittSIMD_XY)) {
            // Prewitt usando SIMD
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            simdPrewitt(src->imageData, dst->imageData, src->width, src->height);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
        } else if(cmp(oper, sobelSIMD_X)) {
            // Sobel usando SIMD solo en X
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            simdSobel(src->imageData, dst->imageData, src->width, src->height, 1, 0);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));

        } else if(cmp(oper, sobelSIMD_Y)) {
            // Sobel usando SIMD solo en Y
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            simdSobel(src->imageData, dst->imageData, src->width, src->height, 0, 1);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));

        } else if(cmp(oper, sobelSIMD_XY)) {
            // Sobel usando SIMD XY
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            simdSobel(src->imageData, dst->imageData, src->width, src->height, 1, 1);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
        } else if(cmp(oper, freichenSIMD_XY)) {
            // Sobel usando SIMD solo en Y
            __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
            simdFreichen(src->imageData, dst->imageData, src->width, src->height);
            __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));

        } else {
            printf("    ERROR: No se reconoce el operador '%s'\n", oper);
            continue;
        }
            
        // Cantidad de clocks insumidos por el algoritmo.
        printf("    El procesamiento tomó %d clocks", tscl); printf("\n");
            
        filename = malloc(strlen(dstName) + 1 + strlen(oper) + strlen(extension) + 1);
        strcpy(filename, "");
        strcat(filename, dstName);
        strcat(filename, "_");
        strcat(filename, oper);
        strcat(filename, extension);
                
        printf("    Guardando en '%s'...\n", filename);
        
        // Guardar resultado
        cvSaveImage(filename, usarSrc ? src : dst);
        
        printf("    OK\n");
        
        free(filename);
    }
    
    return 0;
}

/** Devuelve true si los strings son iguales. */
int cmp(const char* s1, const char* s2) {
    return !strcmp(s1, s2);
}
