; Register purpose:
; PARAMETERES GIVEN IN FUNCTION ARE STORED IN:
; rdi  - buff - memory allocated for pixel array; buff is first address in memory
; rsi  - width of pixel array
; rdx  - height of pixel array
; rcx  - max iterations to check if c is in set
; r8   - out point - helps determine hue based of number of iterations
; xmm0 - zoom - self-explanatory
; xmm1, xmm2 - re, im offset
; REGISTERS PURPOSE FOR VALUES STORED DURING ASM PROGRAM:
; r9 - x iterator
; r10 - y iterator
; xmm4, xmm5 - re c, im c
; r11 - mandelbrot iterator
; xmm6, xmm7 - re z, im z
; xmm8, xmm9 - re, im of next iteration of functions
section .text
global mandelbrot

mandelbrot:
    ; prolog
    push rbp
    mov rbp, rsp
    sub rsp, 32
    push rbx
    push r12
    push r13
    push r14

    ; prepare values for loop
    mov r9, 0          ; x = 0

x_loop:
    cmp r9, rsi
    jge end            ; if x has reached width end

    ; prepare values for y_loop
    mov r10, 0         ; y = 0
    ; calculate real val of c
    mov rax, r9        ; load x
    shl rax, 2         ; mul by 4
    cvtsi2sd xmm4, rax
    mov rax, rsi       ; load width
    shl rax, 1         ; mul by 2
    cvtsi2sd xmm3, rax
    subsd xmm4, xmm3  
    cvtsi2sd xmm3, rsi ; load width
    mulsd xmm3, xmm0   ; mul by zoom
    divsd xmm4, xmm3
    addsd xmm4, xmm1
    ; xmm4 - real val of c
    ; calculate real val of c

y_loop:
    cmp r10, rdx
    jge small_end      ; if y has reached height end y_loop

    ; calculate imaginary val of c
    ; (y / height - 0.5) * 4.0 / zoom + centerImag
    mov rax, r10        ; load y
    shl rax, 2          ; mul by 4
    cvtsi2sd xmm5, rax
    mov rax, rdx        ; load height
    shl rax, 1          ; mul by 2
    cvtsi2sd xmm3, rax
    subsd xmm5, xmm3
    cvtsi2sd xmm3, rdx  ; load height
    mulsd xmm3, xmm0    ; mul by zoom
    divsd xmm5, xmm3
    addsd xmm5, xmm2
    ; xmm5 - imaginary value of c

    ; prepare values for mandelbrot set check
    mov r11, 0          ; mandelbrot iterator
    xorpd xmm6, xmm6    ; re z
    xorpd xmm7, xmm7    ; im z

is_in_set:
    cmp r11, rcx
    jge in_set
    inc r11

    ; calculate next iteration of function
    ; z = a + bj
    movsd xmm8, xmm6
    mulsd xmm8, xmm6    ; a^2
    movsd xmm9, xmm7
    mulsd xmm9, xmm7    ; b^2
    subsd xmm8, xmm9    ; re z^2

    movsd xmm9, xmm6
    mulsd xmm9, xmm7
    addsd xmm9, xmm9    ; im z^2

    addsd xmm8, xmm4    ; add re c
    addsd xmm9, xmm5    ; add im c

    movsd xmm6, xmm8
    movsd xmm7, xmm9

    ; prepare to check if reached out point
    mulsd xmm8, xmm6
    mulsd xmm9, xmm7
    addsd xmm8, xmm9
    ; check if reached out point
    mov rax, r8
    imul rax, r8
    cvtsi2sd xmm10, rax
    ucomisd xmm8, xmm10
    jbe is_in_set

    jmp paint_by_itr

in_set:
    ; calculate buf position
    mov rax, r10        
    imul rax, rsi
    add rax, r9
    shl rax, 2
    mov r12, rax

    ; check buf range
    mov rax, rsi
    imul rax, rdx
    mov r13, rax
    shl r13, 2
    mov rax, r12
    add rax, 3
    cmp rax, r13
    jge end

    ; Paint it, Black by The Rolling Stones
    add r12, rdi
    mov byte [r12], 0
    mov byte [r12 + 1], 0
    mov byte [r12 + 2], 0
    mov byte [r12 + 3], 255

    jmp next

paint_by_itr:
    ; calculate color
    mov rax, r11
    imul rax, 3
    mov byte [rbp - 1], al
    mov rax, r11
    imul rax, 30
    mov byte [rbp - 2], al
    mov rax, r11
    imul rax, 60
    mov byte [rbp - 3], al
    
    ; calculate buf position
    mov rax, r10        
    imul rax, rsi
    add rax, r9
    shl rax, 2
    mov r12, rax

    ; check buf range
    mov rax, rsi
    imul rax, rdx
    shl rax, 2
    mov r13, rax
    mov rax, r12
    add rax, 3
    cmp rax, r13
    jge end

    ; paint pixel
    add r12, rdi
    mov bl, byte [rbp - 1]
    mov byte [r12], bl
    mov bl, byte [rbp - 2]
    mov byte [r12 + 1], bl
    mov bl, byte [rbp - 3]
    mov byte [r12 + 2], bl
    mov byte [r12 + 3], 255

next:
    inc r10                 ; increment y
    jmp y_loop

small_end:
    inc r9                 ; increment x
    jmp x_loop

end:
    ; Epilogue
    pop r14
    pop r13
    pop r12
    pop rbx
    add rsp, 32
    mov rsp, rbp
    pop rbp
    ret