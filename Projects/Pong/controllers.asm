; Controllers
;

; Read 			
; Order		- Button	- Bit Mask
; 1 		- A			- #$10000000
; 2 		- B			- #$01000000
; 3 		- Select	- #$00100000
; 4 		- Start		- #$00010000
; 5 		- Up		- #$00001000
; 6 		- Down		- #$00000100
; 7 		- Left		- #$00000010
; 8 		- Right		- #$00000001

; TODO: Add support for "pressed this frame" and "released this frame" states

ReadController1:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
  LDX #$08
ReadController1Loop:
  LDA $4016
  LSR A            ; bit0 -> Carry
  ROL buttons1     ; bit0 <- Carry
  DEX
  BNE ReadController1Loop
  RTS
  
ReadController2:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
  LDX #$08
ReadController2Loop:
  LDA $4017
  LSR A            ; bit0 -> Carry
  ROL buttons2     ; bit0 <- Carry
  DEX
  BNE ReadController2Loop
  RTS  
  