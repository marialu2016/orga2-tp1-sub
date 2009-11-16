#include <cv.h>
#include <highgui.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void asmPrewitt(const char* src, char* dst, int ancho, int alto);
/**
 * Dado el nombre de un archivo con una imagen, la transforma a escala de grises y genera imágenes
 * con sus bordes destacados usando los operadores especificados.
 * Ver contenido de la función mostrarUso() para más detalles.
 */
int main() {
    IplImage * src;
    IplImage * dst;
    
    int dotIndex;
    int tscl;
    int op;
    int usarSrc;
    char* filename = (char*)"lena.bmp";
    src = cvLoadImage(filename, CV_LOAD_IMAGE_GRAYSCALE);
    if(!src) {
        printf("ERROR: no se pudo abrir la imagen fuente");
        return 1;
    }
    if(src->origin != 0) {
        printf("Formato no reconocido: el 'origin' de OpenCV dio distinto a cero");
        return 1;
    }
    if((dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0) return 0;
    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC
    printf("ENTRO\n");
    asmPrewitt(src->imageData, dst->imageData, src->width, src->height);
    printf("SALIO\n");
    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));    
    printf("    El procesamiento tomó %d clocks", tscl); printf("\n");
    printf("    Guardando en '%s'...\n", "lenaR.bmp");
    cvSaveImage("lenaR.BMP", dst);
    printf("    OK\n");
    
    return 0;
}
