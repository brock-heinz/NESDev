; Gameplay 



LoadGameplay:

  ; Turn off screen
    LDA #$00 
    STA PPU_CTRL
    STA PPU_MASK

  ; Clear old sprite data
	LDX #$FF
	LDA #$00
ClearSpritesLoop:
	STA $0200, x
	DEX 
	BNE ClearSpritesLoop
  
	; Load background	
  
	; Load palettes
  
	; Initialize gameplay variables
	LDA #100
	STA paddle1ytop
	STA paddle2ytop
  
	LDA #$00
	STA score1
	STA score2
  
	; Assume player 2 is cpu for now
  	LDA #TRUE
  	STA player2_is_cpu

  	; Init ball motion
  	JSR GameplayInitBall

	; Turn on screen
  
	LDA #%10011000   ; enable NMI, sprites from Pattern Table 1, background from Pattern Table 1
	STA $2000
	LDA #%00011110   ; enable sprites, enable background, no clipping on left side
	STA $2001
  
	; Set the new state
	LDA #STATEPLAYING 
	STA gamestate
LoadGameplayDone:	
	RTS


GameplayInitBall:
	LDA #$01
	STA balldown
	STA ballleft
	LDA #$00
	STA ballup
	STA ballright
	  
	LDA #$50
	STA bally
	  
	LDA #$80
	STA ballx
	  
	LDA #BALL_SPEED
	STA ballspeedx
	STA ballspeedy
	RTS




TickGameplay:
  JSR GameplayMovePaddles
  JSR GameplayMoveBall
  JSR GameplayCollideBall
  JSR GameplayDrawSprites
TickGameplayDone:
  RTS



GameplayMovePaddles:
	LDA buttons1
	AND #DPAD_DOWN
	BEQ SkipMoveDown
	LDA paddle1ytop
	CLC
	ADC #PADDLESPEED
	STA paddle1ytop
SkipMoveDown:

	LDA buttons1
	AND #DPAD_UP
	BEQ SkipMoveUp
	LDA paddle1ytop
	SEC
	SBC #PADDLESPEED  
	STA paddle1ytop
SkipMoveUp:

	; TODO check for CPU or controller for player 2

GameplayMovePaddlesDone:
	RTS



GameplayMoveBall:

GameplayMoveBallRight:
	LDA ballright
	BEQ GameplayMoveBallRightDone		;;if ballright=0, skip this section

	LDA ballx
	CLC
	ADC ballspeedx        	;;ballx position = ballx + ballspeedx
	STA ballx

	LDA ballx
	CMP #RIGHTWALL
	BCC GameplayMoveBallRightDone      ;;if ball x < right wall, still on screen, skip next section
	; Player 1 scores	
	LDX score1
	INX
	STX score1
	JSR GameplayInitBall
GameplayMoveBallRightDone:

GameplayMoveBallLeft:
	LDA ballleft
	BEQ GameplayMoveBallLeftDone		

	LDA ballx
	SEC
	SBC ballspeedx        ;;ballx position = ballx - ballspeedx
	STA ballx

	LDA ballx
	CMP #LEFTWALL
	BCS GameplayMoveBallLeftDone    
	; Player 2 scores	
	LDX score2
	INX
	STX score2
	JSR GameplayInitBall
GameplayMoveBallLeftDone:
	
GameplayMoveBallDone:
	RTS


GameplayCollideBall:

GameplayCollideBallDone:
	RTS
	
	
	
GameplayDrawSprites:
	LDA #$00
	STA sprite_offset
	
	; Draw Ball
	;LDA bally  
	;STA $0200
	;LDA #$80
	;STA $0201
	;LDA #$00
	;STA $0202
	;LDA ballx
	;STA $0203
	
	LDA bally
	STA sprite_ypos
	LDA #$80 ; ball sprite tile index
	STA sprite_tile
	LDA #$00
	STA sprite_attr
	LDA ballx
	STA sprite_xpos
	JSR DrawSprite
	
	; Draw Player 1 
	
	; Use the square block for the paddles
	LDA #$84 
	STA sprite_tile	

	LDA #PADDLE1X
	STA sprite_xpos
	LDA paddle1ytop	
	LDX #PADDLE_SPRITES
DrawPlayer1Loop:
	STA sprite_ypos
	JSR DrawSprite
	CLC
	ADC #$08
	DEX
	BNE DrawPlayer1Loop


	
	; Draw Player 2
	LDA #PADDLE2X
	STA sprite_xpos
	LDA paddle2ytop	
	LDX #PADDLE_SPRITES
DrawPlayer2Loop:
	STA sprite_ypos
	JSR DrawSprite
	CLC
	ADC #$08
	DEX
	BNE DrawPlayer2Loop
	
	; Draw Score for Player 1
	LDA #$10
	STA sprite_ypos
	LDA #$20
	STA sprite_xpos

	LDA score1
	CLC
	ADC #$30
	STA sprite_tile
	LDA #$00
	STA sprite_attr

	JSR DrawSprite
	

	; Draw Score for Player 2
	LDA #$10
	STA sprite_ypos
	LDA #$D0
	STA sprite_xpos

	LDA score2
	CLC
	ADC #$30
	STA sprite_tile
	LDA #$00
	STA sprite_attr

	JSR DrawSprite
	

GameplayDrawSpritesDone:
	RTS



