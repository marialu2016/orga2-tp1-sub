#include <cv.h>
#include <highgui.h>

#include "bordes.c"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * Implementación en assembly del operador de Roberts en X y en Y.
 */
extern void asmRoberts(const char* src, char* dst, int ancho, int alto);

/**
 * Implementación en assembly del operador de Roberts en X y en Y menos eficiente,
 * que usa la memoria en lugares donde podrían usarse registros.
 */
extern void asmRobertsPush(const char* src, char* dst, int ancho, int alto);

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
    printf("    USO:                                                              "); printf("\n");
    printf("                                                                      "); printf("\n");
    printf("            ./bordes ${src} ${dest} ${lista de operadores}            "); printf("\n");
    printf("                                                                      "); printf("\n");
    printf("    - ${src}: nombre del archivo de origen                            "); printf("\n");
    printf("    - ${dest}: nombre del archivo de salida SIN EXTENSIÓN             "); printf("\n");
    printf("    - ${lista de operadores}: una o más de las siguientes claves:     "); printf("\n");
    printf("                                                                      "); printf("\n");
    printf("             CLAVE | OPERADOR  | DIRECCION | IMPLEMENTACIÓN           "); printf("\n");
    printf("            -------+-----------+-----------+----------------          "); printf("\n");
    printf("              r1   |  Roberts  |    XY     |  Assembler               "); printf("\n");
    printf("              r2   |  Prewitt  |    XY     |     \"                   "); printf("\n");
    printf("              r3   |   Sobel   |    X      |     \"                   "); printf("\n");
    printf("              r4   |   Sobel   |    Y      |     \"                   "); printf("\n");
    printf("              r5   |   Sobel   |    XY     |     \"                   "); printf("\n");
    printf("                   |           |           |                          "); printf("\n");
    printf("              cv3  |   Sobel   |    X      |   OpenCV                 "); printf("\n");
    printf("              cv4  |   Sobel   |    Y      |     \"                   "); printf("\n");
    printf("              cv5  |   Sobel   |    XY     |     \"                   "); printf("\n");
    printf("                   |           |           |                          "); printf("\n");
    printf("              c3   |   Sobel   |    X      |     C                    "); printf("\n");
    printf("              c4   |   Sobel   |    Y      |     \"                   "); printf("\n");
    printf("              c5   |   Sobel   |    XY     |     \"                   "); printf("\n");
    printf("                   |           |           |                          "); printf("\n");
    printf("             push  |  Roberts  |    X      | Assembler usando pila    "); printf("\n");
    printf("                   |           |           |                          "); printf("\n");
    printf("              byn  |   Escala de grises    |                          "); printf("\n");
    printf("                                                                      "); printf("\n");
    printf("    El programa generará una imagen por cada operador solicitado. El  "); printf("\n");
    printf("nombre de los archivos de salida será ${dest} más un sufijo que indica"); printf("\n");
    printf("el operador utilizado, más la extensión (obtenida del archivo fuente)."); printf("\n");
    printf("                                                                      "); printf("\n");
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
    
    char* sufijo;
    char* extension;
    char* filename;
    
    int dotIndex;
    int tscl;
    int op;
    int usarSrc;
        
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
		            
		if(!strcmp(oper, "r1") || !strcmp(oper, "robxy")) {
		    // Roberts XY
		    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
		    asmRoberts(src->imageData, dst->imageData, src->width, src->height);
		    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		    sufijo = "_asm_roberts";
		    
		} else if(!strcmp(oper, "r2") || !strcmp(oper, "prexy")) {
		    // Prewitt XY
		    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
		    asmPrewitt(src->imageData, dst->imageData, src->width, src->height);
		    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		    sufijo = "_asm_prewitt";
		    
		} else if(!strcmp(oper, "r3") || !strcmp(oper, "sobx")) {
		    // Sobel X
		    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
		    asmSobel(src->imageData, dst->imageData, src->width, src->height, 1, 0);
		    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		    sufijo = "_asm_sobelX";
		
		} else if(!strcmp(oper, "r4") || !strcmp(oper, "soby")) {
		    // Sobel Y
		    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
		    asmSobel(src->imageData, dst->imageData, src->width, src->height, 0, 1);
		    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		    sufijo = "_asm_sobelY";
		
		} else if(!strcmp(oper, "r5") || !strcmp(oper, "sobxy")) {
		    // Sobel XY
		    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
		    asmSobel(src->imageData, dst->imageData, src->width, src->height, 1, 1);
		    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		    sufijo = "_asm_sobelXY";
		       
		} else if(!strcmp(oper, "cv3") || !strcmp(oper, "sobxcv")) {
		    // Sobel X (OPenCV)
		    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
		    cvSobel(src, dst, 1, 0, 3);
		    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		    sufijo = "_cv_sobelX";
		
		} else if(!strcmp(oper, "cv4") || !strcmp(oper, "sobycv")) {
		    // Sobel Y (OPenCV)
		    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
		    cvSobel(src, dst, 0, 1, 3);
		    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		    sufijo = "_cv_sobelY";
		
		} else if(!strcmp(oper, "cv5") || !strcmp(oper, "sobxycv")) {
		    // Sobel XY (OPenCV)
		    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
		    cvSobel(src, dst, 1, 1, 3);
		    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		    sufijo = "_cv_sobelXY";
		
		} else if(!strcmp(oper, "c3") || !strcmp(oper, "sobxc")) {
		    // Sobel X (C)
		    tscl = cSobel(src->imageData, dst->imageData, src->width, src->height, 1, 0);
		    sufijo = "_c_sobelX";
		
		} else if(!strcmp(oper, "c4") || !strcmp(oper, "sobyc")) {
		    // Sobel Y (C)
		    tscl = cSobel(src->imageData, dst->imageData, src->width, src->height, 0, 1);
		    sufijo = "_c_sobelY";
		
		} else if(!strcmp(oper, "c5") || !strcmp(oper, "sobxyc")) {
		    // Sobel XY (C)
		    tscl = cSobel(src->imageData, dst->imageData, src->width, src->height, 1, 1);
		    sufijo = "_c_sobelXY";
		
		} else if(!strcmp(oper, "byn")) {
		    // Escala de grises (sin ninguna detección de bordes)
		    tscl = 0;
		    usarSrc = 1;
		    sufijo = "_byn";
		
		} else if(!strcmp(oper, "push")) {
		    // Roberts X usando push/pop
		    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
		    asmRobertsPush(src->imageData, dst->imageData, src->width, src->height);
		    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		    sufijo = "_asm_roberts_push";

		} else {
		    printf("    ERROR: No se reconoce el operador '%s'\n", oper);
		    continue;
		}
		    
		// Cantidad de clocks insumidos por el algoritmo.
		printf("    El procesamiento tomó %d clocks", tscl); printf("\n");
		    
		filename = malloc(strlen(dstName) + strlen(sufijo) + strlen(extension) + 1);
		strcpy(filename, "");
		strcat(filename, dstName);
		strcat(filename, sufijo);
		strcat(filename, extension);
		        
		printf("    Guardando en '%s'...\n", filename);
	    
		// Guardar resultado
		cvSaveImage(filename, usarSrc ? src : dst);
		
		printf("    OK\n");
			
		free(filename);
    }
    
	printf(" ********************* \n\n\n\n");
    return 0;
}
