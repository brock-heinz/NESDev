; Pong Constants

STATETITLE     			= $00  ; displaying title screen
STATEPLAYING   			= $01  ; move paddles/ball, check for collisions
STATEGAMEOVER  			= $02  ; displaying game over screen
STATELOADTITLE 			= $03  ;  
STATELOADPLAYING     	= $04  ;  
STATELOADGAMEOVER		= $05  ;  

  
RIGHTWALL      = $F4  	; when ball reaches one of these, do something
TOPWALL        = $30	; 32 pixels / 4 tiles
BOTTOMWALL     = $D8	; 16 pixels / 2 tiles
LEFTWALL       = $04
  
PADDLE_LIM_TOP  = $38
PADDLE_LIM_BTM  = $B0  
  
PADDLE1X		= $0C ; horizontal position for paddles, doesnt move
PADDLE1XR		= $1C ; Right side of player 1 paddle (for collision tests)
PADDLE2X		= $EC ;
PADDLE2XR		= $F4 ; Right side of the player 2 paddle, for collision test
PADDLE_SPEED	= $02 ; 

PADDLE_SPRITES	= $05 ; 5 sprites tall
PADDLE_HEIGHT	= $28 ; 5x8 = 40 pixels
PADDLE_WIDTH 	= $08 ; 1 sprite, 8 pixels wide
BALL_SPEED		= $01
BALL_SIZE		= $08 ; 1 sprite, 8 pixels