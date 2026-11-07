.globl _start
.type  _start,@function
_start:
    xor  %ebp, %ebp
    call main@PLT
    mov  %eax, %edi
    call exit@PLT
    hlt
.size _start, .-_start

.section .note.GNU-stack,"",@progbits
