TITLE Low-level I/O procedures     (Proj6_culleyp.asm)

; Author: Patrick Culley
; Last Modified: 2/27/2022 
; OSU email address: culleyp@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: #6       Due Date: 3/13/2022
; Description: Designing low-level I/O procedures 


INCLUDE Irvine32.inc

mDisplayString	 MACRO	 chars					; displays strings using WriteString method 
  PUSH		EDX 
  MOV		EDX, chars 
  CALL		WriteString 
  POP		EDX 
ENDM 

mGetString		 MACRO	 chars, input, count, size				; prints prompt to user and gathers integer 
  PUSH		EDX 
  PUSH		EAX 
  PUSH		ECX
  MOV		EDX, chars
  CALL		WriteString
  MOV		EDX, input
  MOV		ECX, size 
  CALL		ReadString
  MOV		EDX, count 
  MOV		[EDX], EAX 
  POP		ECX 
  POP		EAX
  POP		EDX
ENDM 


.data
intro1			BYTE		 "Programming assignment 6: Designing low-level I/O procedures",13,10,
							 "Written by: Patrick Culley",13,10,13,10,0
intro2			BYTE		 "Please provide 10 signed decimal integers.",13,10,
							 "Each number needs to be small enough to fit inside a 32 bit register. After you have finished",13,10,
							 "inputting the raw numbers I will display a list of the integers, their sum, and their average",13,10, 
							 "value",13,10,13,10,0
prompt			BYTE		 "Please enter a signed integer: ",0
invalidMsg		BYTE		 "ERROR: You did not enter a signed number or your number was too big.",13,10,
							 "Please try again: ",0
inputNum		BYTE		  13 DUP (?)						; 13 accounts for the null byte and +/- signs  
outputArr		SDWORD		  10 DUP (?)
outputCount		DWORD		  0 
counter			DWORD		  ? 



.code
main PROC
  mDisplayString	OFFSET intro1				; print intro1 to screen  
  mDisplayString	OFFSET intro2				; print intro2 to screen 

  MOV		EBX, OFFSET outputArr 
  MOV		ECX, 10
_loopingChars:									; loop through userNum array to perform conversions 
  PUSH		OFFSET inputNum
  PUSH		OFFSET invalidMsg
  PUSH		LENGTHOF inputNum
  PUSH		OFFSET prompt
  PUSH		EBX 
  PUSH		OFFSET counter
  CALL		ReadVal
  ADD		EBX, 4
  LOOP		_loopingChars 

  ;PUSH		OFFSET outputArr 
  ;CALL		WriteVal 

  INVOKE	ExitProcess,0						; exit to operating system
main ENDP


ReadVal		PROC
  LOCAL		loopCounter:DWORD, signCount:DWORD        ;  inputNum[12]:BYTE
  PUSH		ECX
  PUSH		ESI
  PUSH		EBX 
  PUSH		EDX		
  PUSH		EAX 

  mGetString  [EBP + 16], [EBP + 28], [EBP + 8], [EBP + 20]

_outerLoop: 
  MOV		ESI, [EBP + 28]						; move character input array stored in InputNum to ESI 
  MOV		EBX, [EBP + 8]						 
  MOV		ECX, [EBX]							; move char count from EBX to ECX to act as loop counter 
  MOV		loopCounter, ECX					; local variable used as loop counter 

  MOV		EAX, 0								; begins accumulator for convertToNum 
  MOV		ECX, 0								; this will initialize the holding number for our calculations 
  MOV		signCount, 0			

  CMP		loopCounter, 0						; if no user input counter is zero 
  JE		_invalidInput 
  
	  LODSB
	  CMP		AL, 43
	  JE		_goPosi
	  CMP		AL, 45
	  JE		_goNeg
	  JMP		_signContinue 					; jump to beginning of vaidation to check if input is in range of [48...57]
	_goPosi: 
	  DEC		loopCounter
	  JMP		_innerLoop  

	_goNeg: 
	  DEC		loopCounter
	  INC		signCount						; if sign count is set to 1 then negation is made below in 

	_innerLoop:	
	  XOR		EAX, EAX					; clear EAX from previous calculation 
	  LODSB

	_signContinue: 
	  CMP		AL, 48
	  JB		_invalidInput
	  CMP		AL, 57
	  JA		_invalidInput
	  JMP		_convertToNum 

	_convertToNum: 
	  SUB		AL, 48		
	  MOV		EBX, EAX
	  MOV		EAX, ECX 
	  MOV		EDX, 10
	  MUL		EDX

	  JC		_invalidInput			; needs correction, if carry flag is set input is too large

	  ADD		EAX, EBX
	  JC		_invalidInput			; needs correction, if carry flag is set input is too large

	  MOV		ECX, EAX 
	  DEC		loopCounter
	  CMP		loopCounter, 0

	  JE		_theEnd 		
	  JMP		_innerLoop 

_invalidInput: 
  mGetString  [EBP + 24], [EBP + 28], [EBP + 8], [EBP + 20]
  JMP		_outerLoop 


_theEnd:
  CMP		signCount, 1
  JE		_isNegative
  CMP		ECX, 7FFFFFFFH	 ; 0111 1111 1111 1111 1111 1111 1111 1111 = 7FFFFFFFH
  JA		_invalidInput
  JMP		_exitReadVal

_isNegative:
  CMP		ECX, 80000000H    ; 1000 0000 0000 0000 0000 0000 0000 0000 = 80000000H
  JA		_invalidInput
  NEG		ECX 

_exitReadVal: 
  MOV		EBX, [EBP + 12]						; move address of SDWORD to be filled into EDI
  MOV		[EBX], ECX	

  POP		EAX 
  POP		EDX 
  POP		EBX 
  POP		ESI 
  POP		ECX
  RET		24
ReadVal		ENDP 


;WriteVal	PROC
  PUSH		EBP 	


  RET		4
;WriteVal	ENDP 

			
END main