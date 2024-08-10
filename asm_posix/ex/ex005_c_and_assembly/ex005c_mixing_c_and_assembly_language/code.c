// code.c -> callmaxofthree.c
/*
**
** A small program that illustrates how to call `maxofthree` function we wrote
** in assembly language.
**
*/
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int64_t maxofthree(int64_t, int64_t, int64_t);

int main(int argc, char *argv[])
{
        printf("%ld\n", maxofthree(1, -4, -7));
        printf("%ld\n", maxofthree(2, -6, 1));
        printf("%ld\n", maxofthree(2, 3, 1));
        printf("%ld\n", maxofthree(-2, 4, 3));
        printf("%ld\n", maxofthree(2, -6, 5));
        printf("%ld\n", maxofthree(2, 4, 6));
        // Output:
        //
        // 1
        // 2
        // 3
        // 4
        // 5
        // 6
        return EXIT_SUCCESS;
}
