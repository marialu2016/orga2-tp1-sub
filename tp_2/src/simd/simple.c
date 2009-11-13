#include <stdio.h>


struct IplImage {
    int width;
    int height;
    char* imageData;
};


/**
 * Reemplazar por otros operadores...
 */
extern void simdRoberts(const char* src, char* dst, int ancho, int alto);


/* Funciones de imagenes */


/**
 * Aplica una matriz de convolución de 3x3 float's a 'src' y guarda el
 * resultado en 'dst'. Asume que son de igual tamaño.
 */
void aplicar3x3(struct IplImage src, struct IplImage dst, float matriz[3][3]);

/**
 * Calcula el operador en un pixel.
 */
char calcular(struct IplImage img, int i, int j, float matriz[3][3]);

/**
 * Devuelve un pixel del dibujo casteado a float.
 */
float get(const struct IplImage img, int i, int j);


void printData(struct IplImage* img);



int main(int argc, char *argv[]){


    int width = 80;     // width debe ser múltiplo de 16
    int height = 40;
        
    char* srcData = malloc(width*height);        //Reservo width*height bytes para los datos
    char* dstData = malloc(width*height);

    int i, j;
    
    for(i = 0; i < height; i += 1) {
        for(j = 0; j < width; j += 1) {
            srcData[i * width + j] = (j + i + 48) % 256;
            dstData[i * width + j] = 0;
        }
    }
    
    struct IplImage* src; src = malloc(9);
    src->width = width; src->height = height; src->imageData = srcData;

    struct IplImage* dst; dst = malloc(9);
    dst->width = width; dst->height = height; dst->imageData = dstData;
    
    //printf("len(srcData)=%d  len(dstData)=%d \n", strlen(srcData), strlen(dstData));
    //printf("%s, %d, %d\n", src->imageData, src->width, src->height);
    //printf("%s, %d, %d\n", dst->imageData, dst->width, dst->height);

    //printf("srcData=%d dstData=%d \n", (int)srcData, (int)dstData);
    //printf("srcData[0:1] = %d:%d\n", srcData[0], srcData[1]);
    //printf("srcData[15:17] = %d:%d:%d\n", srcData[15], srcData[16], srcData[17]);

    printf("Antes:\n");
    printf("  src=");
    printData(src);
    printf("\n");
    printf("  dst=");
    printData(dst);
    printf("\n");
    
    //asmPrewittSIMD(src->imageData, dst->imageData, src->width, src->height);

    simdRoberts(src->imageData, dst->imageData, src->width, src->height);
    
    //cRoberts(src->imageData, dst->imageData, src->width, src->height, 1, 0);

    
    printf("Dsps:\n");
    printf("  src=");
    printData(src);
    printf("\n");
    printf("  dst=");
    printData(dst);
    printf("\n");
    
    
    return 0;

	
}

void printData(struct IplImage* img) {
    int i, j;
    for(i = 0; i < img->height; i++) {
        printf("\n      ");
        for(j = 0; j < img->width; j++) {
            if(j > 0) printf(",");
            if(j == 8) printf("  ");
            printf("%d", img->imageData[i * img->width + j]);
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


char calcular(struct IplImage img, int i, int j, float matriz[3][3]) {
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
		return (char)0;
	} else if(dx >= 255) {
		return (char)255;
	} else {
		return (char)dx;	
	}
}


void aplicar3x3(struct IplImage src, struct IplImage dst, float matriz[3][3]) {
	int i, j;
	int sum;
	char px;
	char res;
	
	for(i = 1; i < src.height - 1; i++) {
		for(j = 1; j < dst.width - 1; j++) {
			px = calcular(src, i, j, matriz);
			
			sum = (int)px;
			sum += (int)get(dst, i, j);

			if(sum <= 0) {
				res = (char)0;
			} else if(sum >= 255) {
				res = (char)255;
			} else {
				res = (char)sum;
			}
			
			dst.imageData[i * src.width + j] = res;	
		}
	}
}


