.data
.code

Gauss proc
    
MLoop:

    ;mov ax, byte ptr[rcx]  
   ; movd xmm0, ax
    ;INSERTPS xmm0, xmm1, 00000000b
    ;PSLLDQ xmm0, 4

    ;vmovaps [rdx],ymm0

    ;vpslld ymm0, ymm0, 8



    add rdx, 32
    add rcx, 32

    dec R8
    jnz  MLoop

    ret
Gauss endp
end