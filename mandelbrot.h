#ifndef CHECK_VAL
#define CHECK_VAL
#include <stdint.h>
void mandelbrot(uint8_t* buf, uint16_t width, uint16_t height, uint16_t max_iterations, uint16_t out_point, double zoom, double re_offset, double im_offset);
#endif // CHECK_VAL