.data
    choice DD 6000
.code

;RCX -> arraysize
;RDX -> width
;R8 -> red_input
;R9 -> green_input
;RSP+40 -> blue_input
;RSP+48 -> red_output
;RSP+56 -> green_output
;RSP+64 -> blue_output

;mov rax,[rsp+40]

Gauss proc
    imul rdx,2

MLoop:

    
    ;mov eax, [R8]

    ;mov eax, byte ptr[rcx]  


    movd xmm1, dword ptr[R8]            ; moving two pixels into xmm1
    INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSRLDQ xmm0, 2                      ; shifting xmm0 to right so only one pixel is left

    vinsertf128 ymm0, ymm0, xmm0, 1     ; copying lower part of ymm0 into higher part
    pxor xmm0, xmm0                     ; clearing xmm0

    movd xmm1, dword ptr[R8+16]         ; moving next two pixels into xmm1
    INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSLLDQ xmm0, 4                      ; shifting xmm0 left by two pixels

    movd xmm1, dword ptr[R8+(RDX)]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 4

    movd xmm1, dword ptr[R8+(RDX)+32]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 2

    movd xmm1, dword ptr[R8+(2*RDX)]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 2

    pxor xmm1, xmm1                     ; clearing xmm1
    movd xmm1, dword ptr[R8+(2*RDX)+32] ; moving two pixels into xmm1
    PSRLDQ xmm1, 2                      ; shifting xmm1 right by one pixel
    POR xmm0,xmm1                       ; logic OR on xmm0 and xmm1 so that only one pixel is inserted

    ;PINSRW xmm0, eax, 0



    ;vpslldq ymm0, ymm0, 0

    ;vmovaps ymm2,ymm0

    ;vpslld ymm0, ymm0, 8



    ;add rdx, 8
    ;add rcx, 8

    dec choice
    jnz  MLoop

    ret
Gauss endp
end