
char calcularPuntoSobel(const char* imgData, int widthStep, int r, int c, int type);

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
                dstData[c + r * widthStep] = calcularPuntoSobel(srcData, widthStep, r, c, 1);
            }
        }
    }
    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
    return tscl;
}


char calcularPuntoSobel(const char* imgData, int widthStep, int r, int c, int type) {
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

    }
    valor+=127;
    if(valor<0)
        return 0;
    if(valor>255)
        return 255;
    return valor;
}
