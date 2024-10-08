!source "libMath.asm"
;===============================================================================
; Constants

Black           = 0
White           = 1
Red             = 2
Cyan            = 3 
Purple          = 4
Green           = 5
Blue            = 6
Yellow          = 7
Orange          = 8
Brown           = 9
LightRed        = 10
DarkGray        = 11
MediumGray      = 12
LightGreen      = 13
LightBlue       = 14
LightGray       = 15
SpaceCharacter  = 32

False           = 0
True            = 1

;===============================================================================
; Variables

!macro LIBSCREEN_VARIABLES {
    ScreenRAMRowStartLow ;  SCREENRAM + 40*0, 40*1, 40*2 ... 40*24
            !byte <SCREENRAM,     <SCREENRAM+40,  <SCREENRAM+80
            !byte <SCREENRAM+120, <SCREENRAM+160, <SCREENRAM+200
            !byte <SCREENRAM+240, <SCREENRAM+280, <SCREENRAM+320
            !byte <SCREENRAM+360, <SCREENRAM+400, <SCREENRAM+440
            !byte <SCREENRAM+480, <SCREENRAM+520, <SCREENRAM+560
            !byte <SCREENRAM+600, <SCREENRAM+640, <SCREENRAM+680
            !byte <SCREENRAM+720, <SCREENRAM+760, <SCREENRAM+800
            !byte <SCREENRAM+840, <SCREENRAM+880, <SCREENRAM+920
            !byte <SCREENRAM+960

    ScreenRAMRowStartHigh 
            !byte >SCREENRAM,      >SCREENRAM+40,  >SCREENRAM+80
            !byte >SCREENRAM+120, >SCREENRAM+160, >SCREENRAM+200
            !byte >SCREENRAM+240, >SCREENRAM+280, >SCREENRAM+320
            !byte >SCREENRAM+360, >SCREENRAM+400, >SCREENRAM+440
            !byte >SCREENRAM+480, >SCREENRAM+520, >SCREENRAM+560
            !byte >SCREENRAM+600, >SCREENRAM+640, >SCREENRAM+680
            !byte >SCREENRAM+720, >SCREENRAM+760, >SCREENRAM+800
            !byte >SCREENRAM+840, >SCREENRAM+880, >SCREENRAM+920
            !byte >SCREENRAM+960

    ColorRAMRowStartLow ;  COLORRAM + 40*0, 40*1, 40*2 ... 40*24
            !byte <COLORRAM,     <COLORRAM+40,  <COLORRAM+80
            !byte <COLORRAM+120, <COLORRAM+160, <COLORRAM+200
            !byte <COLORRAM+240, <COLORRAM+280, <COLORRAM+320
            !byte <COLORRAM+360, <COLORRAM+400, <COLORRAM+440
            !byte <COLORRAM+480, <COLORRAM+520, <COLORRAM+560
            !byte <COLORRAM+600, <COLORRAM+640, <COLORRAM+680
            !byte <COLORRAM+720, <COLORRAM+760, <COLORRAM+800
            !byte <COLORRAM+840, <COLORRAM+880, <COLORRAM+920
            !byte <COLORRAM+960

    ColorRAMRowStartHigh ;  COLORRAM + 40*0, 40*1, 40*2 ... 40*24
            !byte >COLORRAM,     >COLORRAM+40,  >COLORRAM+80
            !byte >COLORRAM+120, >COLORRAM+160, >COLORRAM+200
            !byte >COLORRAM+240, >COLORRAM+280, >COLORRAM+320
            !byte >COLORRAM+360, >COLORRAM+400, >COLORRAM+440
            !byte >COLORRAM+480, >COLORRAM+520, >COLORRAM+560
            !byte >COLORRAM+600, >COLORRAM+640, >COLORRAM+680
            !byte >COLORRAM+720, >COLORRAM+760, >COLORRAM+800
            !byte >COLORRAM+840, >COLORRAM+880, >COLORRAM+920
            !byte >COLORRAM+960

    screenColumn      !byte 0
    screenScrollXValue !byte 0
}

;===============================================================================
; Macros/Subroutines

!macro LIBSCREEN_DEBUG8BIT_VVA .X, .Y, .P {
                        ; .X = X Position Absolute
                        ; .Y = Y Position Absolute
                        ; .P = 1st Number Low Byte Pointer
        
        lda #White
        sta $0286       ; set text color
        lda #$20        ; space
        jsr $ffd2       ; print 4 spaces
        jsr $ffd2
        jsr $ffd2
        jsr $ffd2
        ;jsr $E566      ; reset cursor
        ldx #.Y         ; Select row 
        ldy #.X         ; Select column 
        jsr $E50C       ; Set cursor 

        lda #0
        ldx ./3
        jsr $BDCD       ; print number
}

;===============================================================================

!macro LIBSCREEN_DEBUG16BIT_VVAA .X, .Y, .HP, .LP {
                        ; .X = X Position Absolute
                        ; .Y = Y Position Absolute
                        ; .HP = 1st Number High Byte Pointer
                        ; .LP = 1st Number Low Byte Pointer
        
        lda #White
        sta $0286       ; set text color
        lda #$20        ; space
        jsr $ffd2       ; print 4 spaces
        jsr $ffd2
        jsr $ffd2
        jsr $ffd2
        ;jsr $E566      ; reset cursor
        ldx #.Y         ; Select row 
        ldy #.X         ; Select column 
        jsr $E50C       ; Set cursor 

        lda .HP
        ldx .LP 
        jsr $BDCD       ; print number
}

;==============================================================================

!macro LIBSCREEN_DRAWTEXT_AAAV .X, .Y, .S, .C  {
                                ; .X = X Position 0-39 (Address)
                                ; .Y = Y Position 0-24 (Address)
                                ; .S = 0 terminated string (Address)
                                ; .C = Text Color (Value)

        ldy .Y ; load y position as index into list
        
        lda ScreenRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ScreenRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy .X ; load x position into Y register

        ldx #0
.loop   lda .S,X
        cmp #0
        beq .done
        sta (ZeroPageLow),Y
        inx
        iny
        jmp .loop
.done


        ldy .Y ; load y position as index into list
        
        lda ColorRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ColorRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy .X ; load x position into Y register

        ldx #0
.loop2  lda .S,X
        cmp #0
        beq .done2
        lda #.C
        sta (ZeroPageLow),Y
        inx
        iny
        jmp .loop2
.done2

}

;===============================================================================

!macro LIBSCREEN_DRAWDECIMAL_AAAV .X, .Y, .D, .C {
                                ; .X = X Position 0-39 (Address)
                                ; .Y = Y Position 0-24 (Address)
                                ; .D = decimal number 2 nybbles (Address)
                                ; .C = Text Color (Value)

        ldy .Y ; load y position as index into list
        
        lda ScreenRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ScreenRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy .X ; load x position into Y register

        ; get high nybble
        lda .D 
        and #$F0
        
        ; convert to ascii
        lsr
        lsr
        lsr
        lsr
        ora #$30

        sta (ZeroPageLow),Y

        ; move along to next screen position
        iny 

        ; get low nybble
        lda .D
        and #$0F

        ; convert to ascii
        ora #$30  

        sta (ZeroPageLow),Y
    

        ; now set the colors
        ldy .Y ; load y position as index into list
        
        lda ColorRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ColorRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy .X ; load x position into Y register

        lda #.C
        sta (ZeroPageLow),Y

        ; move along to next screen position
        iny 
        
        sta (ZeroPageLow),Y
}

;==============================================================================

!macro LIBSCREEN_GETCHAR .R  { ; .R = Return character code (Address)
        lda (ZeroPageLow),Y
        sta .R
}

;===============================================================================

!macro LIBSCREEN_PIXELTOCHAR_AAVAVAAAA .XHighPixels, .XLowPixels, .XAdjust, .YPixels, .YAdjust, .XChar, .XOffset, .YChar, .YOffset {
                                ; XHighPixels      (Address)
                                ; XLowPixels       (Address)
                                ; XAdjust          (Value)
                                ; YPixels          (Address)
                                ; YAdjust          (Value)
                                ; XChar            (Address)
                                ; XOffset          (Address)
                                ; YChar            (Address)
                                ; YOffset          (Address)
                                

        lda .XHighPixels 
        sta ZeroPageParam1
        lda .XLowPixels 
        sta ZeroPageParam2
        lda #.XAdjust
        sta ZeroPageParam3
        lda .YPixels 
        sta ZeroPageParam4
        lda #.YAdjust
        sta ZeroPageParam5
        
        jsr libScreen_PixelToChar

        lda ZeroPageParam6
        sta .XChar 
        lda ZeroPageParam7
        sta .XOffset 
        lda ZeroPageParam8
        sta .YChar 
        lda ZeroPageParam9
        sta .YOffset 

}


;==============================================================================

!macro LIBSCREEN_SCROLLXLEFT_A .SR { ; .SR = update subroutine (Address)

        dec screenScrollXValue
        lda screenScrollXValue
        and #%00000111
        sta screenScrollXValue

        lda SCROLX
        and #%11111000
        ora screenScrollXValue
        sta SCROLX

        lda screenScrollXValue
        cmp #7
        bne .finished

        ; move to next column
        inc screenColumn
        jsr .SR ; call the passed in function to update the screen rows
.finished

}

;==============================================================================

!macro LIBSCREEN_SCROLLXRIGHT_A .SR { ; .SR = update subroutine (Address)

        inc screenScrollXValue
        lda screenScrollXValue
        and #%00000111
        sta screenScrollXValue

        lda SCROLX
        and #%11111000
        ora screenScrollXValue
        sta SCROLX

        lda screenScrollXValue
        cmp #0
        bne .finished

        ; move to previous column
        dec screenColumn
        jsr .SR ; call the passed in function to update the screen rows
.finished

}

;==============================================================================

!macro LIBSCREEN_SCROLLXRESET_A .SR { ; .SR = update subroutine (Address)

        lda #0
        sta screenColumn
        sta screenScrollXValue

        lda SCROLX
        and #%11111000
        ora screenScrollXValue
        sta SCROLX

        jsr .SR ; call the passed in function to update the screen rows

}

;==============================================================================

!macro LIBSCREEN_SETSCROLLXVALUE_A .ScrollX {   ; .ScrollX value (Address)

        lda SCROLX
        and #%11111000
        ora .ScrollX 
        sta SCROLX

}

;==============================================================================

!macro    LIBSCREEN_SETSCROLLXVALUE_V .ScrollX {  ; .ScrollX value (Value)

        lda SCROLX
        and #%11111000
        ora #.ScrollX
        sta SCROLX

}

;==============================================================================

; Sets 1000 bytes of memory from start address with a value
!macro LIBSCREEN_SET1000 .Start, .Num {
                                ; .Start  (Address)
                                ; .Num (Value)

        lda #.Num                 ; Get number to set
        ldx #250                ; Set loop value
.loop   dex                     ; Step -1
        sta .Start,x                ; Set start + x
        sta .Start+250,x            ; Set start + 250 + x
        sta .Start+500,x            ; Set start + 500 + x
        sta .Start+750,x            ; Set start + 750 + x
        bne .loop               ; If x<>0 loop

}

;==============================================================================

!macro  LIBSCREEN_SET38COLUMNMODE {

        lda SCROLX
        and #%11110111 ; clear bit 3
        sta SCROLX

}

;==============================================================================

!macro LIBSCREEN_SET40COLUMNMODE {

        lda SCROLX
        ora #%00001000 ; set bit 3
        sta SCROLX

}

;==============================================================================

!macro  LIBSCREEN_SETCHARMEMORY .CM { ; .CM = Character Memory Slot (Value)
        ; point vic (lower 4 bits of $d018)to new character data
        lda VMCSB
        and #%11110000 ; keep higher 4 bits
        ; p208 M Jong book
        ora #.CM ;$0E ; maps to  $3800 memory address
        sta VMCSB
}

;==============================================================================

!macro  LIBSCREEN_SETCHAR_V .CC { ; .CC = Character Code (Value)
        lda #.CC
        sta (ZeroPageLow),Y
}

;==============================================================================

!macro  LIBSCREEN_SETCHAR_A .CC { ; .CC = Character Code (Address)
        lda .CC 
        sta (ZeroPageLow),Y
}

;==============================================================================

!macro  LIBSCREEN_SETCHARPOSITION_AA .X, .Y {
                                     ; .X = X Position 0-39 (Address)
                                     ; .Y = Y Position 0-24 (Address)
        
        ldy .Y ; load y position as index into list
        
        lda ScreenRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ScreenRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy .X ; load x position into Y register

}

;==============================================================================

!macro  LIBSCREEN_SETCOLORPOSITION_AA .X, .Y {   
                                ; .X = X Position 0-39 (Address)
                                ; .Y = Y Position 0-24 (Address)
                               
        ldy .Y ; load y position as index into list
        
        lda ColorRAMRowStartLow,Y ; load low address byte
        sta ZeroPageLow

        lda ColorRAMRowStartHigh,Y ; load high address byte
        sta ZeroPageHigh

        ldy .X ; load x position into Y register

}

;===============================================================================

; Sets the border and background colors
!macro  LIBSCREEN_SETCOLORS .BORD, .BG0, .BG1, .BG2, .BG3 {  
                                ; .Border = Border Color       (Value)
                                ; .BG0 = Background Color 0 (Value)
                                ; .BG1 = Background Color 1 (Value)
                                ; .BG2 = Background Color 2 (Value)
                                ; .BG3 = Background Color 3 (Value)
                                
        lda #.BORD                 ; Color0 -> A
        sta EXTCOL              ; A -> EXTCOL
        lda #.BG0                 ; Color1 -> A
        sta BGCOL0              ; A -> BGCOL0
        lda #.BG1                 ; Color2 -> A
        sta BGCOL1              ; A -> BGCOL1
        lda #.BG2                 ; Color3 -> A
        sta BGCOL2              ; A -> BGCOL2
        lda #.BG3                 ; Color4 -> A
        sta BGCOL3              ; A -> BGCOL3

}

;==============================================================================

!macro LIBSCREEN_SETMULTICOLORMODE {

        lda SCROLX
        ora #%00010000 ; set bit 5
        sta SCROLX

}

;===============================================================================

; Waits for a given scanline 
!macro  LIBSCREEN_WAIT_V .SC {  ; .SC = Scanline (Value)

.loop   lda #.SC                ; Scanline -> A
        cmp RASTER              ; Compare A to current raster line
        bne .loop               ; Loop if raster line not reached 255

}

!macro LIBSCREEN_SUBROUTINES {
    libScreen_PixelToChar

        ; subtract XAdjust pixels from XPixels as left of a sprite is first visible at x = 24
        +LIBMATH_SUB16BIT_AAVAAA ZeroPageParam1, ZeroPageParam2, 0, ZeroPageParam3, ZeroPageParam6, ZeroPageParam7

        lda ZeroPageParam6
        sta ZeroPageTemp

        ; divide by 8 to get character X
        lda ZeroPageParam7
        lsr  ; divide by 2
        lsr  ; and again = /4
        lsr  ; and again = /8
        sta ZeroPageParam6

        ; AND 7 to get pixel offset X
        lda ZeroPageParam7
        and #7
        sta ZeroPageParam7

        ; Adjust for XHigh
        lda ZeroPageTemp
        beq .nothigh
        +LIBMATH_ADD8BIT_AVA ZeroPageParam6, 32, ZeroPageParam6 ; shift across 32 chars

.nothigh
        ; subtract YAdjust pixels from YPixels as top of a sprite is first visible at y = 50
        +LIBMATH_SUB8BIT_AAA ZeroPageParam4, ZeroPageParam5, ZeroPageParam9


        ; divide by 8 to get character Y
        lda ZeroPageParam9
        lsr  ; divide by 2
        lsr  ; and again = /4
        lsr  ; and again = /8
        sta ZeroPageParam8

        ; AND 7 to get pixel offset Y
        lda ZeroPageParam9
        and #7
        sta ZeroPageParam9

        rts
}
