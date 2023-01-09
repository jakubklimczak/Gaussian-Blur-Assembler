.data
    arraysize DQ 0
    iterator DQ 0
    iterator_input DQ 0
    width2 DQ 0
    width4 DQ 0

    kernel:
        DW 1, 2, 1, 2, 4, 2, 1, 2, 1
.code

;RCX -> arraysize
;RDI -> width
;R8/R14 -> red_input
;R9 -> green_input
;RSP+40 -> blue_input
;RSP+48 -> red_output
;RSP+56 -> green_output
;RSP+64 -> blue_output


Gauss proc



    mov [iterator], 0
    mov [iterator_input], 0
    mov [arraysize], 0
    mov [width2], 0
    mov [width4], 0

    mov [arraysize], RCX                    ; moving size of the array into arraysize


    mov rax, 2
    mul rdi
    mov R13, rax

    mov [width2], R13
    add [width2], R13

    mov R14, R8
    ;sub R14,2

    mov R12, qword ptr[RSP+48]

    vmovups ymm8, ymmword ptr [kernel]      ; moving kernel into ymm8
    mov R11, [width2]                       ; moving double of width to R11 

    pxor xmm1,xmm1
RLoop:
    ;vpxor ymm0, ymm0, ymm0
    ;vpxor ymm1, ymm1, ymm1
    ;vpxor ymm3, ymm3, ymm3
    ;vpxor ymm4, ymm4, ymm4

    movd xmm1, dword ptr[R14]           ; moving two pixels into xmm1
    INSERTPS xmm2, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSRLDQ xmm2, 2                      ; shifting xmm0 to right so only one pixel is left

    ;vinsertf128 ymm0, ymm0, xmm0, 1     ; copying lower part of ymm0 into higher part
    INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSLLDQ xmm0, 14
    PSRLDQ xmm0, 10

    movd xmm1, dword ptr[R14+2]         ; moving next two pixels into xmm1
    INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSLLDQ xmm0, 4                      ; shifting xmm0 left by two pixels

    movd xmm1, dword ptr[R14+R13]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 4

    movd xmm1, dword ptr[R14+(R13)+4]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 2

    movd xmm1, dword ptr[R14+(R11)]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 2

    ;pxor xmm1, xmm1                     ; clearing xmm1
    movd xmm1, dword ptr[R14+(R11)+4]   ; moving two pixels into xmm1
    PSRLDQ xmm1, 2                      ; shifting xmm1 right by one pixel
    POR xmm0,xmm1                       ; logic OR on xmm0 and xmm1 so that only one pixel is inserted


    vpmullw xmm4,xmm0,xmm8

    ;VPXOR ymm1, ymm1,ymm1               ; clearing ymm1

    phaddw xmm4,xmm4             ; horizontal addition of results

    phaddw xmm4,xmm4             ; horizontal addition of results

    phaddw xmm4,xmm4             ; horizontal addition of results

    ;VEXTRACTI128 xmm3, ymm4, 1          ; extracting ymm4 into xmm3

    PADDW xmm2, xmm4

    PSRAW xmm2, 4

    mov R10, qword ptr[iterator]

    PEXTRW word ptr[R12+R10], xmm2, 0b

    add iterator, 2
    add iterator_input, 2
    add R14, 2

    mov RAX,iterator_input
    add RAX, 4
    mov RDX, 0
    div R13

    CMP RDX, 0

    jnz NoPixelSkipR
    add R14, 4
    add iterator_input, 4

    NoPixelSkipR:

    dec arraysize
    jnz  RLoop
    ;===========================================GREEN PREPARATION====================================================================

    mov [iterator], 0
    mov [iterator_input], 0
    mov [arraysize], 0
    mov [width2], 0
    mov [width4], 0

    mov [arraysize], RCX                    ; moving size of the array into arraysize


    mov rax, 2
    mul rdi
    mov R13, rax

    mov [width2], R13
    add [width2], R13

    mov R14, R9

    mov R12, qword ptr[RSP+56]
    vmovups ymm8, ymmword ptr [kernel]      ; moving kernel into ymm8

    pxor xmm1,xmm1
    ;==============================================GREEN=================================================================================

    GLoop:
    ;vpxor ymm0, ymm0, ymm0
    ;vpxor ymm1, ymm1, ymm1
    ;vpxor ymm3, ymm3, ymm3
    ;vpxor ymm4, ymm4, ymm4

    movd xmm1, dword ptr[R14]           ; moving two pixels into xmm1
    INSERTPS xmm2, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSRLDQ xmm2, 2                      ; shifting xmm0 to right so only one pixel is left

    ;vinsertf128 ymm0, ymm0, xmm0, 1     ; copying lower part of ymm0 into higher part
    INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSLLDQ xmm0, 14
    PSRLDQ xmm0, 10

    movd xmm1, dword ptr[R14+2]         ; moving next two pixels into xmm1
    INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSLLDQ xmm0, 4                      ; shifting xmm0 left by two pixels

    movd xmm1, dword ptr[R14+R13]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 4

    movd xmm1, dword ptr[R14+(R13)+4]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 2

    movd xmm1, dword ptr[R14+(R11)]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 2

    ;pxor xmm1, xmm1                     ; clearing xmm1
    movd xmm1, dword ptr[R14+(R11)+4]   ; moving two pixels into xmm1
    PSRLDQ xmm1, 2                      ; shifting xmm1 right by one pixel
    POR xmm0,xmm1                       ; logic OR on xmm0 and xmm1 so that only one pixel is inserted


    vpmullw xmm4,xmm0,xmm8

    ;VPXOR ymm1, ymm1,ymm1               ; clearing ymm1

    phaddw xmm4,xmm4             ; horizontal addition of results

    phaddw xmm4,xmm4             ; horizontal addition of results

    phaddw xmm4,xmm4             ; horizontal addition of results

    ;VEXTRACTI128 xmm3, ymm4, 1          ; extracting ymm4 into xmm3

    PADDW xmm2, xmm4

    PSRAW xmm2, 4

    mov R10, qword ptr[iterator]

    PEXTRW word ptr[R12+R10], xmm2, 0b

    add iterator, 2
    add iterator_input, 2
    add R14, 2

    mov RAX,iterator_input
    add RAX, 4
    mov RDX, 0
    div R13

    CMP RDX, 0

    jnz NoPixelSkipG
    add R14, 4
    add iterator_input, 4

    NoPixelSkipG:

    dec arraysize
    jnz  GLoop

;================================BLUE PREPARATION====================================================================================
    mov [iterator], 0
    mov [iterator_input], 0
    mov [arraysize], 0
    mov [width2], 0
    mov [width4], 0

    mov [arraysize], RCX                    ; moving size of the array into arraysize


    mov rax, 2
    mul rdi
    mov R13, rax

    mov [width2], R13
    add [width2], R13

    mov R14, qword ptr[RSP+40]
    ;sub R14,2

    mov R12, qword ptr[RSP+64]
    vmovups ymm8, ymmword ptr [kernel]      ; moving kernel into ymm8

    pxor xmm1,xmm1
;============================================BLUE====================================================================================
    BLoop:
    ;vpxor ymm0, ymm0, ymm0
    ;vpxor ymm1, ymm1, ymm1
    ;vpxor ymm3, ymm3, ymm3
    ;vpxor ymm4, ymm4, ymm4

     movd xmm1, dword ptr[R14]           ; moving two pixels into xmm1
    INSERTPS xmm2, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSRLDQ xmm2, 2                      ; shifting xmm0 to right so only one pixel is left

    ;vinsertf128 ymm0, ymm0, xmm0, 1     ; copying lower part of ymm0 into higher part
    INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSLLDQ xmm0, 14
    PSRLDQ xmm0, 10

    movd xmm1, dword ptr[R14+2]         ; moving next two pixels into xmm1
    INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSLLDQ xmm0, 4                      ; shifting xmm0 left by two pixels

    movd xmm1, dword ptr[R14+R13]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 4

    movd xmm1, dword ptr[R14+(R13)+4]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 2

    movd xmm1, dword ptr[R14+(R11)]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 2

    ;pxor xmm1, xmm1                     ; clearing xmm1
    movd xmm1, dword ptr[R14+(R11)+4]   ; moving two pixels into xmm1
    PSRLDQ xmm1, 2                      ; shifting xmm1 right by one pixel
    POR xmm0,xmm1                       ; logic OR on xmm0 and xmm1 so that only one pixel is inserted


    vpmullw xmm4,xmm0,xmm8

    ;VPXOR ymm1, ymm1,ymm1               ; clearing ymm1

    phaddw xmm4,xmm4             ; horizontal addition of results

    phaddw xmm4,xmm4             ; horizontal addition of results

    phaddw xmm4,xmm4             ; horizontal addition of results

    ;VEXTRACTI128 xmm3, ymm4, 1          ; extracting ymm4 into xmm3

    PADDW xmm2, xmm4

    PSRAW xmm2, 4

    mov R10, qword ptr[iterator]

    PEXTRW word ptr[R12+R10], xmm2, 0b

    add iterator, 2
    add iterator_input, 2
    add R14, 2

    mov RAX,iterator_input
    add RAX, 4
    mov RDX, 0
    div R13

    CMP RDX, 0

    jnz NoPixelSkipB
    add R14, 4
    add iterator_input, 4

    NoPixelSkipB:

    dec arraysize
    jnz  BLoop

    ret
Gauss endp
end