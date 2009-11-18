#include <stdio.h>


/**
 * Reemplazar por otros operadores...
 */
extern void simdRoberts(const char* src, char* dst, int ancho, int alto);


struct IplImage {
    int width;
    int height;
    unsigned char* imageData;
};


/* Funciones de imagenes */


/**
 * Aplica una matriz de convolución de 3x3 float's a 'src' y guarda el
 * resultado en 'dst'. Asume que son de igual tamaño.
 */
void aplicar3x3(struct IplImage src, struct IplImage dst, float matriz[3][3]);
void cRoberts(struct IplImage src, struct IplImage dst);

/**
 * Calcula el operador en un pixel.
 */
unsigned char calcular(struct IplImage img, int i, int j, float matriz[3][3]);

/**
 * Devuelve un pixel del dibujo casteado a float.
 */
float get(const struct IplImage img, int i, int j);
/**
 * Cambia un pixel del dibujo.
 */
float set(const struct IplImage img, int i, int j, unsigned char value);

/**
 * Crean una imagen inicialmente en negro.
 */
struct IplImage* newIplImage(int width, int height); 

void freeIplImage(struct IplImage* img);

void clear(struct IplImage img);
void llenar1(struct IplImage img);
void llenar2(struct IplImage img);
void llenarRandom(struct IplImage img);


unsigned char nextRnd();

 
/** 
 * Muestra por salida estándar los datos de una IplImage.
 */
void printData(struct IplImage* img);

/**
 * Muestra por salida estándar los datos de una IplImage.
 */
void printDataCompacta(struct IplImage* img);


int main(int argc, char *argv[]){
    int width = 32;     // width debe ser múltiplo de 16
    int height = 10;
        
    int i, j;
    
    struct IplImage* src = newIplImage(width, height);
    llenarRandom(*src);
    
    printf("  src=");
    printData(src);
    printf("\n");
    
    struct IplImage* dst = newIplImage(width, height);
    simdPrewitt(src->imageData, dst->imageData, src->width, src->height);
    
    printf("  dst=");
    printData(dst);
    printf("\n");
    
    freeIplImage(src);
    freeIplImage(dst);
        

    return 0;
}


void printData(struct IplImage* img) {
    int i, j;
    for(i = 0; i < img->height; i++) {
        printf("\n      ");
        for(j = 0; j < img->width; j++) {
            if(j > 0) printf(",");
            unsigned char val = get(*img, i, j);
            
            if(val < 100) printf(" ");
            if(val < 10) printf(" ");
            
            printf("%d", val);
        }
    }
}

void printDataCompacta(struct IplImage* img) {
    int i, j;
    for(i = 0; i < img->height; i++) {
        printf("\n");
        for(j = 0; j < img->width; j++) {
            //if(j > 0) printf(",");
            unsigned char val = get(*img, i, j) / 10;
            
            //if(val < 100) printf(" ");
            if(val < 10) printf(" ");
            
            printf("%d", val);
        }
    }
}


void printXmm(float* xmm) {
    int i;
    printf("[");
    for(i = 0; i < 4; i++) {
        if(i > 0) printf(",");
        printf("%f", xmm[i]);
    }
    printf("]\n");
}

void cargar(float* xmm, const char* src, int desde) {
    int i;
    for(i = 0; i < 4; i++) {
        xmm[i] = (float)src[desde + i];
    }
}

/** Función mulps de asm. */
void mulps(float* dest, float* src) {
    int i;
    for(i = 0; i < 4; i++) {
        dest[i] *= src[i];
    }
}

/** Función addps de asm. */
void addps(float* dest, float* src) {
    int i;
    for(i = 0; i < 4; i++) {
        dest[i] += src[i];
    }
}


/* Funciones de imagen */

float get(const struct IplImage img, int i, int j) {
    return (float) img.imageData[i * img.width + j];
}

float set(const struct IplImage img, int i, int j, unsigned char value) {
    img.imageData[i * img.width + j] = value;
}

unsigned char calcular(struct IplImage img, int i, int j, float matriz[3][3]) {
    float dx;
    dx = matriz[0][0] * get(img, i - 1, j - 1)
       + matriz[0][1] * get(img, i - 1, j    )
       + matriz[0][2] * get(img, i - 1, j + 1)
       + matriz[1][0] * get(img, i    , j - 1)
       + matriz[1][1] * get(img, i    , j    )
       + matriz[1][2] * get(img, i    , j + 1)
       + matriz[2][0] * get(img, i + 1, j - 1)
       + matriz[2][1] * get(img, i + 1, j    )
       + matriz[2][2] * get(img, i + 1, j + 1);
       
    if(dx <= 0) {
        return (unsigned char)0;
    } else if(dx >= 255) {
        return (unsigned char)255;
    } else {
        return (unsigned char)dx;    
    }
}


void aplicar3x3(struct IplImage src, struct IplImage dst, float matriz[3][3]) {
    int i, j;
    int sum;
    unsigned char px;
    unsigned char res;
    
    for(i = 1; i < src.height - 1; i++) {
        for(j = 1; j < dst.width - 1; j++) {
            px = calcular(src, i, j, matriz);
            
            sum = (int)px;
            sum += (int)get(dst, i, j);

            if(sum <= 0) {
                res = (unsigned char)0;
            } else if(sum >= 255) {
                res = (unsigned char)255;
            } else {
                res = (unsigned char)sum;
            }
            
            set(dst, i, j, res);
        }
    }
}

struct IplImage* newIplImage(int width, int height) {
    unsigned char* data = malloc(width*height);        //Reservo width*height bytes para los datos
    
    int i, j;
    
    for(i = 0; i < height; i += 1) {
        for(j = 0; j < width; j += 1) {
            data[i * width + j] = (unsigned char)0;
        }
    }
    
    struct IplImage* res = malloc(9);
    res->width = width; res->height = height; res->imageData = data;
    
    return res;
}

void freeIplImage(struct IplImage* img) {
    free(img->imageData);
    free(img);    
}

void clear(struct IplImage img) {
    int i, j;
    for(i = 0; i < img.height; i++) {
        for(j = 0; j < img.width; j++) {
            set(img, i, j, (unsigned char)0);
        }
    }
}

void llenar1(struct IplImage img) {
    int i, j;
    for(i = 0; i < img.height; i++) {
        for(j = 0; j < img.width; j++) {
            set(img, i, j, (unsigned char)((j + i) % 256));
        }
    }
}
void llenar2(struct IplImage img) {
    int i, j;
    for(i = 0; i < img.height; i++) {
        for(j = 0; j < img.width; j++) {
            set(img, i, j, (unsigned char)(((j + i) % 7) * 111));
        }
    }
}

void llenarRandom(struct IplImage img) {
    int i, j;
    for(i = 0; i < img.height; i++) {
        for(j = 0; j < img.width; j++) {
            set(img, i, j, nextRnd());
        }
    }
}

int rndA = 1010; int rndB = 17;
int rndC = 234;
unsigned char nextRnd() {
    rndA = rndA * 7 + 11;
    rndB = rndB * 11 + 13;
    rndC = rndC * 13 + 17;
    
    
    return (rndA+rndB+rndC) % 256;
}

void cRoberts(struct IplImage src, struct IplImage dst) {
    
    float xMatriz[3][3] = {{ 0, 0, 0},
                           { 0, 1, 0},
                           { 0, 0,-1}};
    float yMatriz[3][3] = {{ 0, 0, 0},
                           { 0, 0, 1},
                           { 0,-1, 0}};
    
    aplicar3x3(src, dst, xMatriz);
    aplicar3x3(src, dst, yMatriz);

}

