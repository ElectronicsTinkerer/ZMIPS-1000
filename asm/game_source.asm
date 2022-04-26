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
; ~~Lives Display?
; ~~Draw score function (or code block)
; ~~Update score function
; ~~Move background code to a function (pointers to from and to buffers)
; Enemy spawning
; RNG
; Firing of missiles (potatos)
; Collision detection
; ~~Fast sprite draw (no fractional-word addressing)

; DEFINES
=SCREEN_BASE            0x0000
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

=SPRITE_NUM0_DATA       GAME_DATA_BASE + (2 * SCREEN_WORDS)
=SPRITE_NUM0_MASK       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (1  * SPRITE_MASK_OFFSET)
=SPRITE_NUM1_DATA       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (2  * SPRITE_MASK_OFFSET)
=SPRITE_NUM1_MASK       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (3  * SPRITE_MASK_OFFSET)
=SPRITE_NUM2_DATA       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (4  * SPRITE_MASK_OFFSET)
=SPRITE_NUM2_MASK       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (5  * SPRITE_MASK_OFFSET)
=SPRITE_NUM3_DATA       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (6  * SPRITE_MASK_OFFSET)
=SPRITE_NUM3_MASK       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (7  * SPRITE_MASK_OFFSET)
=SPRITE_NUM4_DATA       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (8  * SPRITE_MASK_OFFSET)
=SPRITE_NUM4_MASK       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (9  * SPRITE_MASK_OFFSET)
=SPRITE_NUM5_DATA       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (10 * SPRITE_MASK_OFFSET)
=SPRITE_NUM5_MASK       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (11 * SPRITE_MASK_OFFSET)
=SPRITE_NUM6_DATA       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (12 * SPRITE_MASK_OFFSET)
=SPRITE_NUM6_MASK       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (13 * SPRITE_MASK_OFFSET)
=SPRITE_NUM7_DATA       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (14 * SPRITE_MASK_OFFSET)
=SPRITE_NUM7_MASK       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (15 * SPRITE_MASK_OFFSET)
=SPRITE_NUM8_DATA       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (16 * SPRITE_MASK_OFFSET)
=SPRITE_NUM8_MASK       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (17 * SPRITE_MASK_OFFSET)
=SPRITE_NUM9_DATA       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (18 * SPRITE_MASK_OFFSET)
=SPRITE_NUM9_MASK       GAME_DATA_BASE + (2 * SCREEN_WORDS) + (19 * SPRITE_MASK_OFFSET)

=SPRITE_ENEMY_DATA      GAME_DATA_BASE + (2 * SCREEN_WORDS) + (20 * SPRITE_MASK_OFFSET)
=SPRITE_ENEMY_MASK      GAME_DATA_BASE + (2 * SCREEN_WORDS) + (21 * SPRITE_MASK_OFFSET)

=SPRITE_PLAYER_DATA     GAME_DATA_BASE + (2 * SCREEN_WORDS) + (22 * SPRITE_MASK_OFFSET)
=SPRITE_PLAYER_MASK     GAME_DATA_BASE + (2 * SCREEN_WORDS) + (23 * SPRITE_MASK_OFFSET)

; Controls
=BTN_DOWN               1
=BTN_UP                 2
=BTN_FIRE               4

; Game variables
=VAR_LIVES              RAM_BASE + 0
=VAR_SCORE              RAM_BASE + 1
=VAR_RNG_SEED           RAM_BASE + 2

; Game constants
=DEFAULT_LIVES          3

; Screen positions
=SPX_LIVES              8           ; LIVES display location (top left)
=SPY_LIVES              8
=SPX_SCORE              0xb8        ; SCORE display location (top right)
=SPY_SCORE              8   


; ENTRY POINT
    li RAM_BASE+RAM_SIZE-1          ; Init SP
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


:init_active_vars
    li DEFAULT_LIVES            ; Setup lives count
    mov r1, r0
    li VAR_LIVES
    sw r0, r1
    li 0                        ; Reset score
    mov r1, r0
    li VAR_SCORE
    sw r0, r1
    li VCORE_OFFSET             ; Init RNG with current frame and line
    lw r1, r0
    li VAR_RNG_SEED
    sw r0, r1

    ; Active Gameplay loop
:active_loop
    
    ; Redraw background (so we don't have "painting")
    li 0                        ; Base of video memory (first buffer)
    mov r20, r0
    li BACKGROUND_GAMEPLAY
    mov r21, r0
    jpl draw_background

    ; Draw the player lives
    li VAR_LIVES                ; Get the total lives
    lw r1, r0
    sll r1, r1, 3               ; Multiply by 8 (width of sprite)
                                ; The loop index is also used as the
                                ; x-pixel location for the sprite
    li SPX_LIVES-8
    ffl x
    add r1, r1, r0              ; Add x offset to loop
    mov r9, r0
:active_draw_lives
    li SPY_LIVES
    mov r21, r0                 ; Setup Y position
    mov r20, r1                 ; Setup X position
    li SPRITE_PLAYER_DATA
    mov r22, r0
    jpl draw_sprite_fast
    li 8                        ; Keep drawing lives until all have been drawn
    ffl c
    sub r1, r1, r0
    cmp r9, r1, C               ; Past start location?
    bfc C, active_draw_lives    ; No, display another


    ; Draw score
    li 8*(8-1)+SPX_SCORE        ; 8 score digits to display (each 8 pixels wide, zero indexed (-1))
    mov r9, r0                  ; Setup loop index
    li SPX_SCORE
    mov r1, r0
    li SPY_SCORE
    mov r2, r0
    li VAR_SCORE                ; Get the current score
    lw r8, r0
    li 0xf
    mov r3, r0
    li SPRITE_NUM0_DATA
    mov r4, r0
:active_draw_score
    and r0, r8, r3              ; Mask off first digit
    sll r0, r0, 4               ; Multiply index by 16 (the amount of data per number sprite)
    add r22, r4, r0             ; Setup pointer to correct number sprite
    mov r21, r2                 ; Y position of sprite
    mov r20, r9                 ; X position
    jpl draw_sprite_fast        ; Display number
    srl r8, r8, 4               ; Shift to get next digit
    li 8
    ffl c
    sub r9, r9, r0
    cmp r9, r1, C               ; Are there any more digits to display?
    bfs C, active_draw_score    ; No, keep going

;     li 64                       ; Setup loop count
;     mov r9, r0
; :active_enemy_update
;     jpl rng ; Random X, Y
;     mov r1, r20
;     li 0
;     sw r0, r1
;     jpl rng
;     li 1
;     sw r0, r20
;     li 0xff
;     and r20, r20, r0    ; Limit x range
;     mov r21, r1
;     li 0x7f ; Limit Y range to on screen
;     and r21, r21, r0
;     li SPRITE_ENEMY_DATA
;     mov r22, r0
;     jpl draw_sprite
;     li 1
;     ffl c
;     sub r9, r9, r0, c           ; Done?
;     bfs c, active_enemy_update  ; No, continue updating enemies

    ; Inc the score when the up button is pressed
    li INPUT_OFFSET
    lw r4, r0
    li BTN_UP
    and r4, r4, r0, Z
    bfc Z, active_loop
    li VCORE_OFFSET
    lw r4, r0
    mov r4, r4, N
    bfs N, active_loop    ; If it's the same frame, don't update player position
    srl r4, r4, 7               ; Remove line number
    li 0x01
    and r31, r4, r0, Z
    bfc Z, active_loop    ; If it's the same frame, don't update player position
    ; li VAR_SCORE
    ; lw r1, r0
    ; li 1
    ; ffl x
    ; add r1, r1, r0
    ; li VAR_SCORE
    ; sw r0, r1
    li 0x10
    mov r20, r0
    jpl update_score
    

    jpl active_loop

:spin
    jpl spin                    ; Spin



; ------------------------------------------------------------------
;             HELPER FUNCTIONS
; ------------------------------------------------------------------


; Add a value to the score
; Args:
;   r20 - Value to be added to the score (in BCD)
; Uses:
;   r0, r10, r11, r12, r13
; Return:
;   NONE
:update_score
    li VAR_SCORE
    lw r10, r0
    ffl x
    add r10, r10, r20
    
    ; Go through all the digits and correct for binary-BCD conversion
    li 0xf
    mov r11, r0
    li 6
    mov r12, r0
    li 10-1
    mov r13, r0
    and r0, r10, r11        ; Mask off current digit
    cmp r13, r0, C          ; Is the digit over 10?
    bfs C, update_score_dig1    ; No, do next digit
    add r10, r10, r12       ; Yes, correct this digit
:update_score_dig1
    sll r11, r11, 4         ; Update digit mask to current digit
    sll r12, r12, 4
    sll r13, r13, 4
    and r0, r11, r10        ; Mask off current digit
    cmp r13, r0, C          ; Is the digit over 10?
    bfs C, update_score_dig2    ; No, do next digit
    add r10, r10, r12       ; Yes, correct this digit
:update_score_dig2
    sll r11, r11, 4         ; Update digit mask to current digit
    sll r12, r12, 4
    sll r13, r13, 4
    and r0, r11, r10        ; Mask off current digit
    cmp r13, r0, C          ; Is the digit over 10?
    bfs C, update_score_dig3    ; No, do next digit
    add r10, r10, r12       ; Yes, correct this digit
:update_score_dig3
    sll r11, r11, 4         ; Update digit mask to current digit
    sll r12, r12, 4
    sll r13, r13, 4
    and r0, r11, r10        ; Mask off current digit
    cmp r13, r0, C          ; Is the digit over 10?
    bfs C, update_score_dig4    ; No, do next digit
    add r10, r10, r12       ; Yes, correct this digit
:update_score_dig4
    sll r11, r11, 4         ; Update digit mask to current digit
    sll r12, r12, 4
    sll r13, r13, 4
    and r0, r11, r10        ; Mask off current digit
    cmp r13, r0, C          ; Is the digit over 10?
    bfs C, update_score_dig5    ; No, do next digit
    add r10, r10, r12       ; Yes, correct this digit
:update_score_dig5
    sll r11, r11, 4         ; Update digit mask to current digit
    sll r12, r12, 4
    sll r13, r13, 4
    and r0, r11, r10        ; Mask off current digit
    cmp r13, r0, C          ; Is the digit over 10?
    bfs C, update_score_dig6    ; No, do next digit
    add r10, r10, r12       ; Yes, correct this digit
:update_score_dig6
    sll r11, r11, 4         ; Update digit mask to current digit
    sll r12, r12, 4
    sll r13, r13, 4
    and r0, r11, r10        ; Mask off current digit
    cmp r13, r0, C          ; Is the digit over 10?
    bfs C, update_score_dig7    ; No, do next digit
    add r10, r10, r12       ; Yes, correct this digit
:update_score_dig7
    sll r11, r11, 4         ; Update digit mask to current digit
    sll r12, r12, 4
    sll r13, r13, 4
    and r0, r11, r10        ; Mask off current digit
    cmp r13, r0, C          ; Is the digit over 10?
    bfs C, update_score_done    ; No, do next digit
    add r10, r10, r12       ; Yes, correct this digit
:update_score_done
    li VAR_SCORE            ; Write back score
    sw r0, r10
    jmp r30                 ; Return

; Return a random number in R20
; Args:
;   NONE
; Uses:
;   r0
; Return:
;   r20 - Containing a random number
:rng
    ffl x
    li VAR_RNG_SEED         ; Get the seed value
    lw r20, r0
    mov r0, r20
    sll r20, r20, 2         ; Multiply it by 4
    add r20, r20, r0        ; And add the original value to effectively multiply by 5
    li 3                    ; Add 3
    ffl x
    add r20, r20, r0
    li VAR_RNG_SEED         ; Save new number for next iteration
    sw r0, r20
    jmp r30                 ; Return


; Copy a full screen of data from one location to another
; Args: (destructive)
;   r20 - To base address
;   r21 - From base address
; Uses:
;   r0, r10, r11
:draw_background
    mov r11, r20            ; Save TO address
    li SCREEN_WORDS         ; Start copying from end of data
    ffl c
    add r20, r20, r0
    ffl x
    add r21, r21, r0
    mov r21, r21
    li 1
    ; This NOP is necessary (strangely)
    ; It appears that once the ZMIPS CPU is synthesized,
    ; if an instruction uses rt exactly 3 cycles after
    ; an instruction that writes to it then the previous 
    ; value is read instead of the last one that was written.
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
    srl r21, r17, 3     ; Divide out pixel number
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



; Draw a 8x8 pixel sprite to a position on screen
; Does not account for sub-word positioning, allowing for
; a much faster operation
; Args: (destructive)
;   r20 - X posiiton (multiple of the sprite width)
;   r21 - Y position
;   r22 - Base address of sprite data (pointer)
; Uses:
;   r0, r10, r11, r12, r13
; Return:
;   NONE
:draw_sprite_fast
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
    srl r21, r17, 3     ; Divide out pixel number
    ffl X               ; Clear C
    add r20, r20, r21

    ; BEGIN LOOP
    li 8                ; Init loop var (8 lines tall)
    mov r10, r0
    
    li 1
    ffl C
    sub r22, r22, r0    ; Start sprite pointer at address minus 1

:sprite_loop_fast
    ; Currently,
    ;    r10 stores the loop count
    ;    r20 stores the base offset of the video data word
    ;    r22 stores the pointer to the sprite data base
    ffl x
    li 1
    add r22, r22, r0    ; Increment sprite data pointer
    lw r12, r22         ; Get the sprite's line of data
    ffl x
    li SPRITE_MASK_OFFSET
    add r0, r22, r0
    lw r13, r0          ; Get the sprite's corresponding line mask
    and r12, r12, r13   ; Apply the mask

    ; Read vmem and get the data present under the current sprite location
    ; Regs:
    ;    r10 - loop index
    ;    r11 - vmem data
    ;    r12 - Sprite data
    ;    r13 - Sprite mask
    ;    r20 - vmem addr
    ;    r22 - Sprite data pointer
    lw r11, r20         ; Get word of vdata
    li 0xffffffff       ; Invert the mask
    eor r13, r13, r0
    and r11, r11, r13   ; And apply it to vmem
    or r11, r11, r12    ; Or the sprite data into vmem
    sw r20, r11

    ; Next byte of data
    ffl x
    li LINE_WIDTH       ; Move vmem pointer to next line
    add r20, r20, r0
    li 1                ; Decrement loop var
    ffl C
    sub r10, r10, r0, Z
    bfc Z,sprite_loop_fast
    
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
    