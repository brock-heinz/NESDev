; Pong Variables

watch      .rs 1  ; .rs 1 means reserve one byte of space
gamestate  .rs 1  ; current application state
ballx      .rs 1  ; ball horizontal position
bally      .rs 1  ; ball vertical position
ballup     .rs 1  ; 1 = ball moving up
balldown   .rs 1  ; 1 = ball moving down
ballleft   .rs 1  ; 1 = ball moving left
ballright  .rs 1  ; 1 = ball moving right
ballspeedx .rs 1  ; ball horizontal speed per frame
ballspeedy .rs 1  ; ball vertical speed per frame
paddle1ytop		.rs 1  ; player 1 paddle top Y position
paddle2ytop		.rs 1  ; player 2 paddle top Y position
buttons1   .rs 1  ; player 1 gamepad buttons, one bit per button
buttons2   .rs 1  ; player 2 gamepad buttons, one bit per button
score1     .rs 1  ; player 1 score
score2     .rs 1  ; player 2 score

player2_is_cpu	.rs 1  ; player 2 score

sprite_offset 	.rs 1 ; sprite write address
sprite_xpos		.rs 1 ; sprite X position
sprite_ypos		.rs 1 ; sprite Y position
sprite_attr		.rs 1 ; sprite attributes
sprite_tile		.rs 1 ; sprite tile address
