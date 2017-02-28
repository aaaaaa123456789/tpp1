#include <stdio.h>
#include <string.h>

int main (int argc, char ** argv) {
  unsigned padding_amount;
  if (argc != 3) {
    fprintf(stderr, "usage: %s rom.gb bank_setting\n", *argv);
    return 1;
  }
  if ((strlen(argv[2]) != 1) || !strchr("0123456789abcdefABCDEF", *(argv[2]))) {
    fprintf(stderr, "invalid ROM size setting: %s\n", argv[2]);
    return 1;
  }
  padding_amount = *(argv[2]) - 48;
  if (padding_amount > 9) padding_amount -= 7;
  if (padding_amount > 15) padding_amount -= 32;
  padding_amount = 2 << padding_amount;
  FILE * fp = fopen(argv[1], "rb+");
  if (!fp) {
    fprintf(stderr, "could not open file: %s\n", argv[1]);
    return 2;
  }
  unsigned bank, pointer, value;
  unsigned char buffer[4];
  fseek(fp, 0x4000, 0);
  for (bank = 1; bank < padding_amount; bank ++) for (pointer = 0x4000; pointer < 0x8000; pointer += 4) {
    value = bank * pointer;
    *buffer = value;
    value >>= 8;
    buffer[1] = value;
    value >>= 8;
    buffer[2] = value;
    value >>= 8;
    buffer[3] = value;
    fwrite(buffer, 1, 4, fp);
  }
  fclose(fp);
  return 0;
}
