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
inputNum		BYTE		  12 DUP (?)			; verify if null terminated val required 
outputArr		SDWORD		  10 DUP (?)
counter			DWORD		  ? 



.code
main PROC
  mDisplayString	OFFSET intro1													; print intro1 to screen  
  mDisplayString	OFFSET intro2													; print intro2 to screen 

  PUSH		OFFSET inputNum
  PUSH		OFFSET invalidMsg
  PUSH		LENGTHOF inputNum
  PUSH		OFFSET prompt 
  PUSH		OFFSET outputArr 
  PUSH		OFFSET counter 
  CALL		ReadVal

  INVOKE	ExitProcess,0																; exit to operating system
main ENDP


ReadVal		PROC
  LOCAL		loopCounter:DWORD, signCount:DWORD        ;  inputNum[12]:BYTE
  PUSH		ECX
  PUSH		ESI
  PUSH		EBX 
  PUSH		EDX
  PUSH		EDI			
  
  mGetString  [EBP + 16], [EBP + 28], [EBP + 8], [EBP + 20]						 

_outerLoop: 
  PUSH		ECX									; push running total 
  PUSH		EBX
  MOV		ESI, [EBP + 28]						; move character array to ESI 
  MOV		EBX, [EBP + 8]						 
  MOV		ECX, [EBX]							; move char count from EBX to ECX to act as loop counter 
  MOV		loopCounter, ECX					; local variable used as loop counter 
  MOV		EDI, [EBP + 12]						; move SDWORD array to EDI to be filled 
  POP		EBX
  POP		ECX

  MOV		EAX, 0								; begins accumulator for convertToNum 
  MOV		ECX, 0								; this will initialize the holding number for our calculations 
  MOV		signCount, 0			

  CMP		loopCounter, 0						; compare if only sign and length = 1
  JE		_invalidInput 
  
	  LODSB
	  CMP		AL, 43
	  JE		_goPosi
	  CMP		AL, 45
	  JE		_goNeg
	  JMP		_signContinue 					; check if first character is a positive or negative sign

	_goPosi: 
	  DEC		loopCounter
	  JMP		_innerLoop  

	_goNeg: 
	  DEC		loopCounter
	  INC		signCount 

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
  CMP		EAX, 7FFFFFFFH	 ; 0111 1111 1111 1111 1111 1111 1111 1111 = 7FFFFFFFH
  JA		_invalidInput
  JMP		_exitReadVal

_isNegative:
  CMP		EAX, 80000000H    ; 1000 0000 0000 0000 0000 0000 0000 0000 = 80000000H
  JA		_invalidInput
  NEG		EAX 

_exitReadVal: 

  CALL		WriteInt
  POP		EDI
  POP		EDX 
  POP		EBX 
  POP		ESI 
  POP		ECX
  RET		24
ReadVal		ENDP 



			
END main