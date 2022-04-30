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
; ~~Enemy spawning
; ~~RNG
; ~~Firing of missiles (potatos)
; ~~Collision detection (missile/enemy)
; ~~Fast sprite draw (no fractional-word addressing)
; ~~Player motion
; ~~Death screen
; ~~Player getting hit detection (and life dec)

; OPTIONAL TODO:
; ~~Remake title screen
; Player explosions
; ~~Enemy explosions
; ~~Player "thruster" animation
; ~~Animate enemy

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

=BACKGROUND_TITLE               GAME_DATA_BASE + 0
=BACKGROUND_GAMEPLAY            GAME_DATA_BASE + SCREEN_WORDS

=SPRITE_NUM0_DATA               GAME_DATA_BASE + (2 * SCREEN_WORDS)
=SPRITE_NUM0_MASK               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (1  * SPRITE_MASK_OFFSET)
=SPRITE_NUM1_DATA               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (2  * SPRITE_MASK_OFFSET)
=SPRITE_NUM1_MASK               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (3  * SPRITE_MASK_OFFSET)
=SPRITE_NUM2_DATA               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (4  * SPRITE_MASK_OFFSET)
=SPRITE_NUM2_MASK               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (5  * SPRITE_MASK_OFFSET)
=SPRITE_NUM3_DATA               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (6  * SPRITE_MASK_OFFSET)
=SPRITE_NUM3_MASK               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (7  * SPRITE_MASK_OFFSET)
=SPRITE_NUM4_DATA               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (8  * SPRITE_MASK_OFFSET)
=SPRITE_NUM4_MASK               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (9  * SPRITE_MASK_OFFSET)
=SPRITE_NUM5_DATA               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (10 * SPRITE_MASK_OFFSET)
=SPRITE_NUM5_MASK               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (11 * SPRITE_MASK_OFFSET)
=SPRITE_NUM6_DATA               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (12 * SPRITE_MASK_OFFSET)
=SPRITE_NUM6_MASK               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (13 * SPRITE_MASK_OFFSET)
=SPRITE_NUM7_DATA               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (14 * SPRITE_MASK_OFFSET)
=SPRITE_NUM7_MASK               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (15 * SPRITE_MASK_OFFSET)
=SPRITE_NUM8_DATA               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (16 * SPRITE_MASK_OFFSET)
=SPRITE_NUM8_MASK               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (17 * SPRITE_MASK_OFFSET)
=SPRITE_NUM9_DATA               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (18 * SPRITE_MASK_OFFSET)
=SPRITE_NUM9_MASK               GAME_DATA_BASE + (2 * SCREEN_WORDS) + (19 * SPRITE_MASK_OFFSET)

=SPRITE_ENEMY_DATA              GAME_DATA_BASE + (2 * SCREEN_WORDS) + (20 * SPRITE_MASK_OFFSET)
=SPRITE_ENEMY_MASK              GAME_DATA_BASE + (2 * SCREEN_WORDS) + (21 * SPRITE_MASK_OFFSET)
;SPRITE_ENEMY2_DATA             GAME_DATA_BASE + (2 * SCREEN_WORDS) + (22 * SPRITE_MASK_OFFSET)
;SPRITE_ENEMY2_MASK             GAME_DATA_BASE + (2 * SCREEN_WORDS) + (23 * SPRITE_MASK_OFFSET)

=SPRITE_MISSILE_DATA            GAME_DATA_BASE + (2 * SCREEN_WORDS) + (24 * SPRITE_MASK_OFFSET)
=SPRITE_MISSILE_MASK            GAME_DATA_BASE + (2 * SCREEN_WORDS) + (25 * SPRITE_MASK_OFFSET)

=SPRITE_PLAYER_DATA             GAME_DATA_BASE + (2 * SCREEN_WORDS) + (26 * SPRITE_MASK_OFFSET)
=SPRITE_PLAYER_MASK             GAME_DATA_BASE + (2 * SCREEN_WORDS) + (27 * SPRITE_MASK_OFFSET)
;SPRITE_PLAYER2_DATA            GAME_DATA_BASE + (2 * SCREEN_WORDS) + (28 * SPRITE_MASK_OFFSET)
;SPRITE_PLAYER2_MASK            GAME_DATA_BASE + (2 * SCREEN_WORDS) + (29 * SPRITE_MASK_OFFSET)

=SPRITE_PLAYER_THRUST_DATA      GAME_DATA_BASE + (2 * SCREEN_WORDS) + (30 * SPRITE_MASK_OFFSET)
=SPRITE_PLAYER_THRUST_MASK      GAME_DATA_BASE + (2 * SCREEN_WORDS) + (31 * SPRITE_MASK_OFFSET)
;SPRITE_PLAYER_THRUST2_DATA     GAME_DATA_BASE + (2 * SCREEN_WORDS) + (32 * SPRITE_MASK_OFFSET)
;SPRITE_PLAYER_THRUST2_MASK     GAME_DATA_BASE + (2 * SCREEN_WORDS) + (33 * SPRITE_MASK_OFFSET)
;SPRITE_PLAYER_THRUST3_DATA     GAME_DATA_BASE + (2 * SCREEN_WORDS) + (34 * SPRITE_MASK_OFFSET)
;SPRITE_PLAYER_THRUST3_MASK     GAME_DATA_BASE + (2 * SCREEN_WORDS) + (35 * SPRITE_MASK_OFFSET)
;SPRITE_PLAYER_THRUST4_DATA     GAME_DATA_BASE + (2 * SCREEN_WORDS) + (36 * SPRITE_MASK_OFFSET)
;SPRITE_PLAYER_THRUST4_MASK     GAME_DATA_BASE + (2 * SCREEN_WORDS) + (37 * SPRITE_MASK_OFFSET)

=SPRITE_DEAD0_DATA              GAME_DATA_BASE + (2 * SCREEN_WORDS) + (38 * SPRITE_MASK_OFFSET)
=SPRITE_DEAD0_MASK              GAME_DATA_BASE + (2 * SCREEN_WORDS) + (39 * SPRITE_MASK_OFFSET)
=SPRITE_DEAD1_DATA              GAME_DATA_BASE + (2 * SCREEN_WORDS) + (40 * SPRITE_MASK_OFFSET)
=SPRITE_DEAD1_MASK              GAME_DATA_BASE + (2 * SCREEN_WORDS) + (41 * SPRITE_MASK_OFFSET)
=SPRITE_DEAD2_DATA              GAME_DATA_BASE + (2 * SCREEN_WORDS) + (42 * SPRITE_MASK_OFFSET)
=SPRITE_DEAD2_MASK              GAME_DATA_BASE + (2 * SCREEN_WORDS) + (43 * SPRITE_MASK_OFFSET)
=SPRITE_DEAD3_DATA              GAME_DATA_BASE + (2 * SCREEN_WORDS) + (44 * SPRITE_MASK_OFFSET)
=SPRITE_DEAD3_MASK              GAME_DATA_BASE + (2 * SCREEN_WORDS) + (45 * SPRITE_MASK_OFFSET)
=SPRITE_DEAD4_DATA              GAME_DATA_BASE + (2 * SCREEN_WORDS) + (46 * SPRITE_MASK_OFFSET)
=SPRITE_DEAD4_MASK              GAME_DATA_BASE + (2 * SCREEN_WORDS) + (47 * SPRITE_MASK_OFFSET)

=SPRITE_EXPLOSION1_DATA         GAME_DATA_BASE + (2 * SCREEN_WORDS) + (48 * SPRITE_MASK_OFFSET)
=SPRITE_EXPLOSION1_MASK         GAME_DATA_BASE + (2 * SCREEN_WORDS) + (49 * SPRITE_MASK_OFFSET)
;SPRITE_EXPLOSION2_DATA         GAME_DATA_BASE + (2 * SCREEN_WORDS) + (50 * SPRITE_MASK_OFFSET)
;SPRITE_EXPLOSION2_MASK         GAME_DATA_BASE + (2 * SCREEN_WORDS) + (51 * SPRITE_MASK_OFFSET)
;SPRITE_EXPLOSION3_DATA         GAME_DATA_BASE + (2 * SCREEN_WORDS) + (52 * SPRITE_MASK_OFFSET)
;SPRITE_EXPLOSION3_MASK         GAME_DATA_BASE + (2 * SCREEN_WORDS) + (53 * SPRITE_MASK_OFFSET)
;SPRITE_EXPLOSION4_DATA         GAME_DATA_BASE + (2 * SCREEN_WORDS) + (54 * SPRITE_MASK_OFFSET)
;SPRITE_EXPLOSION4_MASK         GAME_DATA_BASE + (2 * SCREEN_WORDS) + (55 * SPRITE_MASK_OFFSET)

; Controls
=BTN_DOWN               1
=BTN_UP                 2
=BTN_FIRE               4
=BTN_FIRE_PULSE         8

; Game constants
=DEFAULT_LIVES          3           ; Extra lives (so there's DEFAULT_LIVES + 1 total)
=PLAYER_MIN_Y           24
=PLAYER_MAX_Y           118
=ENEMY_MIN_Y            24
=ENEMY_MAX_Y            118
=MAX_ENEMIES            4
=TOLERANCE_PEX          5           ; Tolerance for player-enemy collision checking (x-axis)
=TOLERANCE_PEY          6           ; Tolerance for player-enemy collision checking (y-axis)
=TOLERANCE_MEX          5           ; Tolerance for missile-enemy collision checking (x-axis)
=TOLERANCE_MEY          6           ; Tolerance for missile-enemy collision checking (y-axis)
=POINTS_HIT             0x100       ; In BCD
=MAX_EXPLOSIONS         4           ; Number of explosions to allocate memory for
=EXPLOSION_FRAMES       16          ; Number of frames an explosion will take
=EXPLOSION_FRAMES_MASK  0x3

; Screen positions
=SPX_LIVES              8           ; LIVES display location (top left)
=SPY_LIVES              8
=SPX_SCORE              0xb8        ; SCORE display location (top right)
=SPY_SCORE              8   
=SPX_PLAYER             16          ; PLAYER initial position (mid left)
=SPY_PLAYER             0x40
=SPX_PLAYERTHRUST       8           ; PLAYER THRUST initial position
=SPX_MISSILE            16          ; MISSILE intitial position
=SPX_ENEMY              0xf8        ; ENEMY initial position
=SPX_DEAD               0x6e        ; DEAD text x start location
=SPY_DEAD               0x3c        ; DEAD top Y

; Game variables
=VAR_LIVES              RAM_BASE + 0
=VAR_SCORE              RAM_BASE + 1
=VAR_RNG_SEED           RAM_BASE + 2
=VAR_PLAYER_Y           RAM_BASE + 3
                                        ; If X is negative, (bit 31 set) then missile slot not in use
                                        ; If X is positive, then missile slot represents y position of missile 
=VAR_MISSILES           RAM_BASE + 4    ; X1 -> Size = 2 per missile (x, y)
;VAR_MISSILES           RAM_BASE + 5    ; Y1
;VAR_MISSILES           RAM_BASE + 6    ; X2
;VAR_MISSILES           RAM_BASE + 7    ; Y2

                                        ; Base of explosion sprite array
                                        ; Like the missiles, if an X value is negative, then that explosion is not currently running
=VAR_EXPLOSION          RAM_BASE + 80    ; X1
;VAR_EXPLOSION          RAM_BASE + 9    ; Y1
;VAR_EXPLOSION          RAM_BASE + 10   ; Frame1
;VAR_EXPLOSION          RAM_BASE + 11   ; sprite pointer

=VAR_ENEMY_FRAME        VAR_EXPLOSION + 4 * MAX_EXPLOSIONS
=VAR_ENEMY_COUNT        VAR_ENEMY_FRAME + 1   ; Total enemies active on the screen
=VAR_ENEMY              VAR_ENEMY_COUNT + 1   ; X1
;VAR_ENEMY              VAR_ENEMY_COUNT + 2   ; Y1
;VAR_ENEMY              VAR_ENEMY_COUNT + 3   ; X2
;VAR_ENEMY              VAR_ENEMY_COUNT + 4   ; Y2
;VAR_ENEMY              VAR_ENEMY_COUNT + 5   ; X3
;VAR_ENEMY              VAR_ENEMY_COUNT + 6   ; Y3
;VAR_ENEMY              VAR_ENEMY_COUNT + 7   ; X4
;VAR_ENEMY              VAR_ENEMY_COUNT + 8   ; Y4


; ENTRY POINT
    li RAM_BASE+RAM_SIZE-1      ; Init SP
    mov r29, r0

    li 120                      ; Setup location of spaceship on title screen
    mov r1, r0
    li 0
    mov r2, r0
:title_loop

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
:title_player_off
    li SPRITE_PLAYER_DATA       ; Sprite to display
    jpl title_update
:title_player_on
    li SPRITE_PLAYER_DATA+16    ; Sprite to display
:title_update
    mov r22, r0
    jpl draw_sprite

:title_same_frame_loop
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
    bfs Z, title_same_frame_loop    ; Loop until "FIRE" has been pressed
:title_start_check_release
    li INPUT_OFFSET
    lw r4, r0                   ; Get player inputs
    li BTN_FIRE
    and r4, r4, r0, Z
    bfc Z, title_start_check_release    ; Loop until "FIRE" has been released


:init_active_vars
    li DEFAULT_LIVES            ; Setup lives count
    mov r1, r0
    li VAR_LIVES
    sw r0, r1
    li 0                        ; Reset score
    mov r1, r0
    li VAR_SCORE
    sw r0, r1

    li VAR_EXPLOSION            ; Reset explosion data
    mov r1, r0
    li MAX_EXPLOSIONS-1         ; Setup loop count
    mov r9, r0    
    ffl x
:init_explosions_loop
    sll r8, r9, 2               ; 4 words per explosion entry
    add r3, r1, r8              ; Add explosion array offset to index
    li -1
    add r9, r9, r0, N
    sw r3, r0                   ; Reset explosion data
    li 2
    add r3, r3, r0              
    li 0                        ; Clear animation frame counter
    sw r3, r0
    bfc N, init_explosions_loop

:init_active_vars_nextlife
        ; Entry point for after being hit
    li VCORE_OFFSET             ; Init RNG with current frame and line
    lw r1, r0
    li VAR_RNG_SEED
    sw r0, r1

    li VAR_LIVES                ; Only reset board if player is alive
    lw r1, r0                   ; (Let them see the screen when they die)
    mov r1, r1, N
    bfs N, active_loop

    li SPY_PLAYER               ; Setup player position
    mov r1, r0
    li VAR_PLAYER_Y
    sw r0, r1
    li -1                       ; Reset missile slots to be not active
    mov r1, r0
    li VAR_MISSILES
    sw r0, r1
    li VAR_MISSILES + 2
    sw r0, r1
    li 0                        ; No enemies initially
    mov r1, r0
    li VAR_ENEMY_COUNT
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
    sll r1, r1, 3, NZ           ; Multiply by 8 (width of sprite)
                                ; The loop index is also used as the
                                ; x-pixel location for the sprite
    bfs N, active_draw_score    ; Don't display lives if negative (negative breaks things!)
    bfs Z, active_draw_score    ; Don't display lives if zero extra remaining
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
:active_draw_score
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
:active_ds_loop
    mov r21, r2                 ; Y position of sprite
    mov r20, r9                 ; X position
    and r0, r8, r3, C           ; Mask off first digit (and reset carry)
    sll r0, r0, 4               ; Multiply index by 16 (the amount of data per number sprite)
    add r22, r4, r0             ; Setup pointer to correct number sprite
    jpl draw_sprite_fast        ; Display number
    srl r8, r8, 4               ; Shift to get next digit
    li 8
    ffl c
    sub r9, r9, r0
    cmp r9, r1, C               ; Are there any more digits to display?
    bfs C, active_ds_loop       ; No, keep going

    ; Draw enemies
:active_draw_enemies:
    li VAR_ENEMY_COUNT          ; Get total number of enemies currently active
    lw r9, r0
    mov r9, r9, Z
    bfs Z, active_draw_missiles ; If no enemies to display, don't display them!
    li VAR_ENEMY                ; Get enemy base address and save it for later
    mov r8, r0
    li 1                        ; Save 1 for "math"
    mov r6, r0
    ; Handle Enemy animation
    li VCORE_OFFSET             ; Get the current frame number
    lw r4, r0
    li 0x1000                   ; Bit to determine animation state
    and r31, r4, r0, Z
    bfc Z,active_enemy_s1
:active_enemy_s2
    li SPRITE_ENEMY_DATA        ; Sprite to display
    jpl active_de_pre_loop
:active_enemy_s1
    li SPRITE_ENEMY_DATA+16     ; Sprite to display
:active_de_pre_loop
    mov r7, r0                  ; Save enemy data pointer for later
:active_de_loop
    mov r22, r7                 ; Data pointer
    lw r20, r8                  ; Get X for enemy
    ffl x
    add r8, r8, r6              ; Inc pointer to get Y
    lw r21, r8                  ; Get Y
    jpl draw_sprite
    ffl x
    add r8, r8, r6              ; Inc pointer to get next sprite X

    ffl c
    sub r9, r9, r6, z           ; Dec loop index
    bfc z, active_de_loop

    
    ; Draw Missiles
:active_draw_missiles
    li VAR_MISSILES             ; Check to if first missile is in use
    lw r1, r0
    mov r1, r1, N
    bfs N, active_dm_2          ; If slot not in use, don't display anything
    li SPRITE_MISSILE_DATA      ; Otherwise, put sprite on to screen
    mov r22, r0
    li VAR_MISSILES             ; X
    lw r20, r0
    li VAR_MISSILES + 1         ; Y
    lw r21, r0
    jpl draw_sprite
        ; Fallthrough to check for second missile
:active_dm_2
    li VAR_MISSILES + 2         ; Each slot is two words
    lw r1, r0
    mov r1, r1, N
    bfs N, active_draw_explosions   ; If slot not in use, ignore it
    li SPRITE_MISSILE_DATA      ; Otherwise, put sprite on to screen
    mov r22, r0
    li VAR_MISSILES + 2         ; X
    lw r20, r0
    li VAR_MISSILES + 3         ; Y
    lw r21, r0
    jpl draw_sprite

    ; Draw explosions 
:active_draw_explosions   
    li VAR_EXPLOSION            ; Reset explosion data
    mov r1, r0
    li MAX_EXPLOSIONS-1         ; Setup loop count
    mov r9, r0    
:active_dex_loop
    ffl x
    sll r8, r9, 2               ; 4 words per explosion entry
    add r3, r1, r8              ; Add explosion array offset to index
    lw r0, r3                   ; Get X of explosion slot
    mov r0, r0, N
    bfs N, active_dex_continue  ; Not active, don't draw it
    mov r20, r0                 ; Setup X
    li 1
    add r3, r3, r0
    lw r0, r3
    mov r21, r0                 ; Setup Y
    li 1
    add r3, r3, r0              ; Get a pointer to the frame count
    lw r4, r3                   ; And update the frame
    li -1
    add r4, r4, r0, Z
    sw r3, r4
    bfc Z, active_dex_update_frame
        ; Reset explosion
    li -2
    add r3, r3, r0
    sw r3, r0
    jpl active_dex_continue
:active_dex_update_frame
    sw r3, r4                   ; Save back updated frame number
    li EXPLOSION_FRAMES_MASK
    and r4, r4, r0, Z
    bfc Z, active_dex_draw      ; If frame % 0x8 != 0, don't change animation state
        ; Change animation state
    li 1
    add r3, r3, r0
    lw r2, r3                   ; Get current pointer
    li 2 * SPRITE_MASK_OFFSET
    add r2, r2, r0              ; Inc to next sprite position
    sw r3, r2
    li -1                       ; Un-inc the pointer for dex_draw
    add r3, r3, r0

:active_dex_draw
    li 1
    add r3, r3, r0
    lw r22, r3                  ; Display the current animation frame of the sprite
    jpl draw_sprite
:active_dex_continue
    li -1
    add r9, r9, r0, N
    bfc N, active_dex_loop      ; More slots left
    
    ; Draw player
:active_draw_player
    li SPX_PLAYER               ; Setup player location
    mov r20, r0
    li VAR_PLAYER_Y
    lw r21, r0
    li SPRITE_PLAYER_DATA
    ; Handle player animation
    li VCORE_OFFSET             ; Get the current frame number
    lw r4, r0
    li 0x800                    ; Bit to determine spaceship animation state
    and r31, r4, r0, Z
    bfc Z,active_player_on
:active_player_off
    li SPRITE_PLAYER_DATA       ; Sprite to display
    jpl active_update
:active_player_on
    li SPRITE_PLAYER_DATA+16    ; Sprite to display
:active_update
    mov r22, r0
    jpl draw_sprite_fast        ; Can use FAST mode since the x-coord is a multiple of 8

    li 0x600                    ; Bits for animation state
    and r4, r4, r0, c           ; Clear C for later addition
    srl r4, r4, 5               ; Divide to get 16 * [0..3]
    li SPRITE_PLAYER_THRUST_DATA
    add r22, r4, r0
    li SPX_PLAYERTHRUST         ; Setup player thrust location
    mov r20, r0
    li VAR_PLAYER_Y
    lw r21, r0
    jpl draw_sprite_fast        ; And display it


    ; Check for player death
    li VAR_LIVES
    lw r1, r0
    mov r1, r1, N
    bfs N, dead_screen          ; Zero is still alive, negative is dead

:active_frame_wait
    jpl rng
    li VCORE_OFFSET
    lw r4, r0
    mov r4, r4, N
    bfs N, active_frame_wait    ; If it's the same frame, don't update player position

    ; Only do screen updates once every 2 frames
    ; Sets update rate (commented since this is unneeded)
    ; srl r4, r4, 7               ; Remove line number
    ; li 0x01                     ; frame % 2
    ; and r31, r4, r0, Z
    ; bfc Z, active_frame_wait    ; frame % 2 != 0 -> wait

    li VAR_ENEMY_FRAME          ; Update enemy frame counter for determining when to spawn another enemy
    lw r1, r0
    li 1
    ffl x
    add r1, r1, r0
    li VAR_ENEMY_FRAME
    sw r0, r1                   
    li 0x3f                     ; Update score (by 5 points) for staying alive for about second
    and r1, r1, r0, z
    bfc z, active_update_enemies
    li 5                        ; Add 5 points
    mov r20, r0
    jpl update_score
    
    ; Update enemy positions
    ; If enemy gets past player, subtract points (5)
    ; Keep a count of the number of enemies active, start out with 0 and go up until MAX_ENEMIES
:active_update_enemies
    li VAR_ENEMY_COUNT          ; Get total number of enemies currently active
    lw r9, r0
    li MAX_ENEMIES
    cmp r9, r0, C               ; Are all the possible enemies on the screen?
    bfs c, active_ue_move       ; Yes, move them
    li VAR_ENEMY_FRAME          ; No, is it time to spawn another?
    lw r1, r0
    li 0x3f
    and r1, r1, r0, Z
    bfc Z, active_ue_move       ; No, just update positions
                                ; Yes, spawn another

    li -1                       ; Used to check if the rng was entered via adding
    mov r4, r0                  ; another enemy or regenerating an existing one

:active_ue_rng_loop
    jpl rng                     ; Get a random Y position
    li 0x7f
    and r20, r20, r0            ; mask off to keep within reasonable range (screen height)
    li ENEMY_MIN_Y
    cmp r20, r0, c              ; Is the random value out of range?
    bfc c, active_ue_rng_loop   ; Yes, regenerate the number
    li ENEMY_MAX_Y
    cmp r20, r0, c              ; Is the random value out of range?
    bfs c, active_ue_rng_loop   ; Yes, regenerate the number

    sll r8, r9, 1               ; Multiply the enemy count by 2
    li VAR_ENEMY                ; Add to base address of enemy array
    ffl x
    add r8, r8, r0

    li SPX_ENEMY                ; Setup X start position
    sw r8, r0
    li 1
    ffl x
    add r8, r8, r0
    sw r8, r20                  ; Save random Y position

    mov r4, r4, N
    bfc N, active_ue_loop       ; If entered from ue_move, don't change enemy count

    li 1                        ; Increment the total enemies count
    ffl x
    add r9, r9, r0
    li VAR_ENEMY_COUNT          ; And save the updated count
    sw r0, r9

    li 0                        ; Indicate that enemy rng call will be from move update, not spawning
    mov r4, r0

:active_ue_move
    mov r6, r9, Z               ; If no enemies to display, don't update them!
    bfs Z, active_update_missiles
    li 0                        ; Setup index for rng callback
    mov r9, r0
    li VAR_ENEMY                ; Get enemy array base address and save it for later
    mov r7, r0
:active_ue_loop
    lw r1, r7                   ; Get X for enemy
    li 1
    ffl c
    sub r1, r1, r0, Z           ; Enemy moving toward player
    bfc Z, active_ue_next       ; If not a edge of screen, update next
        ; If end of screen, subtract a few points and respawn
    ; li 0x9999                   ; 10's complement of 10 has to be loaded in two separate operations
    ; sll r1, r0, 16
    ; li 0x9980
    ; or r20, r1, r0
    ; jpl update_score            ; Subtract 10 points from the score
    jpl active_ue_rng_loop      ; Respawn the enemy if it's at the edge of the screen

:active_ue_next
    nop                         ; The 3-cycle reg issue strikes again!
    sw r7, r1
    
    li SPX_PLAYER               ; Compare enemy with player X value
    sub r2, r1, r0, N
    bfc N, active_ue_player_check
    li 0                        ; If negative, invert sign
    ffl c
    sub r2, r0, r2
:active_ue_player_check
    li TOLERANCE_PEX
    cmp r0, r2, c               ; If the enemy is close in X to player, check for Y collisions
    bfc c, active_ue_update_continue

    li 1                        ; Inc pointer to get Y value
    ffl x
    add r1, r7, r0
    lw r2, r1                   ; Get the Y value
    li VAR_PLAYER_Y             ; Get player Y value
    lw r1, r0
    ffl c                       ; Difference between values
    sub r2, r2, r1, N
    bfc N, active_ue_player_collision
    li 0                        ; If negative, invert sign
    ffl c
    sub r2, r0, r2
:active_ue_player_collision
    li TOLERANCE_PEY
    cmp r0, r2, c
    bfs c, active_player_hit    ; If within size, player is hit

        ; Otherwise, keep updating enemy positions
:active_ue_update_continue
    li 2                        ; Inc pointer to get next enemy's X value
    ffl x
    add r7, r7, r0

    li 1                        ; Update RNG callback index
    ffl x
    add r9, r9, r0
    ffl c
    sub r6, r6, r0, Z           ; Dec loop index
    bfc z, active_ue_loop


    ; Update missiles positions and check for collisions
:active_update_missiles
    li VAR_MISSILES             ; Check to if first missile is in use
    lw r2, r0
    mov r2, r2, N
    bfs N, active_um_2          ; If slot not in use, don't update it
    li 2                        ; Otherwise, move it 2 pixels to the right
    ffl x
    add r2, r2, r0
    li VAR_MISSILES             ; Save back result
    sw r0, r2
    li LINE_WIDTH*8-8           ; Has the missile gone past the end of the frame?
    cmp r2, r0, C           
    bfs C, active_um_1_reset    ; Yes, reset missile slot
        ; No - check for collisions
    li VAR_MISSILES
    mov r20, r0
    jpl collision_check_me
    jpl active_um_2

:active_um_1_reset
    li -1                       ; Reset missile slot to be not active
    mov r1, r0
    li VAR_MISSILES
    sw r0, r1
        ; Fallthrough to update and check second missile
:active_um_2
    li VAR_MISSILES + 2         ; Each slot is two words
    lw r1, r0
    mov r1, r1, N
    bfs N, active_input_check   ; If slot not in use, ignore it
    li 2
    ffl x
    add r1, r1, r0
    li VAR_MISSILES + 2         ; Save back result
    sw r0, r1
    li LINE_WIDTH*8-8           ; Has the missile gone past the end of the frame?
    cmp r1, r0, C           
    bfs C, active_um_2_reset   ; Yes, reset missile slot
        ; No, check for collisions
    li VAR_MISSILES + 2
    mov r20, r0
    jpl collision_check_me
    jpl active_input_check
    
:active_um_2_reset
    li -1                       ; Reset missile slot to be not active
    mov r1, r0
    li VAR_MISSILES + 2
    sw r0, r1

    ; Move the player if a button is pressed
:active_input_check
    li INPUT_OFFSET
    lw r4, r0
    li BTN_UP                   ; Move Up?
    and r31, r4, r0, Z          
    bfc Z, active_move_up
    li BTN_DOWN                 ; Move Down?
    and r31, r4, r0, Z          
    bfc Z, active_move_down
    li BTN_FIRE_PULSE           ; Fire?
    and r31, r4, r0, Z          
    bfc Z, active_player_fire

    ; No action from player, update screen
    jpl active_loop

:active_move_up
    li VAR_PLAYER_Y             ; Get current player position
    lw r1, r0
    li PLAYER_MIN_Y             ; Bound movement
    cmp r1, r0, C
    bfc C, active_move_check_fire   ; Don't move player
        ; Yes, move player
    li -1                       ; Negative Y is up
    jpl active_move
:active_move_down
    li VAR_PLAYER_Y             ; Get current player position
    lw r1, r0
    li PLAYER_MAX_Y             ; Bound movement
    cmp r0, r1, C
    bfc C, active_move_check_fire   ; Don't move player
        ; Yes, move player
    li 1                        ; Down is positive Y
:active_move
    ffl x
    add r1, r1, r0              ; Add direction to position
    li VAR_PLAYER_Y
    sw r0, r1                   ; Save result
        ; Fallthrough
:active_move_check_fire
    li BTN_FIRE_PULSE           ; Fire? (Check again in case the player is moving and firing)
    and r31, r4, r0, Z          
    bfc Z, active_player_fire
    jpl active_loop

:active_player_fire
    li VAR_MISSILES             ; Check to if both missiles are in use
    lw r1, r0
    mov r1, r1, N
    bfs N, active_missile       ; If slot not in use, use it
    li VAR_MISSILES + 2         ; Each slot is two words
    lw r1, r0
    mov r1, r1, N
    bfs N, active_missile       ; If slot not in use, use it

    ; Also add some more "entropy" to the RNG
    li VAR_RNG_SEED
    lw r1, r0
    li 13
    add r1, r1, r0
    li VAR_RNG_SEED
    sw r0, r1

    jpl active_loop             ; No slot found, don't fire

    ; r0 contains the address of the missile to use
:active_missile
    mov r9, r0                  ; Save missile pointer
    li SPX_PLAYER               ; Set missile to player X
    sw r9, r0
    li VAR_PLAYER_Y             ; And to the player Y
    lw r1, r0
    li 1                        ; Inc pointer to access Y value
    ffl x
    add r9, r9, r0
    sw r9, r1       
    jpl active_loop


    ; When player is hit, update stuff
:active_player_hit
    li VAR_LIVES                ; Get the lives count
    lw r1, r0
    li 1                        ; Subtract 1
    ffl c
    sub r1, r1, r0              ; Death detection is after screen update code
    li VAR_LIVES                ; Save new life total
    sw r0, r1
    
    jpl init_active_vars_nextlife   ; Start the next round


:dead_screen
    ; Draw the "DEAD!" message to the screen
    li SPX_DEAD                 ; Get base location for text
    mov r8, r0
    li (5-1)*8                  ; 5 sprites wide, 8 pixels each
    ffl x
    add r9, r8, r0              ; Setup X location
    li SPY_DEAD
    mov r7, r0
    li SPRITE_DEAD4_DATA       ; Get data pointer
    mov r6, r0
:dead_splash_loop
    mov r22, r6
    mov r21, r7
    mov r20, r9
    jpl draw_sprite
    ffl c
    li 16
    sub r6, r6, r0              ; Move pointer
    li 8
    sub r9, r9, r0              ; Next character
    cmp r9, r8, C               ; Are we done?
    bfs C, dead_splash_loop     ; No, keep going

    li 0x800000
    mov r1, r0
:dead_delay
    li 1
    ffl c
    sub r1, r1, r0, Z
    bfc Z, dead_delay

:dead_screen_loop
    li INPUT_OFFSET
    lw r4, r0
    li BTN_FIRE_PULSE           ; Fire?
    and r31, r4, r0, Z          
    bfs Z, dead_screen_loop     ; No, keep checking
        ; Yes, restart game
    jpl init_active_vars


:spin
    jpl spin                    ; Spin



; ------------------------------------------------------------------
;             HELPER FUNCTIONS
; ------------------------------------------------------------------

; Check for collisions between a missile and an enemy
; Args:
;   r20 - Missile X address
; Regs:
;   r0, r10..r19
; Return:
;   Will modify state vars for the specified missile if a collision is detected
;   Also will modify state vars for enemy array if collision is detected
;   NONE
; Details:
;   * loop over enemies
;   * compare x and y values
;   * if collision detected, shift all enemies down one slot and dec enemy count and free missile
:collision_check_me
    sw r29, r30                 ; Save return address
    li -1
    ffl x
    add r29, r29, r0

    li VAR_ENEMY_COUNT          ; Get enemy count
    lw r19, r0
    mov r19, r19, Z
    bfs Z, collision_me_done    ; If no enemies on screen, don't check for collisions
    li 1                        ; Correct for zero-indexed array
    ffl c
    sub r19, r19, r0
    sll r19, r19, 1             ; Multiply enemy count by 2 for indexing into enemy array
    li VAR_ENEMY
    mov r18, r0                 ; Save enemy array base address for done checking
    ffl x
    add r19, r19, r18           ; Add index to the base of the array
:collision_me_loop
    lw r11, r19                 ; Get enemy X value
    nop                         ; 3 cycle bug
    lw r12, r20                 ; Get missile X value
    sub r11, r12, r11, N        ; Get X distance between enemy and missile
    bfc N, collision_me_cl_xpos ; Correct sign if negative
    li 0
    ffl c
    sub r11, r0, r11
:collision_me_cl_xpos
    li TOLERANCE_MEX            ; Check tolerance
    cmp r0, r11, c
    bfc c, collision_me_continue ; Out of tolerance, check next
        ; In tolerance, check Y positions

    li 1                        ; Get missile Y value
    ffl x
    add r10, r20, r0
    lw r12, r10
    li 1                        ; Inc pointer to Y value of enemy
    ffl x
    add r13, r19, r0
    lw r11, r13                 ; Get enemy Y
    sub r11, r12, r11, N        ; Get Y distance between enemy and missile
    bfc N, collision_me_cl_ypos ; Correct sign if negative
    li 0
    ffl c
    sub r11, r0, r11
:collision_me_cl_ypos
    li TOLERANCE_MEY            ; Check tolerance
    cmp r0, r11, c
    bfc c, collision_me_continue ; Not out of tolerance, keep checking
        ; Out of tolerance, handle check

    li POINTS_HIT               ; Update score
    mov r14, r20                ; But save Missile X position first
    mov r20, r0
    jpl update_score
    mov r20, r14                ; And restore X position
    li -1                       ; Free missile slot
    sw r20, r0

    ; Signal explosion to drawing code
    li VAR_EXPLOSION
    mov r1, r0
    li -1
    mov r2, r0
    li MAX_EXPLOSIONS           ; Setup loop count
    mov r9, r0    
    ffl x
:collsion_explosions_loop
    add r8, r9, r2              ; Accound for zero-indexed array
    sll r8, r8, 2               ; 4 words per explosion entry
    add r3, r1, r8              ; Add explosion array offset to index
    add r9, r9, r2, N
    bfs N, collision_remove_enemy   ; If out of slots, don't keep checking. Just don't display the explosion
    lw r4, r3                   ; Get explosion state (or X value if active)
    mov r4, r4, N
    bfc N, collsion_explosions_loop ; Keep looping until we find an open slot
        ; Found open slot, mark it with the current enemy's X and Y location
        ; r19 has the enemy base address (X address)
    lw r0, r19                  ; Get enemy X
    sw r3, r0                   ; Save to explosion
    ffl x
    li 1
    add r3, r3, r0
    add r13, r19, r0
    lw r0, r13                  ; Enemy Y
    sw r3, r0
    li 1
    add r3, r3, r0
    li EXPLOSION_FRAMES         ; Reset explosion frame counter
    sw r3, r0
    li 1
    add r3, r3, r0
    li SPRITE_EXPLOSION1_DATA   ; Setup sprite pointer
    sw r3, r0

    :collision_remove_enemy
        ; Move all the missliles over in the array (remove current missile)
        li VAR_ENEMY_COUNT          ; Get enemy count
        ffl c
        lw r13, r0                  ; r3 later used for updating active enemy count
        li 1
        sub r15, r13, r0
        sll r15, r15, 1, Z          ; Multiply count to get index into array
        bfs Z, collision_me_update_count ; If only 1 enemy, don't bother updating array
        add r15, r15, r18           ; Add enemy array base to the index 
                                    ; r5 should now be the last X memory location
                                    ; in the array
        mov r17, r19                ; Make copy of enemy array pointer
        li 2
        ffl x   
        add r16, r17, r0            ; Setup "TO" address
        li 1
    :collision_me_remove_enemy_loop
        cmp r17, r15, c             ; Are we done? (at the end of the array)
        bfs c, collision_me_update_count ; Yes, update count
            ; No, keep moving enemies
        lw r11, r16
        add r16, r16, r0
        lw r12, r16
        add r16, r16, r0
        sw r17, r11
        add r17, r17, r0
        sw r17, r12
        add r17, r17, r0            ; Inc pointers
        nop
        jpl collision_me_remove_enemy_loop

    :collision_me_update_count
        li 1                        ; Subtract 1 from enemy count
        ffl c
        sub r13, r13, r0
        li VAR_ENEMY_COUNT          ; And save count
        sw r0, r13

        ; Don't check the other enemies
        jpl collision_me_reset

:collision_me_continue
    li 2                        ; Next enemy
    ffl c
    sub r19, r19, r0
    cmp r19, r18, c             ; Done?
    bfs c, collision_me_loop
    jpl collision_me_done
    
:collision_me_reset
    li -1                       ; Reset missile slot to be not active
    mov r11, r0
    sw r20, r11

:collision_me_done
    li 1                        ; Return
    ffl x
    add r29, r29, r0
    lw r0, r29
    jmp r0
:
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
    add r10, r10, r20, N
    bfc N, update_score_dig0    ; If underflow (or realy good score, reset to 0)
    li 0
    mov r10, r0
    
    ; Go through all the digits and correct for binary-BCD conversion
:update_score_dig0
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
    li 1                ; Calculate high byte address
    ffl x
    add r21, r20, r0
    li LINE_WIDTH       ; If sprite wraps, correct for line offset
    and r11, r21, r0
    and r12, r20, r0
    eor r31, r11, r12, Z
    bfs Z, sprite_wrap_bypass
    ffl c
    sub r21, r21, r0    ; Go up a line if wrapping
:sprite_wrap_bypass
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



; Draw a 8x8 pixel sprite to a position on screen
; Does not account for sub-word positioning, allowing for
; a much faster operation
; Args: (destructive)
;   r20 - X posiiton (multiple of the sprite width)
;   r21 - Y position
;   r22 - Base address of sprite data (pointer)
; Uses:
;   r0, r10, r11, r12, r13, r14
; Return:
;   NONE
:draw_sprite_fast
    sw r29, r30         ; Save return address
    li -1
    ffl x
    add r29, r29, r0
    
    ; Save X
    mov r14, r20

    ; calculate line
    ; y * line_width
    li LINE_WIDTH
    mov r20, r0
    jpl mult            ; Result in r20

    ; Determine line index
    srl r21, r14, 3     ; Divide out pixel number
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
    ; ffl x
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
    