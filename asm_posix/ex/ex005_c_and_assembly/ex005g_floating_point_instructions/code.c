/*
**
** code.c -> callsum.c
** Illustrates how to call the sum function we wrote in assembly language.
**
**
*/
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

double sum(double[], uint64_t);

int main(int argc, char *argv[])
{
        double test[] = {
                40.4,
                26.7,
                21.9,
                1.5,
                -40.5,
                -23.4,
        };
        printf("%20.7f\n", sum(test, 6));
        printf("%20.7f\n", sum(test, 2));
        printf("%20.7f\n", sum(test, 0));
        printf("%20.7f\n", sum(test, 3));
        return EXIT_SUCCESS;
}
// Output:
//
// 26.6000000
// 67.1000000
//  0.0000000
// 89.0000000
