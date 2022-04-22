; Game source code
; Reserved regs:
;   R29 - SP

; DEFINES
=RAM_BASE               0x2000
=RAM_SIZE               0x2000

=GAME_DATA_BASE         0x4000
=SPRITE_MASK_OFFSET     8
=SPRITE_PLAYER_DATA     GAME_DATA_BASE + 0
=SPRITE_PLAYER_MASK     GAME_DATA_BASE + SPRITE_MASK_OFFSET

=LINE_WIDTH             0x20 ; In px

; ENTRY POINT
;     nop
    li RAM_BASE+RAM_SIZE-1         ; Init SP
    mov r29, r0
    li 0
    mov r28, r0
    li 0x0800            ; All of video memory
    mov r2, r0          
    li 0
    mov r1, r0          ; i = 0
:loop_start
    ffl c               ; Set carry
    add r1, r1, r28     ; i += 1
    sw r1, r1           ; mem[i] = 0
    cmp r2, r1, Z       ; Count == 0x2000?
    bfc z, loop_start   ; No, keep going

    li 0
    mov r2, r0
    li 0xbbbbbbbb   ; cyan
    sw r2, r0

    li 3                ; Line 4
    mov r21, r0
    li 76               ; Pixel 76
    mov r20, r0
    li SPRITE_PLAYER_DATA    ; Sprite to display
    mov r22, r0
    jpl draw_sprite

    ; li 0x60
    ; mov r20, r0
    ; li 0
    ; lw r0, r0
    ; sw r20, r0


    nop

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
    sw r29, r30         ; Save return address
    li -1
    ffl x
    add r29, r29, r0
    
    ; Save X
    mov r17, r20

    ; calculate line
    ; y * line_width
    li LINE_WIDTH
    mov r20, r0
    jpl mult
    
    ; Determine line index
    srl r21, r17, 3     ; Divide out pixel number (FIXME)
    ffl X               ; Clear C
    add r20, r20, r21

    ; BEGIN LOOP
    li 0                ; Init loop var
    mov r10, r0
    
    li 1
    ffl C
    sub r22, r22, r0    ; Start sprite pointer at address minus 1

:sprite_loop
    ; Currently,
    ;    r10 stores the loop count
    ;    r20 stores the base offset of the video data word
    ;    r22 stores the pointer to the sprite data base
    ffl x
    li 1
    add r22, r22, r0    ; Increment sprite data pointer
    lw r13, r22         ; Get the sprite's line of data
    ffl x
    li SPRITE_MASK_OFFSET
    add r0, r22, r0
    lw r14, r0          ; Get the sprite's corresponding line mask
    and r13, r13, r14   ; Apply the mask

    ; Regs used below:
    ;    r13 - Sprite low data
    ;    r15 - Sprite high data
    ;    r14 - Sprite low mask
    ;    r16 - Sprite high mask
    ;    r17 - Pixel horiz word offset
    ;    r21 - Jump address for LUTs
    mov r15, r13
    mov r16, r14
    ; Handle high data/mask shifting
    li 7
    and r17, r17, r0    ; Mask off index into word
    mov r21, r17        ; Copy into jump reg
    sll r21, r21, 3     ; jump index * 2 * 4
    li sprite_shift_lut_high
    ffl x
    add r21, r21, r0
    jmp r21

:sprite_shift_lut_high
    srl r15, r15, 4     ; 28 Shift data
    srl r16, r16, 4     ; Same for the mask
    srl r15, r15, 4     ; 24
    srl r16, r16, 4
    srl r15, r15, 4     ; 20
    srl r16, r16, 4
    srl r15, r15, 4     ; 16
    srl r16, r16, 4 
    srl r15, r15, 4     ; 12
    srl r16, r16, 4
    srl r15, r15, 4     ; 8
    srl r16, r16, 4
    srl r15, r15, 4     ; 4
    srl r16, r16, 4
    srl r15, r15, 4     ; 0
    srl r16, r16, 4
    
    ; Handle low data/mask shifting
:sprite_shift_low
    li 7
    eor r21, r17, r0    ; Invert index bits (reverse count direction)
    sll r21, r21, 3     ; jump index * 2 * 4
    li sprite_shift_lut_low
    ffl x
    add r21, r21, r0
    jmp r21

:sprite_shift_lut_low
    sll r13, r13, 4     ; 28 Shift data
    sll r14, r14, 4     ; Same for the mask
    sll r13, r13, 4     ; 24
    sll r14, r14, 4
    sll r13, r13, 4     ; 20
    sll r14, r14, 4
    sll r13, r13, 4     ; 16
    sll r14, r14, 4 
    sll r13, r13, 4     ; 12
    sll r14, r14, 4
    sll r13, r13, 4     ; 8
    sll r14, r14, 4
    sll r13, r13, 4     ; 4
    sll r14, r14, 4
    ;nop                ; 0
    ;nop

    ; Read vmem and get the data present under the current sprite location
    ; Regs:
    ;    r10 - loop index
    ;    r11 - vmem data low
    ;    r12 - vmem data high
    ;    r13 - Sprite low data
    ;    r15 - Sprite high data
    ;    r14 - Sprite low mask
    ;    r16 - Sprite high mask
    ;    r17 - Pixel horiz word offset
    ;    r20 - vmem addr low
    ;    r21 - vmem addr high
    ;    r22 - Sprite data pointer
    li 0                ; Calculate high byte address
    ffl c
    add r21, r20, r0
    lw r11, r20         ; Get low word of vdata
    lw r12, r21         ; Get high word of vdata
    li 0xffffffff       ; Invert the masks
    eor r14, r14, r0
    eor r16, r16, r0
    and r11, r11, r14   ; And apply them to vmem
    and r12, r12, r16
    or r11, r11, r13    ; Or the sprite data into vmem
    or r12, r12, r15
    sw r20, r11
    sw r21, r12

    ; Next byte of data
    ffl x
    li LINE_WIDTH       ; Move vmem pointer to next line
    add r20, r20, r0
    li 1                ; Increment loop var
    add r10, r10, r0
    li 8                ; 8 iterations (8 pixels tall)
    cmp r10, r0, Z
    bfc Z,sprite_loop
    
    li 1                ; Return
    ffl x
    add r29, r29, r0
    lw r0, r29
    jmp r0


    
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
    