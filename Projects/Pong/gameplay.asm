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

GameplayMovePaddlesDone:
	RTS



GameplayMoveBall:

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
	LDA paddle1ytop
	STA sprite_ypos
	LDA #$84 
	STA sprite_tile
	LDA #PADDLE1X
	STA sprite_xpos
	JSR DrawSprite
	
	; Draw Player 1 
	LDA paddle2ytop
	STA sprite_ypos
	LDA #PADDLE2X
	STA sprite_xpos
	JSR DrawSprite
	
	; Draw Score for Player 1
	
	; Draw Scpre for Player 2
	
	

GameplayDrawSpritesDone:
	RTS



