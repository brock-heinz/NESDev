; Gameplay 



LoadGameplay:

  ; Turn off screen
    LDA #$00 
    STA PPU_CTRL
    STA PPU_MASK

  ; Clear old sprite data
;  LDX #$80
;  LDY #$00
;ClearSpritesLoop:
;  DEX 
;  BNE ClearSpritesLoop:
  
  ; Load background	
  
  ; Load palettes
  
  ; Turn on screen
  
  LDA #%10011000   ; enable NMI, sprites from Pattern Table 1, background from Pattern Table 1
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  
  ; Set the new state
  LDA #STATEPLAYING 
  STA gamestate
  RTS
LoadGameplayDone:




TickGameplay:
  JSR EnginePlaying
  JSR UpdateSprites
  RTS
TickGameplayDone: