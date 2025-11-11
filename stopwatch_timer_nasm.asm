global main
extern GetTickCount64, printf, getchar, Sleep, _kbhit

section .text
main:
    sub rsp, 40              ; Shadow space + stack alignment

    ; Prompt to start
    lea rcx, [rel msg_start]
    xor rax, rax
    call printf

    call getchar             ; Wait for Enter to start

    ; Get initial tick count
    call GetTickCount64
    mov rbx, rax             ; Store start time in rbx
    xor rsi, rsi             ; Previous seconds = 0

.loop:
    ; Check if input is available (non-blocking)
    call _kbhit
    test eax, eax
    jnz .end_stopwatch       ; If key pressed, break loop

    ; Get current tick
    call GetTickCount64
    sub rax, rbx             ; Elapsed milliseconds
    mov rcx, 1000
    xor rdx, rdx
    div rcx                  ; RAX = seconds, RDX = milliseconds

    cmp rax, rsi
    jz .wait

    mov rsi, rax             ; Update last second printed
    lea rcx, [rel msg_sec]
    mov rdx, rax
    xor rax, rax
    call printf

.wait:
    ; Sleep(100 ms) to avoid 100% CPU
    mov ecx, 100
    call Sleep
    jmp .loop

.end_stopwatch:
    ; Consume the key (Enter) after _kbhit triggers
    call getchar

    ; Get final time
    call GetTickCount64
    sub rax, rbx             ; Total elapsed ms
    mov rcx, 1000
    xor rdx, rdx
    div rcx                  ; RAX = seconds, RDX = ms

    ; Print final result
    lea rcx, [rel msg_result]
    mov rdx, rax             ; seconds
    xor rax, rax
    call printf

    ; Wait for Enter before exiting
    call getchar

    add rsp, 40
    xor eax, eax
    ret

section .data
    msg_start  db "Press Enter to start stopwatch...", 10, 0
    msg_sec    db "Elapsed: %llu seconds", 10, 0
    msg_result db "Stopwatch stopped. Total time: %llu seconds", 10, 0

section .bss
