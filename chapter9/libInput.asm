!source "gameMemory.asm"

;===============================================================================
; Constants

 ; use joystick 2, change to CIAPRB for joystick 1
JoystickRegister        = CIAPRA

GameportUpMask          = %00000001
GameportDownMask        = %00000010
GameportLeftMask        = %00000100
GameportRightMask       = %00001000
GameportFireMask        = %00010000
FireDelayMax            = 30

;===============================================================================
; Variables

!macro LIBINPUT_VARIABLES {
    gameportLastFrame       !byte 0
    gameportThisFrame       !byte 0
    gameportDiff            !byte 0
    fireDelay               !byte 0
    fireBlip                !byte 1 ; reversed logic to match other input
}

;===============================================================================
; Macros/Subroutines

!macro  LIBINPUT_GETHELD .buttonMask {

        lda gameportThisFrame
        and #.buttonMask
}  ; test with bne on return

;===============================================================================

!macro LIBINPUT_GETFIREPRESSED {
     
        lda #1
        sta fireBlip ; clear Fire flag

        ; is fire held?
        lda gameportThisFrame
        and #GameportFireMask
        bne .notheld

.held
        ; is this 1st frame?
        lda gameportDiff
        and #GameportFireMask
        
        beq .notfirst
        lda #0
        sta fireBlip ; Fire

        ; reset delay
        lda #FireDelayMax
        sta fireDelay        
.notfirst

        ; is the delay zero?
        lda fireDelay
        bne .notheld
        lda #0
        sta fireBlip ; Fire
        ; reset delay
        lda #FireDelayMax
        sta fireDelay   
        
.notheld 
        lda fireBlip
}  ; test with bne on return

;===============================================================================

!macro LIBINPUT_SUBROUTINES { 

libInputUpdate

        lda JoystickRegister
        sta gameportThisFrame

        eor gameportLastFrame
        sta gameportDiff

        
        lda fireDelay
        beq lIUDelayZero
        dec fireDelay
lIUDelayZero

        lda gameportThisFrame
        sta gameportLastFrame

        rts
}

