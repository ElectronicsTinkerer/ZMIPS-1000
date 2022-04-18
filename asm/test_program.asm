; Test data file


; DEFINES
=game_data_base         0x2000
=sprite_player_data      game_data_base + 0
=sprite_player_mask      game_data_base + 8

; ENTRY POINT
;     li 0
;     mov r28, r0
;     li 0x4000            ; Half of video memory
;     mov r2, r0          
;     li 0
;     mov r1, r0          ; i = 0
; :loop_start
;     ffl c               ; Set carry
;     add r1, r1, r28     ; i += 1
;     sw r1, r1           ; mem[i] = 0
;     cmp r2, r1, Z       ; Count == 0x2000?
;     bfc z, loop_start   ; No, keep going

    li 0x40
    mov r2, r0
    li 0xbbbbbbbb   ; cyan
    sw r2, r0

    li 4                ; Line 4
    mov r21, r0
    li 76               ; Pixel 76
    mov r20, r0
    li sprite_player_data    ; Sprite to display
    mov r22, r0

    jpl draw_sprite

:spin
    jpl spin           ; Spin


; Draw a 8x8 pixel sprite to a position on screen
; Args: 
;   r20 - X posiiton
;   r21 - Y position
;   r22 - Base address of sprite data (pointer)
; Uses:
;   mult:
;       R0, R10, R11
;   self:
;       R12, R13, R14
; Return:
;   NONE
:draw_sprite
    
    ; Save X
    mov r12, r20

    ; calculate line
    ; y * 0x40
    li 0x40             ; Line width
    mov r20, r0
    jpl mult
    
    ; Determine line index
    srl r21, r12, 3     ; Divide out pixel number (FIXME)
    ffl X               ; Clear C
    add r20, r20, r21

    ; Currently, r20 stores the base offset of the video data word
    lw r13, r22         ; Get the sprite's line of data
    lw r14, r22         ; Get the sprite's corresponding line mask
    and r13, r13, r14

;     li 7
;     and r12, r12, r0    ; Mask off index into word
;     eor r21, r12, r0    ; Invert index bits (reverse count direction)
;     sll r21, r21, 3     ; jump index * 2 * 4
;     li sprite_shift_lut
;     add r21, r21, r0
;     jmp r21

; :sprite_shift_lut
;     sll r13, r13, 4     ; 28 Shift both the data
;     sll r14, r14, 4     ;  and the mask
;     sll r13, r13, 4     ; 24
;     sll r14, r14, 4
;     sll r13, r13, 4     ; 20
;     sll r14, r14, 4
;     sll r13, r13, 4     ; 16
;     sll r14, r14, 4 
;     sll r13, r13, 4     ; 12
;     sll r14, r14, 4
;     sll r13, r13, 4     ; 8
;     sll r14, r14, 4
;     sll r13, r13, 4     ; 4
;     sll r14, r14, 4
;     nop                 ; 0
;     nop
    


    li sprite_player_data    ; Sprite to display
    lw r0, r0
    ; li 0x60
    ; mov r20, r0
    ; li 0xffffffff
    sw r20, r0

    jpl spin


    
; Multiply two numbers
; Args:
;   R20 - X
;   R21 - Y
; Uses:
;   R0
;   R10 - Accumulator
;   R11 - Loop index
; Return:
;   {R21, R20} = X * Y
:mult
    li 0
    mov r10, r0
    mov r20, r20, Z     ; If X == 0, don't multiply
    bfs Z, mult_0
    mov r21, r21, Z     ; If Y == 0, don't multiply
    bfs Z, mult_0
    li 32               ; 32 bits to multiply
    mov r11, r0
:mult_loop
    srl r0, r20, 1, c   ; Get next bit of X
    bfc C, mult_next    ; If carry is clear, then skip iteration
    ffl X               ; Clear carry
    add r10, r10, r21   ; Add Y to accumulator
:mult_next
    srl r10, r10, 1, C  ; Shift lsb of accumulator out.
    srl r20, r20, 1     
    bfc C, mult_indx    ; If carry clear, don't shift a 1 in to accumulator msb
    li 1
    sll r0, r0, 31      ; Set MSB
    or r20, r20, r0, C  ; Also clears C
:mult_indx
    li -1
    add r11, r11, r0, Z ; C is clear, so subtract 1 from index
    bfs Z, mult_ret     ; If index = 0, we're done
    bfc Z, mult_loop    ; Otherwise, move on to next bit

:mult_0
    mov r20, r0         ; R0 and R10 are already cleared from beginning of mult
:mult_ret
    mov r21, r10        ; Return MSW of result (since it's 64-bit)
    jmp R30             ; Return
    