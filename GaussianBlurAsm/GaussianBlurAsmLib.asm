.data
.code

Gauss proc
shr R8, 1
    
    vmovups	ymm0, ymmword ptr[rcx]

MLoop:
    vmovups ymmword ptr[rdx], ymm0
    add rdx, 32

    dec R8
    jnz  MLoop

    ret
Gauss endp
end