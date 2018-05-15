; Gameplay 



LoadGameplay:

	; Turn screen off
	LDA #$00
	STA $2000
	LDA #$00  
	STA $2001

	; Clear old sprite data
	JSR ClearSprites
  
	; Load Background Tiles
	LDA $2002             ; read PPU status to reset the high/low latch
	LDA #$20
	STA $2006             ; write the high byte of $2000 address
	LDA #$00
	STA $2006             ; write the low byte of $2000 address
	LDX #LOW(bg_nametable_rle)
	LDY #HIGH(bg_nametable_rle)
	JSR unrle 
	
	; Load Background Attributes
	JSR LoadPongAttribute	
 
	; Load Palettes
	JSR LoadPalettes									
 
  
	; Initialize gameplay variables
	LDA #100
	STA paddle1ytop
	STA paddle2ytop
  
	LDA #$00
	STA score1
	STA score2
  
	; Assume player 2 is person for now
  	LDA #FALSE
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

	; Player 1 controller movement
	LDA buttons1
	AND #DPAD_DOWN
	BEQ SkipP1MoveDown
	LDA paddle1ytop
	CLC
	ADC #PADDLE_SPEED
	CMP #PADDLE_LIM_BTM
	BCS SkipP1MoveDown
	STA paddle1ytop
SkipP1MoveDown:

	LDA buttons1
	AND #DPAD_UP
	BEQ SkipP1MoveUp
	LDA paddle1ytop
	SEC
	SBC #PADDLE_SPEED
	CMP #PADDLE_LIM_TOP
	BCC SkipP1MoveUp	
	STA paddle1ytop
SkipP1MoveUp:

	; TODO check for CPU or controller for player 2
	
	; Player 2 controller movement
	LDA buttons2
	AND #DPAD_DOWN
	BEQ SkipP2MoveDown
	LDA paddle2ytop
	CLC
	ADC #PADDLE_SPEED
	STA paddle2ytop
SkipP2MoveDown:

	LDA buttons2
	AND #DPAD_UP
	BEQ SkipP2MoveUp
	LDA paddle2ytop
	SEC
	SBC #PADDLE_SPEED  
	STA paddle2ytop
SkipP2MoveUp:


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

	; PLAYER2 PADDLE COLLISION
	; We are going to test the center right point of the ball sprite against the
	; 'box' formed by the paddle. 
	LDA ballx
	CLC
	ADC #BALL_SIZE
	CMP #PADDLE2X	 			; Carry flag is set if A(bally+BALL_SIZE) >= M (#PADDLE2X)
	BCC Player2NoBallCollision 	; If the right side of the paddle is < than PADDLE2X, we're done 
	CMP #PADDLE2XR 				; Carry flag is set if A(bally+BALL_SIZE) >= M (#PADDLE2XR)
	BCS Player2NoBallCollision 	; If the right side of the ball is >= than PADDLE2XR, we're done
	
	LDA bally
	CLC
	ADC #BALL_SIZE				; We want the bottom of the ball
	CMP paddle2ytop				; Carry flag is set if (bally+BALL_SIZE) >= M (paddle2ytop)
	BCC Player2NoBallCollision	; If the bottom of the ball is < the top of the paddle, we're done
	LDA paddle2ytop
	ADC #PADDLE_HEIGHT
	CMP bally					; Carry flag set if (paddle2ytop+PADDLE_HEIGHT) >= bally
	BCC Player2NoBallCollision 	; If the bottom of the paddle is < top of the ball, we're done
	
	
	; The ball has collided with the paddle, so bounce it!
	LDA #$01
	STA ballleft
	LDA #$00
	STA ballright
Player2NoBallCollision:
	
	LDA ballx
	CMP #RIGHTWALL
	BCC GameplayMoveBallRightDone      ;;if ball x < right wall, still on screen, skip next section
	; Player 1 scores!	
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

	; PLAYER 1 PADDLE COLLISION
	; We are going to test the center left point of the ball sprite against the
	; 'box' formed by the paddle. 
	LDA #PADDLE1X
	CMP ballx	; Compare PADDLE1X to ballx, Carry flag is set if A >= M
	BCS Player1NoBallCollision ; If the left side of the ball is to the left of the left side the paddle, we're done
	CLC
	ADC #PADDLE_WIDTH
	CMP ballx	; Compare PADDLE1X+PADDLE_WIDTH to ballx, Carry flag is set if A >= M
	BCC Player1NoBallCollision ; If the left side of the ball is not to the left of the right side the paddle, we're done

	LDA bally
	CLC
	ADC #BALL_SIZE
	CMP paddle1ytop				; compare the bottom of the ball with the top of the paddle, carry flag is set if  A >= M
	BCC Player1NoBallCollision	; If the carry flag is clear, then the ball is above the paddle on screen
	LDA paddle1ytop
	CLC
	ADC #PADDLE_HEIGHT
	CMP bally					; compare the top of the ball with the bottom of the paddle, carry flag is set if  A >= M
	BCC Player1NoBallCollision	; If the carry flag is clear, then the ball is below the paddle on screen
	
	; The ball has collided with the paddle, so bounce it!
	LDA #$00
	STA ballleft
	LDA #$01
	STA ballright
Player1NoBallCollision:


	LDA ballx
	CMP #LEFTWALL
	BCS GameplayMoveBallLeftDone    
	; Player 2 scores!	
	LDX score2
	INX
	STX score2
	JSR GameplayInitBall
GameplayMoveBallLeftDone:

GameplayMoveBallUp:
  LDA ballup
  BEQ GameplayMoveBallUpDone   ;;if ballup=0, skip this section

  LDA bally
  SEC
  SBC ballspeedy        ;;bally position = bally - ballspeedy
  STA bally

  LDA bally
  CMP #TOPWALL
  BCS GameplayMoveBallUpDone      ;;if ball y > top wall, still on screen, skip next section
  LDA #$01
  STA balldown
  LDA #$00
  STA ballup         ;;bounce, ball now moving down
GameplayMoveBallUpDone:


GameplayMoveBallDown:
  LDA balldown
  BEQ GameplayMoveBallDownDone   ;;if ballup=0, skip this section

  LDA bally
  CLC
  ADC ballspeedy        ;;bally position = bally + ballspeedy
  STA bally

  LDA bally
  CMP #BOTTOMWALL
  BCC GameplayMoveBallDownDone      ;;if ball y < bottom wall, still on screen, skip next section
  LDA #$00
  STA balldown
  LDA #$01
  STA ballup         ;;bounce, ball now moving down
GameplayMoveBallDownDone:

	
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
	
	; Draw paddle logic
	JSR StorePaddleSpriteTop
	
	LDA #PADDLE1X
	STA sprite_xpos
	LDA paddle1ytop	
	LDX #PADDLE_SPRITES
	
DrawPlayer1Loop:
	STA sprite_ypos
	PHA
	CPX #$04
	BNE Player1DrawStage2 
	JSR StorePaddleSpriteMid
Player1DrawStage2:
	CPX #$01
	BNE Player1DrawStage3
	JSR StorePaddleSpriteBottom
Player1DrawStage3:
	JSR DrawSprite
	PLA
	CLC
	ADC #$08
	DEX
	BNE DrawPlayer1Loop
	
	
	
	; Draw Player 2
	JSR StorePaddleSpriteTop
	
	LDA #PADDLE2X
	STA sprite_xpos
	LDA paddle2ytop
	LDX #PADDLE_SPRITES
DrawPlayer2Loop:
	STA sprite_ypos
	PHA
	CPX #$04
	BNE Player2DrawStage2 
	JSR StorePaddleSpriteMid
Player2DrawStage2:
	CPX #$01
	BNE Player2DrawStage3
	JSR StorePaddleSpriteBottom
Player2DrawStage3:
	JSR DrawSprite
	PLA
	CLC
	ADC #$08
	DEX
	BNE DrawPlayer2Loop
	
	; Draw Score for Player 1
	LDA #$18
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
	LDA #$18
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
	
	;JMP GameplayDrawSpritesDone
	
	
StorePaddleSpriteTop:
	LDA #$01
	STA sprite_tile
	LDA #$00
	STA sprite_attr
	RTS 
	
StorePaddleSpriteMid:
	LDA #$02 
	STA sprite_tile	
	RTS
	
StorePaddleSpriteBottom:
	LDA #$01 
	STA sprite_tile
	LDA #%11000000
	STA sprite_attr
	RTS
	
GameplayDrawSpritesDone:
	RTS



