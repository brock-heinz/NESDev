; Pong Constants

STATETITLE     			= $00  ; displaying title screen
STATEPLAYING   			= $01  ; move paddles/ball, check for collisions
STATEGAMEOVER  			= $02  ; displaying game over screen
STATELOADTITLE 			= $03  ;  
STATELOADPLAYING     	= $04  ;  
STATELOADGAMEOVER		= $05  ;  

  
RIGHTWALL      = $F4  ; when ball reaches one of these, do something
TOPWALL        = $20
BOTTOMWALL     = $E0
LEFTWALL       = $04
  
  
PADDLE1X		= $08 ; horizontal position for paddles, doesnt move
PADDLE1XR		= $10 ; Right side of player 1 paddle (for collision tests)
PADDLE2X		= $F0 ;
PADDLE2XR		= $F8 ; Right side of the player 2 paddle, for collision test
PADDLE_SPEED	= $02 ; 

PADDLE_SPRITES	= $05 ; 5 sprites tall
PADDLE_HEIGHT	= $28 ; 5x8 = 40 pixels
PADDLE_WIDTH 	= $08 ; 1 sprite, 8 pixels wide
BALL_SPEED		= $01
BALL_SIZE		= $08 ; 1 sprite, 8 pixels