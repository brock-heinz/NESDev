; Pong Title Screen Logic

LoadTitle:

	; Turn screen off
	LDA #$00
	STA $2000
	LDA #$00  
	STA $2001
	
	; Clear old sprite data
	JSR ClearSprites
	
	; Load Background Tiles
  
	; Load Background Attributes
	
	; Load Palettes
	
	; Turn screen on
	LDA #%10011000   ; enable NMI, sprites from Pattern Table 1, background from Pattern Table 1
	STA $2000
	LDA #%00011110   ; enable sprites, enable background, no clipping on left side
	STA $2001

  LDA #STATETITLE 
  STA gamestate
  
  RTS
  
  
  
TickTitle:

  JSR TitleBallBounce
  
  ; TODO 
  ; Move this to its own sub routine
  ; Have 
  
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
  
	LDA #$10
	STA sprite_offset
  	LDA bally
	STA sprite_ypos
	LDA #$80 ; ball sprite tile index
	STA sprite_tile
	LDA #$00
	STA sprite_attr
	LDA ballx
	STA sprite_xpos
	JSR DrawSprite
	
  
;  LDA bally  ;;update all ball sprite info
;  STA 
;  LDA #$80
;  STA $0211
;  LDA #$00
;  STA $0212
;  LDA ballx
;  STA $0213
  
  ; If the user has pressed start, transition to gameplay
  LDA buttons1
  AND #BUTTON_START
  BNE SetStateLoadPlaying

  RTS
  
  
SetStateLoadPlaying:
  LDA #STATELOADPLAYING 
  STA gamestate
SetStateLoadPlayingDone:  


 
TitleBallBounce:

TitleMoveBallRight:
  LDA ballright
  BEQ TitleMoveBallRightDone		;;if ballright=0, skip this section

  LDA ballx
  CLC
  ADC ballspeedx        	;;ballx position = ballx + ballspeedx
  STA ballx

  LDA ballx
  CMP #RIGHTWALL
  BCC TitleMoveBallRightDone      ;;if ball x < right wall, still on screen, skip next section
  LDA #$00
  STA ballright
  LDA #$01
  STA ballleft         ;;bounce, ball now moving left
TitleMoveBallRightDone:


TitleMoveBallLeft:
  LDA ballleft
  BEQ TitleMoveBallLeftDone   ;;if ballleft=0, skip this section

  LDA ballx
  SEC
  SBC ballspeedx        ;;ballx position = ballx - ballspeedx
  STA ballx

  LDA ballx
  CMP #LEFTWALL
  BCS TitleMoveBallLeftDone      ;;if ball x > left wall, still on screen, skip next section
  LDA #$01
  STA ballright
  LDA #$00
  STA ballleft         ;;bounce, ball now moving right
TitleMoveBallLeftDone:


TitleMoveBallUp:
  LDA ballup
  BEQ TitleMoveBallUpDone   ;;if ballup=0, skip this section

  LDA bally
  SEC
  SBC ballspeedy        ;;bally position = bally - ballspeedy
  STA bally

  LDA bally
  CMP #TOPWALL
  BCS TitleMoveBallUpDone      ;;if ball y > top wall, still on screen, skip next section
  LDA #$01
  STA balldown
  LDA #$00
  STA ballup         ;;bounce, ball now moving down
TitleMoveBallUpDone:


TitleMoveBallDown:
  LDA balldown
  BEQ TitleMoveBallDownDone   ;;if ballup=0, skip this section

  LDA bally
  CLC
  ADC ballspeedy        ;;bally position = bally + ballspeedy
  STA bally

  LDA bally
  CMP #BOTTOMWALL
  BCC TitleMoveBallDownDone      ;;if ball y < bottom wall, still on screen, skip next section
  LDA #$00
  STA balldown
  LDA #$01
  STA ballup         ;;bounce, ball now moving down
TitleMoveBallDownDone:

	RTS
TitleBallBounceDone:
  