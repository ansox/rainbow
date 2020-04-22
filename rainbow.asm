  PROCESSOR 6502

  include "vcs.h"
  include "macro.h"

  seg code
  org $F000

START: 
  CLEAN_START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by turning on VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NEXTFRAME:
  LDA #2                      ;same as binary value %00000010
  STA VBLANK                  ;turn on VBLANK 
  STA VSYNC                   ;turn on VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the three lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  STA WSYNC                   ;first scanline
  STA WSYNC                   ;second scanline 
  STA WSYNC                   ;third scanline

  LDA #0                      
  STA VSYNC                   ;turn off VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let the TIA output the recommended 37 scanlines of VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  LDX #37                     ;X = 37
LOOPVBLANK:
  STA WSYNC                   ;hit WSYNC and wait for the next scaline
  DEX                         ;X--
  BNE LOOPVBLANK              ;loop while X != 0

  LDA #0 
  STA VBLANK                  ;turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw 192 visible scanlines (kernel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  LDX #192                    ;X = 192 (visible scanlines)
LOOPVISIBLE:
  STX COLUBK                  ;set the background color
  STA WSYNC                   ;wait for the next scanline
  DEX                         ;X--
  BNE LOOPVISIBLE             ;loop while X != 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Output 30 more VBLANK lines (overscan) to complete our frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  LDA #2                      ;hit and turn on VBLANK again
  STA VBLANK

  LDX #30                     ;X = 30 (overscan)
LOOPOVERSCAN:
  STA WSYNC                   ;wait for the next scanline
  DEX                         ;X--
  BNE LOOPOVERSCAN            ;loop while X != 0

  JMP NEXTFRAME

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete my ROM size to 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ORG #$FFFC
  .WORD START
  .WORD START

