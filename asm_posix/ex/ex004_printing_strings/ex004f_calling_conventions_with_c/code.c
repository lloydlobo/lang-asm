#include <stdio.h>
#include <stdlib.h>

// $ find -name '*.c' | entr -crs 'date; zig cc code.c -o a_c.out; ./a_c.out; echo exit status $?; hexdump -C a_c.out >code.c.hex.dump; echo exit status $?; objdump -M intel -d a_c.out >code.c.a_c.out.obj.dump; echo exit status $?;'

#define PROGN "ex004f_calling_conventions_with_c"  // note: omit newline as
                                                   // `puts` calls with newline
#define FORMAT "%20ld\n"

long print(long a_rax, long b_rbx, long counter_ecx);

// RAX (64-bit): [63..........................32|31..........................0]
// EAX (32-bit):                                [31..........................0]
// AX (16-bit):                                                 [15..........0]
// AL (8-bit):                                                           [7..0]
// AH (8-bit):                                                  [15.......8]
int main(int argc, char *argv[])
{
        unsigned long long rax       = 0;
        unsigned long long rbx       = 0;
        long               saved_rbx = rbx;                                  //     push rbx
        char              *rdi       = PROGN;                                //     mov rdi, progn
        puts(rdi);                                                           //     call puts
        long counter_ecx = 90;                                               //     mov ecx, 42
        rax              = (rax & 0x0000000000000000) | 0x0000000000000000;  //     xor rax, rax
        rbx              = (rbx & 0x0000000000000000) | 0x0000000000000000;  //     xor rbx, rbx
        rbx++;                                                               //     inc rbx
        rax = print(rax, rbx, counter_ecx);                                  //     call printf
        return (rax == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}

// note: maybe use pointers for save(push) and restore(pop) to take effect
// note: maybe asm implicitly returns {rax} from the context a label(function)
// instructions were called from
long print(long a_rax, long b_rbx, long counter_ecx)
{
        long saved_rax, saved_rbx, saved_rcx;
print:
        //                        .save:
        saved_rax = a_rax;        //     push rax
        saved_rcx = counter_ecx;  //     push rcx
        saved_rbx = b_rbx;

        //                    .load:
        char *rdi = FORMAT;   //     mov rdi, format
        long  rsi = a_rax;    //     mov rsi, rax
        a_rax     = 0;        //     xor rax, rax
        printf(FORMAT, rsi);  //     call printf
                              //
        //                        .restore:
        counter_ecx = saved_rcx;  //     pop rcx
        a_rax       = saved_rax;  //     pop rax
        b_rbx       = saved_rbx;

        //                       .next:
        long rdx = a_rax;        //     mov rdx, rax
        a_rax    = b_rbx;        //     mov rax, rbx
        b_rbx += rdx;            //     add rbx,rdx
        if (--counter_ecx != 0)  //     dec ecx
                goto print;      //     jnz print

        //                  .leave:
        b_rbx = saved_rax;  //     pop rbx
        a_rax = 0;          //     mov rax, 0
        return a_rax;       //     ret
}

//
//     rax = (rax & 0xFFFFFFFFFFFFFF00) | 0x00;  //     xor al, al
//     rbx = (rbx & 0xFFFFFFFFFFFFFF00) | 0x00;  //     xor bl, bl
//
// The reason for this is that al and bl represent only the lowest 8 bits of
// rax and rbx respectively. In C, we don't typically have direct access to
// these partial registers, so we operate on the full 64-bit register and just
// modify the lowest byte.
//
// A more accurate C representation might look like this:
//
//     unsigned char* al_ptr = (unsigned char*)&rax;
//     *al_ptr = 0;  // This is equivalent to xor al, al
//
//     unsigned char* bl_ptr = (unsigned char*)&rbx;
//     *bl_ptr = 0;  // This is equivalent to xor bl, bl
//
// Or, if we're working with the full registers:
//
//     rax &= 0xFFFFFFFFFFFFFF00;  // Clear the lowest byte of rax
//     rbx &= 0xFFFFFFFFFFFFFF00;  // Clear the lowest byte of rbx
//
// These operations clear only the lowest byte of the respective registers,
// which is what xor al, al and xor bl, bl do in assembly.
