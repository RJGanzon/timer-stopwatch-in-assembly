global main
extern printf, getchar, Sleep, GetTickCount64

section .text
main:
    sub rsp, 40              ; shadow space

    ; Prompt user to enter time
    lea rcx, [rel msg_prompt]
    xor rax, rax
    call printf

    ; Read digits and convert to number
    xor rbx, rbx             ; RBX will hold the final number (seconds)
.read_loop:
    call getchar
    cmp al, 10               ; Enter key?
    je .start_timer
    cmp al, '0'
    jl .read_loop            ; Ignore non-digits
    cmp al, '9'
    jg .read_loop

    ; Convert ASCII to number: rbx = rbx * 10 + (al - '0')
    imul rbx, rbx, 10
    sub al, '0'
    movzx rax, al
    add rbx, rax
    jmp .read_loop

.start_timer:
    ; Countdown loop
.count_loop:
    cmp rbx, 0
    je .time_up

    ; Print remaining time
    lea rcx, [rel msg_countdown]
    mov rdx, rbx
    xor rax, rax
    call printf

    ; Sleep 1000 ms (1 second)
    mov ecx, 1000
    call Sleep

    dec rbx
    jmp .count_loop

.time_up:
    lea rcx, [rel msg_done]
    xor rax, rax
    call printf

    ; Wait for Enter before exiting
    call getchar

    add rsp, 40
    xor eax, eax
    ret

section .data
    msg_prompt    db "Enter number of seconds for countdown: ", 0
    msg_countdown db "Remaining: %llu seconds", 10, 0
    msg_done      db "Time's up!", 10, 0

section .bss
