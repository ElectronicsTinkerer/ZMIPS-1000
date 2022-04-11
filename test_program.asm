; Test data file
    nop
    nop
    nop
    li 0
    mov r29, r0
    li 0x40            ; Half of video memory
    mov r2, r0          
    li 0
    mov r1, r0          ; i = 0
:loop_start
    ffl c               ; Set carry
    add r1, r1, r29     ; i += 1
    sw r1, r1           ; mem[i] = 0
    cmp r2, r1, Z       ; Count == 0x2000?
    bfc z, loop_start   ; No, keep going

    ; li 0x69abcdef
    ; sw r2, r0
:spin
    jpl spin           ; Spin

