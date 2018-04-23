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
  
PADDLE1X       = $08  ; horizontal position for paddles, doesnt move
PADDLE2X       = $F0

