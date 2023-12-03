.intel_syntax noprefix

exit:
    mov rax, 0x3c
    syscall

open:
    mov rax, 2
    syscall
    ret

write:
    mov rax, 1
    syscall
    ret

read:
    mov rax, 0
    syscall
    ret

// rdi: buf
// rsi: length
memzero:
    movq r8, 0
memzero_loop:
    mov BYTE PTR [rdi + r8], 0
    inc r8
    cmp r8, rsi
    jle memzero_loop
    ret

// read a line into buf
// rdi: fd
// rsi: buf
readline:
    movq r9, rdi
    xor r8, r8
readline_loop:
    movq rdi, r9
    lea rsi, data
    add rsi, r8
    movq rdx, 1
    call read

    cmp rax, 0x0
    je readline_fail

    // check if the read char is a newline
    lea rsi, data
    add rsi, r8

    xor rax, rax
    mov al, BYTE PTR [rsi]
    inc r8
    cmp rax, 0x0a
    jne readline_loop
    movq rax, r8
    ret
readline_fail:
    movq rax, 0
    ret

// dl: the digit byte
is_digit:
    cmp dl, 48
    jl is_digit_fail
    cmp dl, 57
    jg is_digit_fail
    movq rax, 1
    ret    
is_digit_fail:
    movq rax, 0
    ret

first_digit:
    xor r8, r8

first_digit_loop:
    lea rsi, data
    add rsi, r8
    xor rax, rax
    mov al, BYTE PTR [rsi]
    mov dl, al
    call is_digit
    inc r8
    cmp rax, 1
    jne first_digit_loop

    dec r8
    lea rsi, data
    add rsi, r8
    xor rax, rax
    mov al, BYTE PTR [rsi]
    ret


last_digit:
    xor r8, r8
    xor r10, r10

last_digit_loop:
    lea rsi, data
    add rsi, r8
    xor rax, rax
    mov bl, BYTE PTR [rsi]
    mov dl, bl
    call is_digit
    cmp rax, 0x0
    je last_digit_not_digit
    
    xor rbx, rbx
    mov bl, BYTE PTR [rsi]
    xor r10, r10
    movq r10, rbx    

last_digit_not_digit:
    inc r8
    cmp bl, 0
    jne last_digit_loop

    movq rax, r10
    ret


// rdi: the integer
print_integer:
    movq r9, rdi

    lea rdi, number_print_buf
    movq rsi, 128
    call memzero    

    movq r8, r9

    xor rax, rax
    mov rcx, 10
    lea rbx, number_print_buf
    add rbx, 0x30
    mov BYTE PTR [rbx], 0x0a
    movq rax, r9

print_integer_loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    dec rbx
    mov BYTE PTR [rbx], dl
    test rax, rax
    jnz print_integer_loop

    movq rdi, 0x1
    movq rsi, rbx
    movq rdx, 30
    call write
    ret



.global _start
_start:
    sub rsp, 0x80

    lea rdi, filename
    mov rsi, 0
    mov rdx, 0
    call open

    //fd of input file
    movq [rsp + 0x8], rax

    // accumulator
    movq [rsp + 0x10], 0

main_loop:
    lea rdi, data
    movq rsi, 128
    call memzero

    movq rdi, QWORD PTR [rsp + 0x8]
    lea rsi, data
    call readline
    cmp rax, 0x0
    je main_loop_exit

    call first_digit

    sub rax, '0'
    movq rcx, 10
    mul rcx
    add QWORD PTR [rsp + 0x10], rax

    call last_digit
    sub rax, '0'
    add QWORD PTR [rsp + 0x10], rax

    jmp main_loop

main_loop_exit:
    // print the answer
    movq rdi, 0x1
    lea rsi, hello_world 
    movq rdx, 15
    call write

    movq rdi, QWORD PTR [rsp + 0x10]
    call print_integer

    movq rdi, 0
    call exit


.section .data
hello_world:
    .ascii "The answer is: "

filename:
    .ascii "input.txt\0"

data:
    .string "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

number_print_buf:
    .string "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
