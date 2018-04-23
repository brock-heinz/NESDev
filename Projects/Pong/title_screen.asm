; Pong Title Screen Logic

LoadTitle:

; Turn screen off
;  LDA #$00
;  STA $2000
;  LDA #$00  
;  STA $2001
	
  ; Load Palette
	
  ; Load Background
	
	
  ; Turn screen on
;  LDA #%10011000   ; enable NMI, sprites from Pattern Table 1, background from Pattern Table 1
;  STA $2000
;  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
;  STA $2001

  LDA #STATETITLE 
  STA gamestate
  
  LDA #$03
  STA watch
  
  RTS
  
  
  
TickTitle:

  LDA #100		; Y Pos
  STA $0200
  LDA #$50		; Sprite Index'P'		
  STA $0201  
  LDA #$00		; Attributes
  STA $0202  
  LDA #100		; X Pos
  STA $0203
  
  LDA #100		; Y Pos
  STA $0204
  LDA #$4F		; Sprite Index'O'		
  STA $0205  
  LDA #$00		; Attributes
  STA $0206  
  LDA #108		; X Pos
  STA $0207
  
  LDA #100		; Y Pos
  STA $0208
  LDA #$4E		; Sprite Index'N'		
  STA $0209  
  LDA #$00		; Attributes
  STA $020A  
  LDA #116		; X Pos
  STA $020B
  
  LDA #100		; Y Pos
  STA $020C
  LDA #$47		; Sprite Index'G'		
  STA $020D  
  LDA #$00		; Attributes
  STA $020E  
  LDA #124		; X Pos
  STA $020F
  
  ; If the user has pressed start, transition to gameplay
  LDA buttons1
  AND #BUTTON_START
  BNE SetStateLoadPlaying

  RTS
  
  
SetStateLoadPlaying:
  LDA #STATELOADPLAYING 
  STA gamestate
SetStateLoadPlayingDone:  
  