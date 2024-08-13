/*
**
** code.c -> test_add_four_floats.c
**
** An application that illustrates The XMM registers can do arithmetic on
** floating point values one operation at a time (scalar) or multiple operations
** at a time (packed). The operations have the form:
**
*/
#include <stdio.h>
#include <stdlib.h>

void add_four_floats(float[], float[]);

int main(int argc, char *argv[])
{
        float x[] = { -29.750, 244.333, 887.29, 48.1E22 };
        float y[] = { -29.750, 199.333, -8.29, 22.1E23 };
        add_four_floats(x, y);
        printf("%f\n%f\n%f\n\%f\n", x[0], x[1], x[2], x[3]);
        return EXIT_SUCCESS;
}

// Also see this "[nice little x86 floating-point slide deck from Ray
// Seyfarth](http://rayseyfarth.com/asm/pdf/ch11-floating-point.pdf)".

// Output:
//
// + nasm -f elf64 -Ox code.asm -I ../../../ -I ../../../lib/sys/Linux -Wlabel-orphan -Wno-orphan-labels
// + zig cc code.o code.c
// + ./a.out
// -59.500000
// 443.665985
// 879.000000
// 2691000072718455624695808.000000
