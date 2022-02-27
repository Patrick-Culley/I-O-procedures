TITLE Program #6     (Proj6_culleyp.asm)

; Author: Patrick Culley
; Last Modified: 2/27/2022 
; OSU email address: culleyp@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: #6       Due Date: 3/13/2022
; Description: Project #6 


INCLUDE Irvine32.inc

; (insert macro definitions here)

; (insert constant definitions here)

.data

StringA   BYTE  "This is a 26 byte string!",0
StringB   BYTE  26 DUP(0)

.code
main PROC
  LOCAL	 sumLoop 
  MOV    ESI, OFFSET StringA
  MOV    EDI, OFFSET StringB
  MOV    ECX, LENGTHOF StringA
  
  REP    MOVSB   ; Copies all of StringA into StringB
  MOV	 EDX, OFFSET StringB  
  CALL	 WriteString
  INVOKE ExitProcess,0	; exit to operating system
main ENDP

END main
