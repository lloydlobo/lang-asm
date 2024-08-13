/*
**
** code.c -> callfactorial.c
**
** An application that illustrates calling the factorial function defined elsewhere.
**
**
*/
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

uint64_t factorial(uint64_t n);

uint64_t fac(uint64_t n);

int main(int argc, char *argv[])
{
        for (uint64_t i; i < 20; i++)
                printf("factorial(%2lu) = %lu\n", i, factorial(i));
        for (uint64_t i; i < 20; i++)
                printf("fac(torial)(%2lu) = %lu\n", i, fac(i));

        return EXIT_SUCCESS;
}

// Output:
//
// + nasm -f elf64 -Ox code.asm -I ../../../ -I ../../../lib/sys/Linux -Wlabel-orphan -Wno-orphan-labels -O0 -g -F dwarf
// + zig cc code.o code.c
// + ./a.out
//
// factorial( 0) = 1
// factorial( 1) = 1
// factorial( 2) = 2
// factorial( 3) = 6
// factorial( 4) = 24
// factorial( 5) = 120
// factorial( 6) = 720
// factorial( 7) = 5040
// factorial( 8) = 40320
// factorial( 9) = 362880
// factorial(10) = 3628800
// factorial(11) = 39916800
// factorial(12) = 479001600
// factorial(13) = 6227020800
// factorial(14) = 87178291200
// factorial(15) = 1307674368000
// factorial(16) = 20922789888000
// factorial(17) = 355687428096000
// factorial(18) = 6402373705728000
// factorial(19) = 121645100408832000
