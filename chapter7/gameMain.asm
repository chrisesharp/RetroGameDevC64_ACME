!to "chapter7.prg", cbm

;===============================================================================
; Imports

!source "gameMemory.asm"
!source "gamePlayer.asm"
!source "libInput.asm"
!source "libScreen.asm"
!source "libSprite.asm"

;===============================================================================
; BASIC Loader

*=$0801 ; 10 SYS (2064)

        !byte $0E, $08, $0A, $00, $9E, $20, $28, $32
        !byte $30, $36, $34, $29, $00, $00, $00

        ; Our code starts at $0810 (2064 decimal)
        ; after the 15 bytes for the BASIC loader

;===============================================================================

; Initialize

        ; Turn off interrupts to stop LIBSCREEN_WAIT failing every so 
        ; often when the kernal interrupt syncs up with the scanline test
        sei

        ; Disable run/stop + restore keys
        lda #$FC 
        sta $0328

        ; Set border and background colors
        ; The last 3 parameters are not used yet
        +LIBSCREEN_SETCOLORS Blue, Black, Black, Black, Black

        ; Fill 1000 bytes (40x25) of screen memory 
        +LIBSCREEN_SET1000 SCREENRAM, SpaceCharacter

        ; Fill 1000 bytes (40x25) of color memory
        +LIBSCREEN_SET1000 COLORRAM, White

        ; Set sprite multicolors
        +LIBSPRITE_SETMULTICOLORS_VV MediumGray, DarkGray
        
        ; Initialize the game
        jsr gamePlayerInit

;===============================================================================
; Update

gMLoop
        ; Wait for scanline 255
        +LIBSCREEN_WAIT_V 255

        ; Start code timer change border color
        ;inc EXTCOL

        ; Update the library
        jsr libInputUpdate

        ; Update the game
        jsr gamePlayerUpdate

        ; End code timer reset border color
        ;dec EXTCOL
        
        ; Loop back to the start of the game loop
        jmp gMLoop

+LIBSPRITE_VARIABLES
+LIBSCREEN_VARIABLES
+LIBINPUT_VARIABLES
+GAMEPLAYER_VARIABLES
+LIBINPUT_UPDATE
+LIBSPRITE_UPDATE
+GAMEPLAYER_INIT
+GAMEPLAYER_UPDATE
+GAMEPLAYER_UPDATE_POS
