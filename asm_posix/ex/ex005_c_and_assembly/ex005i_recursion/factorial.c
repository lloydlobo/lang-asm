/*
**
** factorial.c
**
** An application that implements finding factorial of a number with either
** iterative or recursive approach
*/
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

// uint64_t iterative_factorial(uint64_t n)
// {
//         uint64_t accumulator = 1;
//         for (uint64_t i = 2; i <= n; i++)
//                 accumulator *= i;
//         return accumulator;
// }

uint64_t recursive_factorial(uint64_t n)
{
        if (n == 0)
                return 1;
        return n * recursive_factorial(n - 1);
}

int main(int argc, char *argv[])
{
        // for (uint64_t i = 0; i < 20; i++)
        //         printf("iterative factorial(%2lu) = %lu\n", i, iterative_factorial(i));
        for (uint64_t i = 0; i < 20; i++)
                printf("recursive factorial(%2lu) = %lu\n", i, recursive_factorial(i));
        return EXIT_SUCCESS;
}

// Output:
//
// iteration factorial( 0) = 1
// iteration factorial( 1) = 1
// iteration factorial( 2) = 2
// iteration factorial( 3) = 6
// iteration factorial( 4) = 24
// iteration factorial( 5) = 120
// iteration factorial( 6) = 720
// iteration factorial( 7) = 5040
// iteration factorial( 8) = 40320
// iteration factorial( 9) = 362880
// iteration factorial(10) = 3628800
// iteration factorial(11) = 39916800
// iteration factorial(12) = 479001600
// iteration factorial(13) = 6227020800
// iteration factorial(14) = 87178291200
// iteration factorial(15) = 1307674368000
// iteration factorial(16) = 20922789888000
// iteration factorial(17) = 355687428096000
// iteration factorial(18) = 6402373705728000
// iteration factorial(19) = 121645100408832000
// recursion factorial( 0) = 1
// recursion factorial( 1) = 1
// recursion factorial( 2) = 2
// recursion factorial( 3) = 6
// recursion factorial( 4) = 24
// recursion factorial( 5) = 120
// recursion factorial( 6) = 720
// recursion factorial( 7) = 5040
// recursion factorial( 8) = 40320
// recursion factorial( 9) = 362880
// recursion factorial(10) = 3628800
// recursion factorial(11) = 39916800
// recursion factorial(12) = 479001600
// recursion factorial(13) = 6227020800
// recursion factorial(14) = 87178291200
// recursion factorial(15) = 1307674368000
// recursion factorial(16) = 20922789888000
// recursion factorial(17) = 355687428096000
// recursion factorial(18) = 6402373705728000
// recursion factorial(19) = 121645100408832000
