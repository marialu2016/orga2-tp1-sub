#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <stdlib.h>

extern void asmRoberts(const char* src, char* dst, int ancho, int alto);

int main( int argc, char** argv )
{

   IplImage * src = 0;
   IplImage * dst = 0;
   IplImage * dst_ini = 0;

   char* filename = argc == 2 ? argv[1] : (char*)"lena.bmp";

   // Cargo la imagen
   if( (src = cvLoadImage (filename, CV_LOAD_IMAGE_GRAYSCALE)) == 0 )
	   return -1;

   // Creo una IplImage para cada salida esperada
   if( (dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
	   return -1;

   asmRoberts(src->imageData, dst->imageData, src->width, src->height);
   cvSaveImage("prueba.bmp",dst);
   return 0;
}

