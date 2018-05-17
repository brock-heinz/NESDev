;; utils.asm

LoadPalettes:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006             ; write the high byte of $3F00 address
  LDA #$00
  STA $2006             ; write the low byte of $3F00 address
  LDX #$00              ; start out at 0
LoadPalettesLoop:
  LDA palette, x        ; load data from address (palette + the value in x)
                        ; 1st time through loop it will load palette+0
                        ; 2nd time through loop it will load palette+1
                        ; 3rd time through loop it will load palette+2
                        ; etc
  STA $2007             ; write to PPU
  INX                   ; X = X + 1
  CPX #$20              ; Compare X to hex $20, decimal 32 - copying 32 bytes = 8 palettesS
  BNE LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down
  RTS
						  
LoadPongAttribute:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$23
  STA $2006             ; write the high byte of $23C0 address
  LDA #$C0
  STA $2006             ; write the low byte of $23C0 address
  LDX #$00              ; start out at 0

LoadPongAttributeLoop:
   LDA bg_attributes, x	 ; load data from address (attribute + the value in x)
   STA $2007             ; write to PPU
   INX                   ; X = X + 1
   CPX #$40              ; Compare X to hex $40 - decimal 16 x 4
   BNE LoadPongAttributeLoop
   RTS
   

DrawSprite:
	; Push registers we're going to mess with 
	PHP ; Push Processor Status
	PHA ; Push Accumulator
	TXA ; Transfer Accumulator to X
	PHA ; Push Accumulator (X)

	LDX sprite_offset
	; Y Pos
	LDA sprite_ypos
	STA $0200, x
	INX
	; Tile
	LDA sprite_tile
	STA $0200, x
	INX
	; Attributes
	LDA sprite_attr
	STA $0200, x
	INX
	; X Position
	LDA sprite_xpos
	STA $0200, x
	INX
	STX sprite_offset

	; Restore registers
	PLA ; Pull Accumulator (X)
	TAX ; Transfer Accumulator to X
	PLA ; Pull Accumulator 
	PLP ; Pull Processor Statu
	RTS
 
ClearSprites:
	LDX #$FF
	LDA #$00
ClearSpritesLoop:
	STA $0200, x
	DEX 
	BNE ClearSpritesLoop
	RTS   