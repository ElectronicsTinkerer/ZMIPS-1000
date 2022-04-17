; Test data file
    nop
    nop
    nop
    li 0
    mov r29, r0
    li 0x4000            ; Half of video memory
    mov r2, r0          
    li 0
    mov r1, r0          ; i = 0
:loop_start
    jpl mul
    ffl c               ; Set carry
    add r1, r1, r29     ; i += 1
    sw r1, r1           ; mem[i] = 0
    cmp r2, r1, Z       ; Count == 0x2000?
    bfc z, loop_start   ; No, keep going

    li 0xffffffff
    sw r2, r0
:spin
    jpl spin           ; Spin


; Args: 
;   r20 - X posiiton
;   r21 - Y position
;   r22 - Base address of sprite data
:draw_sprite
    
    ; calculate line
    ; y * 0x40
    
    li 0xffffffff
    
; Multiply two numbers
; Args:
;   R20 - X
;   R21 - Y
; Uses:
;   R0
;   R10
;   R11
; Return:
;   R20 = X * Y
:mul
    mov r20, r20, Z     ; If X == 0, don't multiply
    bfs Z, mul_0
    mov r21, r21, Z     ; If Y == 0, don't multiply
    bfs Z, mul_0
    mov r10, r20        ; Copy X
    li 0x20             ; 32 bits to multiply
:mult_loop
    srl r20, r20, 1, c  ; Get next bit of A
    bfc tb_0, c         ; If carry is set, then add B
         
:mul_0
    li 0
    mov r20, r0
:mul_ret
    jmp R30         ; Return
