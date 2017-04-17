
#include <stdio.h>
#include <stdint.h>

const uint64_t IMAGES[] = {
  0x0101010101010101
};

const int IMAGES_LEN = sizeof(IMAGES)/8;

int main() {
  printf("animation = {\n");
  for(int i=0; i < IMAGES_LEN; i++) {
    printf("{ ");
    uint64_t image = IMAGES[i];
    for(int j=0; j<8; j++) {
      char result = (image >> (j * 8)) & 0xFF;
      printf("0x%02x,", result);  
    }
    printf("}, \n");
  }
  printf("\n}");
}
