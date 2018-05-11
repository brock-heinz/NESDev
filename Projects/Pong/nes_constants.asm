; NES Constants


TRUE		= $01
FALSE		= $00


; PPU 

PPU_CTRL 		= $2000 ; NMI enable (V), PPU master/slave (P), sprite height (H), background tile select (B), sprite tile select (S), increment mode (I), nametable select (NN)
PPU_MASK 		= $2001 ; color emphasis (BGR), sprite enable (s), background enable (b), sprite left column enable (M), background left column enable (m), greyscale (G)
PPU_STATUS		= $2002 ; vblank (V), sprite 0 hit (S), sprite overflow (O), read resets write pair for $2005/2006    
PPU_OAM_ADDR	= $2003 ; OAM read/write address
PPU_OAM_DATA	= $2004 ; OAM data read/write
PPU_SCROLL 		= $2005 ; fine scroll position (two writes: X, Y)
PPU_ADDRESS		= $2006 ; PPU read/write address (two writes: MSB, LSB)  
PPU_DATA		= $2007 ; PPU data read/write
OAM_DMA 		= $4014 ; OAM DMA high address



;
; Controller Bitmasks
; 
BUTTON_A		= %10000000
BUTTON_B		= %01000000
BUTTON_SELECT	= %00100000
BUTTON_START 	= %00010000 
DPAD_UP			= %00001000
DPAD_DOWN		= %00000100
DPAD_LEFT		= %00000010
DPAD_RIGHT		= %00000001


;
; Palette Colors
;
COLOR_BLACK = $0F
COLOR_WHTIE = $30

COLOR_GREY1 = $3D ; Lightest Grey
COLOR_GREY2 = $10 ; 
COLOR_GREY3 = $00 ; 
COLOR_GREY4 = $2D ; Darkest Grey



; PPU_CTRL = $2000
;7  bit  0
;---- ----
;VPHB SINN
;|||| ||||
;|||| ||++- Base nametable address
;|||| ||    (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
;|||| |+--- VRAM address increment per CPU read/write of PPUDATA
;|||| |     (0: add 1, going across; 1: add 32, going down)
;|||| +---- Sprite pattern table address for 8x8 sprites
;||||       (0: $0000; 1: $1000; ignored in 8x16 mode)
;|||+------ Background pattern table address (0: $0000; 1: $1000)
;||+------- Sprite size (0: 8x8; 1: 8x16)
;|+-------- PPU master/slave select
;|          (0: read backdrop from EXT pins; 1: output color on EXT pins)
;+--------- Generate an NMI at the start of the
;           vertical blanking interval (0: off; 1: on)

; PPU_MASK = $2001
;7  bit  0
;---- ----
;BGRs bMmG
;|||| ||||
;|||| |||+- Greyscale (0: normal color, 1: produce a greyscale display)
;|||| ||+-- 1: Show background in leftmost 8 pixels of screen, 0: Hide
;|||| |+--- 1: Show sprites in leftmost 8 pixels of screen, 0: Hide
;|||| +---- 1: Show background
;|||+------ 1: Show sprites
;||+------- Emphasize red*
;|+-------- Emphasize green*
;+--------- Emphasize blue*


; PPU_STATUS = $2002
;
;7  bit  0
;---- ----
;VSO. ....
;|||| ||||
;|||+-++++- Least significant bits previously written into a PPU register
;|||        (due to register not being updated for this address)
;||+------- Sprite overflow. The intent was for this flag to be set
;||         whenever more than eight sprites appear on a scanline, but a
;||         hardware bug causes the actual behavior to be more complicated
;||         and generate false positives as well as false negatives; see
;||         PPU sprite evaluation. This flag is set during sprite
;||         evaluation and cleared at dot 1 (the second dot) of the
;||         pre-render line.
;|+-------- Sprite 0 Hit.  Set when a nonzero pixel of sprite 0 overlaps
;|          a nonzero background pixel; cleared at dot 1 of the pre-render
;|          line.  Used for raster timing.
;+--------- Vertical blank has started (0: not in vblank; 1: in vblank).
;           Set at dot 1 of line 241 (the line *after* the post-render
;           line); cleared after reading $2002 and at dot 1 of the
;           pre-render line.
