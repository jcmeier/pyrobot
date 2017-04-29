
#include <stdio.h>
#include <stdint.h>

const uint64_t IMAGES[] = {
  0x0000000000000000,
  0xffffffffffffffff,
  0x5555555555555555,
  0x0055005500550055
};


const int IMAGES_LEN = sizeof(IMAGES)/8;

int main() {
  FILE *fp;
  fp = fopen("animation.bytes", "w+");
  //printf("animation = {\n");
  for(int i=0; i < IMAGES_LEN; i++) {
    uint64_t image = IMAGES[i];
    for(int j=0; j<8; j++) { 
      char result = (image >> (j * 8)) & 0xFF;
      fputc(result, fp); 
      printf("0x%hhx ", result);  
    }
    //printf("}, \n");
  }
  //printf("\n}");
}
