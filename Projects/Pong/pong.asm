;;;;;;;;;;;;;;;
;; ROM Header
  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring
  

;;;;;;;;;;;;;;;

;; DECLARE SOME VARIABLES HERE
  .rsset $0000  ;;start variables at ram location 0
  .include "variables.asm"

;; DECLARE SOME CONSTANTS HERE
  .include "constants.asm"
  .include "nes_constants.asm"


  
  
;;;;;;;;;;;;;;;;;;
  .bank 0
  .org $C000 
RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT $2002
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2


              
;LoadBackground:
;  LDA $2002             ; read PPU status to reset the high/low latch
;  LDA #$20
;  STA $2006             ; write the high byte of $2000 address
;  LDA #$00
;  STA $2006             ; write the low byte of $2000 address
;
;  LDA #LOW(bg_nametable)
;  STA pointerLo       ; put the low byte of the address of background into pointer
;  LDA #HIGH(bg_nametable)
;  STA pointerHi       ; put the high byte of the address into pointer
;  
;  LDX #$00            ; start at pointer + 0
;  LDY #$00
;
;BGoutsideLoop:
;    
;BGinsideLoop:
;  LDA [pointerLo], y  ; copy one background byte from address in pointer plus Y
;  STA $2007           ; this runs 256 * 4 times
;  
;  INY                 ; inside loop counter
;  CPY #$00
;  BNE BGinsideLoop      ; run the inside loop 256 times before continuing down
;  
;  INC pointerHi       ; low byte went 0 to 256, so high byte needs to be changed now
;  
;  INX
;  CPX #$04
;  BNE BGoutsideLoop     ; run the outside loop 256 times before continuing down

   ;;; Let's try the RLE background! 
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$20
  STA $2006             ; write the high byte of $2000 address
  LDA #$00
  STA $2006             ; write the low byte of $2000 address
  LDX #LOW(title_nametable_rle)
  LDY #HIGH(title_nametable_rle)
  JSR unrle 


  JSR LoadPalettes
											
  JSR LoadPongAttribute					
		

   
   
;;;Set some initial ball stats
  LDA #$01
  STA balldown
  STA ballright
  LDA #$00
  STA ballup
  STA ballleft
  
  LDA #$50
  STA bally
  
  LDA #$80
  STA ballx
  
  LDA #$02
  STA ballspeedx
  STA ballspeedy
  
  ;; Init FamiTone2
  LDA #$80			; Force NTSC for FamiTone for now, need to detect this!
  STA ft_ntsc_mode	;$00 PAL, $80 NTSC
  LDX #LOW(pong_music_data)
  LDY #HIGH(pong_music_data)
  LDA ft_ntsc_mode
  JSR FamiToneInit		;init FamiTone
  LDA #0
  JSR FamiToneMusicPlay
	
;;:Set starting game state
  LDA #STATELOADTITLE
  STA gamestate
       
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001

Forever:
  JMP Forever     ;jump back to Forever, infinite loop, waiting for NMI
  
 

NMI:

  LDA #$01
  STA watch

  ; DMA sprites to the PPU 
  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014       ; set the high byte (02) of the RAM address, start the transfer

  ;;This is the PPU clean up section, so rendering the next frame starts properly.
  LDA #%10011000   ; enable NMI, sprites from Pattern Table 1, background from Pattern Table 1
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  LDA #$00        ;;tell the ppu there is no background scrolling
  STA $2005
  STA $2005
    
  ; FamiTone Update
  JSR FamiToneUpdate		;update sound

	
  ;;;all graphics updates done by here, run game engine


  JSR ReadController1  ;;get the current button data for player 1
  JSR ReadController2  ;;get the current button data for player 2
  
GameEngine:  
  LDA gamestate    		; Initialize Main Menu / Title Screen
  CMP #STATELOADTITLE
  BEQ JumpLoadTitle			
  
  LDA gamestate			;;game is displaying title screen
  CMP #STATETITLE
  BEQ JumpTickTitle    

  LDA gamestate    		; Initialize Gameplay state
  CMP #STATELOADPLAYING
  BEQ JumpLoadGameplay	
  
  LDA gamestate			; Gameplay! 
  CMP #STATEPLAYING
  BEQ JumpTickGameplay 
  
  LDA gamestate			; 
  CMP #STATEGAMEOVER
  BEQ EngineGameOver   
  
GameEngineDone:  
  LDA #$0F
  STA watch
  RTI             ; return from interrupt
 
 
 
 
;;;;;;;;
JumpLoadTitle:
  JSR LoadTitle
  JMP GameEngineDone
JumpLoadTitleDone:
  
JumpTickTitle:
  JSR TickTitle
  JMP GameEngineDone
JumpTickTitleDone:  

JumpLoadGameplay:
  JSR LoadGameplay
  JMP GameEngineDone
JumpLoadPlayingDone:

JumpTickGameplay:
  JSR TickGameplay
  JMP GameEngineDone
JumpTickGameplayDone:

  

;;;;;;;;; 
 
EngineGameOver:
  ;;if start button pressed
  ;;  turn screen off
  ;;  load title screen
  ;;  go to Title State
  ;;  turn screen on 
  JMP GameEngineDone
 
;;;;;;;;;;;
 
 
 
 
UpdateSprites:
  LDA bally  ;;update all ball sprite info
  STA $0200
  
  LDA #$80
  STA $0201
  
  LDA #$00
  STA $0202
  
  LDA ballx
  STA $0203
  
  ;;update paddle sprites
  RTS
 
 
 
; Returns a random 8-bit number in A (0-255)
; http://wiki.nesdev.com/w/index.php/Random_number_generator
; Random8:
;  TXA ; Transfer Accumulator to X
;  PHA ; Push Accumulator (X)
;
;  LDX #8     ; iteration count (generates 8 bits)
;  LDA random_seed+0
;  ASL        ; shift the register
;  ROL random_seed+1
;  BCC :+
;  EOR #$2D   ; apply XOR feedback whenever a 1 bit is shifted out
;  DEX
;  BNE :--
;  STA random_seed+0
;  CMP #0     ; reload flags
;
;  PLA ; Pull Accumulator (X)
;  TAX ; Transfer Accumulator to X
;  RTS

  ; Utility Subroutines
  .include "utils.asm" 
  
  ; Game State Logic
  .include "title_screen.asm"
  .include "controllers.asm"
  .include "gameplay.asm"

  ; RLE compression for use with NES Screen Tool
  .include "rle.asm"

  ; Famitone2 Config
FT_BASE_ADR		= $0300	;page in the RAM used for FT2 variables, should be $xx00
FT_TEMP			= $00	;3 bytes in zeropage used by the library as a scratchpad
FT_DPCM_OFF		= $c000	;$c000..$ffc0, 64-byte steps
FT_SFX_STREAMS	= 4		;number of sound effects played at once, 1..4
; FT_DPCM_ENABLE		;undefine to exclude all DMC code
; FT_SFX_ENABLE			;undefine to exclude all sound effects code
; FT_THREAD				;undefine if you are calling sound effects from the same thread as the sound update call

FT_PAL_SUPPORT			;undefine to exclude PAL support
FT_NTSC_SUPPORT			;undefine to exclude NTSC support
  ; FamiTone2 Library
  .include "famitone2.asm"
  
	
;;;;;;;;;;;;;;  
  
  .bank 1
  .org $E000


;bg_nametable:
;  .incbin "pong_nam.nam"

bg_nametable_rle:
  .incbin "pong_nam.rle"
  
title_nametable_rle:
  .incbin "pong_title.rle"

  
bg_attributes: 
  .incbin "pong_atr.atr"
  
palette:
  .incbin "pong.pal"  ;background palette
  .db COLOR_BLACK,$01,$21,$31,  $22,$02,$38,$3C,  $22,$1C,$15,$14,  $22,$02,$38,$3C   ;sprite palette


ft_pong: 
  .include "ft_pong.asm"
  

;;;;;;;;;;;;;;  
  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial
  
  
;;;;;;;;;;;;;;  
  
  
  .bank 2
  .org $0000
  .incbin "pong.chr"   ;includes 8KB graphics file from pong.chr