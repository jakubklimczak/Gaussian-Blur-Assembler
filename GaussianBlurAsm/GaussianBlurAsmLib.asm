.data
    arraysize DQ 0
    iterator DQ 0
    iterator_input DQ 0
    width2 DQ 0
    border_detector DQ 0

    kernel:
        DW 1, 1, 2, 4, 2, 2, 2, 1, 1
        ; our kerenl is:
        ; 1, 2, 1,
        ; 2, 4, 2,
        ; 1, 2, 1
        ; but data that we insert into regsiters is not in correct order
.code

;RCX -> arraysize
;RDI -> width
;R8 -> red_input
;R9 -> green_input
;RSP+40 -> blue_input
;RSP+48 -> red_output
;RSP+56 -> green_output
;RSP+64 -> blue_output

;R13 -> width but in bytes, so RDI*2
;R14 -> current color input ptr
;R12 -> current color output ptr


Gauss proc
;==================================clearing iterators=====================================================
    mov [iterator], 0
    mov [iterator_input], 0
    mov [arraysize], 0
    mov [width2], 0
;=========================================================================================================

    mov [arraysize], RCX                    ; moving size of the picture(in pixels) into arraysize

    mov rax, 2
    mul rdi
    mov R13, rax                            ; moving width of picture into R13, in fact it is width but in bytes

    mov [width2], R13                       
    add [width2], R13                       ; moving double 

    mov [border_detector], R13
    sub [border_detector], 4

    mov R14, R8                             ; moving red input ptr into R14

    mov R12, qword ptr[RSP+48]              ; moving red output ptr into R12

    vmovups ymm8, ymmword ptr [kernel]      ; moving kernel into ymm8
    mov R11, [width2]                       ; moving double of width to R11 

    pxor xmm1,xmm1
RLoop:

    movd xmm1, dword ptr[R14]           ; moving two pixels into xmm1
    INSERTPS xmm2, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm2
    PSLLDQ xmm2, 14                     ; shifting xmm2 to left so that only first pixel is left
    PSRLDQ xmm2, 14                     ; shifting xmm2 to right to get into initial position
    ;the pixel above is the only pixel in xmm2, as it should be multiplied by 1 we just add it at the end

    movd xmm1, dword ptr[R14+2]         ; moving pixel No. 2 & 3 into xmm1
    INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing rest of xmm0)
    PSLLDQ xmm0, 4                      ; shifting xmm0 left by two pixels

    movd xmm1, dword ptr[R14+R13]       ; moving two pixels from 2nd row into xmm1
    INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0
    PSLLDQ xmm0, 4                      ; moving xmm0 to left by two 'pixels'

    movd xmm1, dword ptr[R14+(R13)+4]   ; moving two next pixels into xmm1
    PSLLDQ xmm1, 14                     ; deleting the 4th pixel
    PSRLDQ xmm1, 12
    INSERTPS xmm0, xmm1, 00000000b      ; inserting 3rd pixel into xmm0
    PSLLDQ xmm0, 2                      ; moving left only by one pixel because  we inserted only one new pixel

    movd xmm1, dword ptr[R14+(R11)]     ; inserting two pixels from 3rd row
    INSERTPS xmm0, xmm1, 00000000b      ; inserting into xmm0
    PSLLDQ xmm0, 2                      ; moving left only by one pixel as only one pixel is left to insert

    movd xmm1, dword ptr[R14+(R11)+4]   ; moving two pixels into xmm1
    PSLLDQ xmm1, 14                     ; leaving only the 3rd pixel that we accutally need
    PSRLDQ xmm1, 14
    POR xmm0,xmm1                       ; logic OR on xmm0 and xmm1 so that only one pixel is inserted


    vpmullw xmm4,xmm0,xmm8              ;multiplying 8 pixels by kernel

    vphaddw ymm4,ymm4,ymm6              ; horizontal addition of results

    vphaddw ymm4,ymm4,ymm6              ; horizontal addition of results

    vphaddw ymm4,ymm4,ymm6              ; horizontal addition of results

    PADDW xmm2, xmm4                    ; now we need to add one pixel left in xmm2

    PSRAW xmm2, 4                       ; dividing the result by 16

    mov R10, qword ptr[iterator]        ; moving output pixel iterator into R10 so we can use it in addressing

    PEXTRW word ptr[R12+R10], xmm2, 0b  ; extracting result from xmm2 into output array

    add iterator, 2                     ; moving iterators
    add iterator_input, 2
    add R14, 2

    mov RAX,border_detector             ; we check if are at the end of picture if so we need to skip two pixels, 
    CMP RAX, [iterator_input]           ; because we added border to input picture

    jnz NoPixelSkipR
    add R14, 4                          ; if we are at the picture edge we need to move iterator and pointers once again
    add iterator_input, 4
    add [border_detector],R13           ; adding width to border_detector so it can be used in next loop

    NoPixelSkipR:

    dec arraysize
    jnz  RLoop
    ;===========================================GREEN PREPARATION====================================================================

    mov [iterator], 0
    mov [iterator_input], 0
    mov [arraysize], 0
    mov [width2], 0
    mov [border_detector], R13
    sub [border_detector], 4

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

    movd xmm1, dword ptr[R14]           ; moving two pixels into xmm1
    INSERTPS xmm2, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSLLDQ xmm2, 14
    PSRLDQ xmm2, 14                    ; shifting xmm0 to right so only one pixel is left

    ;vinsertf128 ymm0, ymm0, xmm0, 1     ; copying lower part of ymm0 into higher part
    ;INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    ;PSRLDQ xmm0, 2

    movd xmm1, dword ptr[R14+2]         ; moving next two pixels into xmm1
    INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSLLDQ xmm0, 4                      ; shifting xmm0 left by two pixels

    movd xmm1, dword ptr[R14+R13]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 4

    movd xmm1, dword ptr[R14+(R13)+4]
    PSLLDQ xmm1, 14
    PSRLDQ xmm1, 12
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 2

    movd xmm1, dword ptr[R14+(R11)]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 2

    ;pxor xmm1, xmm1                     ; clearing xmm1
    movd xmm1, dword ptr[R14+(R11)+4]   ; moving two pixels into xmm1
    PSLLDQ xmm1, 14
    PSRLDQ xmm1, 14
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

    ;mov RAX,iterator_input
    ;add RAX, 4
    ;mov RDX, 0
    ;div R13

    ;CMP RDX, 0

    mov RAX,border_detector
    CMP RAX, [iterator_input]

    jnz NoPixelSkipG
    add R14, 4
    add iterator_input, 4
    add [border_detector], R13

    NoPixelSkipG:

    dec arraysize
    jnz  GLoop

;================================BLUE PREPARATION====================================================================================
    mov [iterator], 0
    mov [iterator_input], 0
    mov [arraysize], 0
    mov [width2], 0
    mov [border_detector], R13
    sub [border_detector], 4

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
    PSLLDQ xmm2, 14
    PSRLDQ xmm2, 14                    ; shifting xmm0 to right so only one pixel is left

    ;vinsertf128 ymm0, ymm0, xmm0, 1     ; copying lower part of ymm0 into higher part
    ;INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    ;PSRLDQ xmm0, 2

    movd xmm1, dword ptr[R14+2]         ; moving next two pixels into xmm1
    INSERTPS xmm0, xmm1, 00000000b      ; inserting two pixels from xmm1 into xmm0 (without lossing other)
    PSLLDQ xmm0, 4                      ; shifting xmm0 left by two pixels

    movd xmm1, dword ptr[R14+R13]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 4

    movd xmm1, dword ptr[R14+(R13)+4]
    PSLLDQ xmm1, 14
    PSRLDQ xmm1, 12
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 2

    movd xmm1, dword ptr[R14+(R11)]
    INSERTPS xmm0, xmm1, 00000000b
    PSLLDQ xmm0, 2

    ;pxor xmm1, xmm1                     ; clearing xmm1
    movd xmm1, dword ptr[R14+(R11)+4]   ; moving two pixels into xmm1
    PSLLDQ xmm1, 14
    PSRLDQ xmm1, 14
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

    ;mov RAX,iterator_input
    ;add RAX, 4
    ;mov RDX, 0
    ;div R13
    ;CMP RDX, 0

    mov RAX,border_detector
    CMP RAX, [iterator_input]


    jnz NoPixelSkipB
    add R14, 4
    add iterator_input, 4
    add [border_detector], R13

    NoPixelSkipB:

    dec arraysize
    jnz  BLoop

    ret
Gauss endp
end