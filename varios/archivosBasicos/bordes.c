#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <stdlib.h>

void detectarBordeSobel(IplImage* src, IplImage* dst);
char calcularPuntoSobel(IplImage* img, int r, int c, int type);

void detectarBordeRoberts(IplImage* src, IplImage* dst);
char calcularPuntoRoberts(IplImage* img, int r, int c, int type);

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
   detectarBordeSobel(src,dst);
   cvSaveImage("prueba.bmp",dst);
   return 0;
}

void detectarBordeSobel(IplImage* src, IplImage* dst) {
	char* srcData, *dstData;
	srcData = src->imageData;
	dstData = dst->imageData;
	int r=0,c=0;
	for(r=0;r<src->height;r++) {
		for(c=0;c<src->widthStep;c++) {
			if(c==0 || c+1 >= src->width) {
				dstData[c+r*dst->widthStep] = 0x00; 
			}else {
				//dstData[c+r*src->widthStep] = calcularPuntoSobel(src, c, r*src->widthStep, 1);
				dstData[c+r*src->widthStep] = calcularPuntoSobel(src, r, c, 1);
			}
		}
	}
// 	int i;
}


char calcularPuntoSobel(IplImage* img, int r, int c, int type) {
	char* imgData;
	imgData = img->imageData;
	int widthStep = img->widthStep;
	int valor=0;
	char ret=0;
	int coef[3][3] = {{-2,-2,0},{-2,0,2},{0,2,2} } ;
	if(type==1) {
		int a11 = c-1 + (r-1)*widthStep;
		int a12 = a11 + 1;
		int a13 = a11+2;
		int a21 = a11+widthStep;
		int a22 = a21 + 1;
		int a23 = a21+2;
		int a31 = a21+widthStep;
		int a32 = a31+1;
		int a33 = a31+2;
		valor = (coef[0][0]*(unsigned char)imgData[a11]) + (coef[0][1]*(unsigned char)imgData[a12]) + (coef[0][2]*(unsigned char)imgData[a13]) +
			(coef[1][0]*(unsigned char)imgData[a21]) + (coef[1][1]*(unsigned char)imgData[a22]) + (coef[1][2]*(unsigned char)imgData[a23]) +
			(coef[2][0]*(unsigned char)imgData[a31]) + (coef[2][1]*(unsigned char)imgData[a32]) + (coef[2][2]*(unsigned char)imgData[a33]);

;
	}
	valor+=127;
	if(valor<0)
		return 0;
	if(valor>255)
		return 255;
	return valor;
		
}
