float get(const char* img, int ancho, int i, int j) {
    return (float) (unsigned char) img[i * ancho + j];
}

float set(char* img, int ancho, int i, int j, unsigned char value) {
    img[i * ancho + j] = value;
}

unsigned char calcularPunto(const char* img, int ancho, int i, int j, float matriz[3][3]) {
    float dx;
    dx = matriz[0][0] * get(img, ancho, i - 1, j - 1)
       + matriz[0][1] * get(img, ancho, i - 1, j    )
       + matriz[0][2] * get(img, ancho, i - 1, j + 1)
       + matriz[1][0] * get(img, ancho, i    , j - 1)
       + matriz[1][1] * get(img, ancho, i    , j    )
       + matriz[1][2] * get(img, ancho, i    , j + 1)
       + matriz[2][0] * get(img, ancho, i + 1, j - 1)
       + matriz[2][1] * get(img, ancho, i + 1, j    )
       + matriz[2][2] * get(img, ancho, i + 1, j + 1);
       
    if(dx <= 0) {
        return (unsigned char)0;
    } else if(dx >= 255) {
        return (unsigned char)255;
    } else {
        return (unsigned char)dx;    
    }
}

void aplicar3x3(const char* src, char* dst, int ancho, int alto, float matriz[3][3]) {
    int i, j;
    int sum;
    unsigned char px;
    unsigned char res;
    
    for(i = 1; i < alto - 1; i++) {
        for(j = 1; j < ancho - 1; j++) {
            px = calcularPunto(src, ancho, i, j, matriz);
            
            sum = (int)px;
            sum += (int)get(dst, ancho, i, j);

            if(sum <= 0) {
                res = (unsigned char)0;
            } else if(sum >= 255) {
                res = (unsigned char)255;
            } else {
                res = (unsigned char)sum;
            }
            
            set(dst, ancho, i, j, res);
        }
    }
}

int cFreichen(const char* src, char* dst, int ancho, int alto, int xorder, int yorder) {
    float sq = 1.414213562;
    
    float xMatriz[3][3] = {{ -1,  0,  1},
                           {-sq,  0, sq},
                           { -1,  0,  1}};
    
    float yMatriz[3][3] = {{ -1,-sq, -1},
                           {  0,  0,  0},
                           {  1, sq,  1}};
    
    int tscl;
    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC 
    
    if(xorder != 0) aplicar3x3(src, dst, ancho, alto, xMatriz);
    if(yorder != 0) aplicar3x3(src, dst, ancho, alto, yMatriz);    
    
    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
    return tscl;
}

int cRoberts(const char* src, char* dst, int ancho, int alto, int xorder, int yorder) {
    float xMatriz[3][3] = {{ 0, 0, 0},
                           { 0, 1, 0},
                           { 0, 0,-1}};
    float yMatriz[3][3] = {{ 0, 0, 0},
                           { 0, 0, 1},
                           { 0,-1, 0}};
                               
    int tscl;
    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC 
    
    if(xorder != 0) aplicar3x3(src, dst, ancho, alto, xMatriz);
    if(yorder != 0) aplicar3x3(src, dst, ancho, alto, yMatriz);    
    
    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
    return tscl;
}

int cPrewitt(const char* src, char* dst, int ancho, int alto, int xorder, int yorder) {
    
    float xMatriz[3][3] = {{-1, 0, 1},
                           {-1, 0, 1},
                           {-1, 0, 1}};
    
    float yMatriz[3][3] = {{-1,-1,-1},
                           { 0, 0, 0},
                           { 1, 1, 1}};
    
    int tscl;
    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC 
    
    if(xorder != 0) aplicar3x3(src, dst, ancho, alto, xMatriz);
    if(yorder != 0) aplicar3x3(src, dst, ancho, alto, yMatriz);    
    
    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
    return tscl;
}

int cSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder) {
    float xMatriz[3][3] = {{-1, 0, 1},
                           {-2, 0, 2},
                           {-1, 0, 1}};
    
    float yMatriz[3][3] = {{-1,-2, -1},
                           { 0, 0,  0},
                           { 1, 2,  1}};
    int tscl;
    __asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl)); // Toma estado del TSC 
    
    if(xorder != 0) aplicar3x3(src, dst, ancho, alto, xMatriz);
    if(yorder != 0) aplicar3x3(src, dst, ancho, alto, yMatriz);    
    
    __asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
    return tscl;
}
