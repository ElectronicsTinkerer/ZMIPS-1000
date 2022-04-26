; Game source code
; Reserved regs:
;   R29 - SP
;
; "Recommended reg usage":
; r0  - r9  => temp
; r10 - r19 => internal
; r20 - r28 => args
;


; TODO:
; Lives Display?
; Draw score function
; ~~Move background code to a function (pointers to from and to buffers)
; Enemy spawning
; RNG
; Firing of missiles (potatos)
; Collision detection

; DEFINES
=RAM_BASE               0x2000
=RAM_SIZE               0x2000
=GAME_DATA_BASE         0x4000
=INPUT_OFFSET           0x8000
=VCORE_OFFSET           0xc000

; Screen info
=LINE_WIDTH             0x20 ; In words (8px/word)
=SCREEN_WORDS           0x1000

; Graphic data
=SPRITE_MASK_OFFSET     8

=BACKGROUND_TITLE       GAME_DATA_BASE + 0
=BACKGROUND_GAMEPLAY    GAME_DATA_BASE + SCREEN_WORDS

=SPRITE_PLAYER_DATA     GAME_DATA_BASE + (2 * SCREEN_WORDS)
=SPRITE_PLAYER_MASK     GAME_DATA_BASE + SPRITE_MASK_OFFSET

; Controls
=BTN_DOWN               1
=BTN_UP                 2
=BTN_FIRE               4


; ENTRY POINT
    li RAM_BASE+RAM_SIZE-1         ; Init SP
    mov r29, r0

    li 120
    mov r1, r0
    li 0
    mov r2, r0
:title_loop
;     li INPUT_OFFSET
;     lw r3, r0
;     li 1
;     and r31, r3, r0, Z          ; Can't write to r31, so use as dummy
;     bfs z, player_go_right
;     li 2
;     and r31, r3, r0, Z
;     bfc Z,loop
;     li 1
;     ffl c
;     sub r2, r2, r0
;     jpl player_move
; :player_go_right

    ; Redraw background (so we don't have "painting")
    li 0                        ; Base of video memory (first buffer)
    mov r20, r0
    li BACKGROUND_TITLE
    mov r21, r0
    jpl draw_background

    li 1
    ffl x
    add r2, r2, r0
:title_draw_player
    li 0xff
    and r2, r2, r0
    mov r20, r2                 ; Setup X, Y position
    mov r21, r1

    li VCORE_OFFSET             ; Get the current frame number
    lw r4, r0
    li 0x800                    ; Bit to determine spaceship animation state
    and r31, r4, r0, Z
    bfc Z,title_player_on
:title_ player_off
    li SPRITE_PLAYER_DATA       ; Sprite to display
    jpl title_update
:title_player_on
    li SPRITE_PLAYER_DATA+16    ; Sprite to display
:title_update
    mov r22, r0
    jpl draw_sprite

    li VCORE_OFFSET
    lw r4, r0
    mov r4, r4, N
    bfs N, title_start_check    ; If it's the same frame, don't update player position
    srl r4, r4, 7               ; Remove line number
    li 0x01
    and r31, r4, r0, Z
    bfc Z, title_start_check    ; If it's the same frame, don't update player position
    jpl title_loop              ; Frame % 2 = 0, update player position


:title_start_check
    li INPUT_OFFSET             ; When user presses "FIRE" button, move to ACTIVE gameplay
    lw r4, r0                   ; Get player inputs
    li BTN_FIRE
    and r4, r4, r0, Z
    bfc Z, title_draw_player    ; Loop until "FIRE" has been pressed


    ; Active Gameplay loop
:active_loop
    
    ; Redraw background (so we don't have "painting")
    li 0                        ; Base of video memory (first buffer)
    mov r20, r0
    li BACKGROUND_GAMEPLAY
    mov r21, r0
    jpl draw_background


    jpl active_loop

:spin
    jpl spin                    ; Spin



; ------------------------------------------------------------------
;             HELPER FUNCTIONS
; ------------------------------------------------------------------

; Copy a full screen of data from one location to another
; Args: (destructive)
;   r20 - To base address
;   r21 - From base address
; Uses:
;   r0, r10, r11
:draw_background
    mov r11, r20            ; Save TO address
    li SCREEN_WORDS         ; Start copying from end of data
    ffl x
    add r20, r20, r0
    ffl x
    add r21, r21, r0
    mov r21, r21
    li 1
    ; This NOP is necessary (strangely)
    ; It appears that once the ZMIPS CPU is synthesized,
    ; if an instruction uses rt=0 exactly 3 cycles after
    ; LI then zero is read instead of the immediate value.
    ; This is not the case in the simulated CPU - it works 
    ; fine without the NOP there
    nop                     
:background_loop
    lw r10, r21             ; Get word from data memory
    ffl c
    sub r21, r21, r0
    sw r20, r10             ; Store the word
    ffl c
    sub r20, r20, r0
    cmp r20, r11, N         ; Past base address?
    bfc N, background_loop  ; No, keep going
    jmp r30                 ; Yes, Return


; Draw a 8x8 pixel sprite to a position on screen
; Args: (destructive)
;   r20 - X posiiton
;   r21 - Y position
;   r22 - Base address of sprite data (pointer)
; Uses:
;   r0, r10, r11, r12, r13, r14, r15, r16, r17, r20, r21, r22
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

    li LINE_WIDTH       ; If sprite wraps, correct for line offset
    and r13, r21, r0
    and r14, r20, r0
    eor r31, r13, r14, Z
    bfs Z, sprite_store_high
    ffl c
    sub r21, r21, r0
:sprite_store_high
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
    