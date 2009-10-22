
char calcularPuntoSobel(const char* imgData, int widthStep, int r, int c, int xorder, int yorder);

/**
 * Implementación en C del operador de Sobel en X, Y o ambos.
 * Devuelve la cantidad de clocks insumidos por el algoritmo.
 */
int cSobel(const char* srcData, char* dstData, int ancho, int alto, int xorder, int yorder) {
    int widthStep = ancho % 4 > 0 ? ancho + 4 - ancho % 4 : ancho;
    int tscl;
    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC 
    int r = 0, c = 0;
    for(r = 0; r < alto; r++) {
        for(c = 0; c < widthStep; c++) {
            if(c == 0 || c + 1 >= ancho) {
                dstData[c + r * widthStep] = 0x00;
            } else {
                dstData[c + r * widthStep] = calcularPuntoSobel(srcData, widthStep, r, c,xorder,yorder);
            }
        }
    }
    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
    return tscl;
}


char calcularPuntoSobel(const char* imgData, int widthStep, int r, int c, int xorder, int yorder) {
    int valor=0;
    char ret=0;
    int coefX[3][3] = {{-1,0,1},{-2,0,2},{-1,0,1} } ;
    int coefY[3][3] = {{-1,-2,-1},{0,0,0},{1,2,1} } ;
        int a11 = c-1 + (r-1)*widthStep;
        int a12 = a11 + 1;
        int a13 = a11+2;
        int a21 = a11+widthStep;
        int a22 = a21 + 1;
        int a23 = a21+2;
        int a31 = a21+widthStep;
        int a32 = a31+1;
        int a33 = a31+2;
        valor=0;
        if(xorder==1) {
        	valor = (coefX[0][0]*(unsigned char)imgData[a11]) + (coefX[0][1]*(unsigned char)imgData[a12]) + (coefX[0][2]*(unsigned char)imgData[a13]) +
            (coefX[1][0]*(unsigned char)imgData[a21]) + (coefX[1][1]*(unsigned char)imgData[a22]) + (coefX[1][2]*(unsigned char)imgData[a23]) +
            (coefX[2][0]*(unsigned char)imgData[a31]) + (coefX[2][1]*(unsigned char)imgData[a32]) + (coefX[2][2]*(unsigned char)imgData[a33]);
        }
        if(valor<0)
	        valor=0;
	if(valor>255)
	        valor=255;
        if(yorder==1) {
        	valor += (coefY[0][0]*(unsigned char)imgData[a11]) + (coefY[0][1]*(unsigned char)imgData[a12]) + (coefY[0][2]*(unsigned char)imgData[a13]) +
            (coefY[1][0]*(unsigned char)imgData[a21]) + (coefY[1][1]*(unsigned char)imgData[a22]) + (coefY[1][2]*(unsigned char)imgData[a23]) +
            (coefY[2][0]*(unsigned char)imgData[a31]) + (coefY[2][1]*(unsigned char)imgData[a32]) + (coefY[2][2]*(unsigned char)imgData[a33]);
        }
       if(valor<0)
		valor=0;
	if(valor>255)
		valor=255;
    return valor;
}
