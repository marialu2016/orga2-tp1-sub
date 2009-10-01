#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <stdlib.h>

void detectarBordeSobel(IplImage* src, IplImage* dst);
char calcularPuntoSobel(IplImage* img, int r, int c, int type);

void detectarBordeRoberts(IplImage* src, IplImage* dst);
char calcularPuntoRoberts(IplImage* img, int r, int c);

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

   //cvSaveImage("lenaBYN.BMP",src); //grabo la imagen byn
   //detectarBordeSobel(src,dst);
   detectarBordeRoberts(src,dst);
   cvSaveImage("prueba.bmp",dst);
   return 0;
}

void detectarBordeRoberts(IplImage* src, IplImage* dst) {
	char* srcData, *dstData;
	srcData = src->imageData;
	dstData = dst->imageData;
	int r=0,c=0;
	for(r=0;r<src->height;r++) {
		for(c=0;c<src->widthStep;c++) {
			if(c+1 >= src->width) {
				dstData[c+r*dst->widthStep] = 0x00; 
			}else {
				//dstData[c+r*src->widthStep] = calcularPuntoSobel(src, c, r*src->widthStep, 1);
				dstData[c+r*src->widthStep] = calcularPuntoRoberts(src, r, c);
			}
		}
	}
	int i;
}


char calcularPuntoRoberts(IplImage* img, int r, int c) {
	char* imgData;
	imgData = img->imageData;
	int widthStep = img->widthStep;
	int valor=0;
	char ret=0;
	int a11 = c + r*widthStep;
	int a22 = c+1 + (r+1)*widthStep;
	valor = imgData[a11] - imgData[a22];
	if(valor<0)
		return 0;
	if(valor>255)
		return 255;
	return valor;
		
}
