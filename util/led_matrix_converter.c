
#include <stdio.h>
#include <stdint.h>

const uint64_t IMAGES[] = {
  0xc100140000000003,
  0x0000040208000000,
  0x0000380808000000,
  0x0000701010000000,
  0x0000e02020000000
};

const int IMAGES_LEN = sizeof(IMAGES)/8;

int main() {
  printf("animation = {\n");
  for(int i=0; i < IMAGES_LEN; i++) {
    uint64_t image = IMAGES[i];
    for(int j=0; j<8; j++) { 
      char result = (image >> (j * 8)) & 0xFF;
      printf("0x%hhx, ", result);  
    }
    printf("}, \n");
  }
  printf("\n}");
}
