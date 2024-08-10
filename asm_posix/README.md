# asm_posix

This table lists the naming conventions and different sizes for all the
general-purpose registers in x86-64:

| 64-bit | 32-bit | 16-bit | 8-bit (low) | 8-bit (high) |
| ------ | ------ | ------ | ----------- | ------------ |
| RAX    | EAX    | AX     | AL          | AH           |
| RBX    | EBX    | BX     | BL          | BH           |
| RCX    | ECX    | CX     | CL          | CH           |
| RDX    | EDX    | DX     | DL          | DH           |
| RSI    | ESI    | SI     | SIL         | -            |
| RDI    | EDI    | DI     | DIL         | -            |
| RBP    | EBP    | BP     | BPL         | -            |
| RSP    | ESP    | SP     | SPL         | -            |
| R8     | R8D    | R8W    | R8B         | -            |
| R9     | R9D    | R9W    | R9B         | -            |
| R10    | R10D   | R10W   | R10B        | -            |
| R11    | R11D   | R11W   | R11B        | -            |
| R12    | R12D   | R12W   | R12B        | -            |
| R13    | R13D   | R13W   | R13B        | -            |
| R14    | R14D   | R14W   | R14B        | -            |
| R15    | R15D   | R15W   | R15B        | -            |

For each register:

- `R**` is the full 64-bit register
- `E**` or `**D` is the lower 32 bits
- `**W` is the lower 16 bits
- `**B` is the lowest 8 bits
- `*H` (for AH, BH, CH, DH only) is the second lowest 8 bits

Notes:

- The first 8 registers (RAX to RSP) are the original x86 registers extended
  to 64 bits.
- The last 8 registers (R8 to R15) are the new registers introduced with
  x86-64.
- Only the first 4 registers (RAX, RBX, RCX, RDX) have high 8-bit versions.
- For the extended registers (R8-R15), the naming convention is slightly
  different, using suffixes (D, W, B) instead of prefixes. Note that R8-R15
  are the extended registers introduced with x86-64, and they follow a slightly
  different naming convention.

This table provides a clear visual representation of how each register can be
accessed at different bit-widths, which is crucial for understanding x86-64
assembly programming.
