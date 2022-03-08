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
listTitle		BYTE		 "You entered the following numbers: ",13,10,0
space			BYTE		  " ",0
comma			BYTE		  ",",0
subSymbol		BYTE		  "-",0
nullTerm		BYTE		  0 
inputNum		BYTE		  13 DUP (?)						; 13 accounts for the null byte and +/- signs  
outputArr		SDWORD		  10 DUP (?)
num2String		BYTE		  1 DUP (?)
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
  PUSH		OFFSET invalidMsg					; address of Error message 
  PUSH		LENGTHOF inputNum
  PUSH		OFFSET prompt						; address of prompt 
  PUSH		EBX									; contains address of output array 
  PUSH		OFFSET counter					
  CALL		ReadVal
  ADD		EBX, 4								 
  LOOP		_loopingChars 
				
  PUSH		OFFSET listTitle					; title of list 
  PUSH		OFFSET comma						; insert commas between nums 
  PUSH		OFFSET space						; insert spaces between nums 
  PUSH		OFFSET subSymbol	
  PUSH		OFFSET outputArr
  PUSH		OFFSET num2String					; address of number stored in BYTE 
  CALL		listOfNums 

  mDisplayString	OFFSET nullTerm				; insert null terminator at end of list 


  INVOKE	ExitProcess,0						 
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
	  XOR		EAX, EAX						; clear EAX from previous calculation 
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

	  JC		_invalidInput			; if carry flag is set input is too large

	  ADD		EAX, EBX
	  JC		_invalidInput			; if carry flag is set input is too large

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
  MOV		EBX, [EBP + 12]						; move address of SDWORD to be filled into EBX
  MOV		[EBX], ECX	

  POP		EAX 
  POP		EDX 
  POP		EBX 
  POP		ESI 
  POP		ECX
  RET		24
ReadVal		ENDP 

;-------------------------------------------------------
; Name: WriteVal 
;
; Receives: [EBP + 8]		=  Address of output BYTE 
;           [EBP + 12]		=  Address of SDWORD array 
;			[EBP + 16]		=  Address of minus sign 
;-------------------------------------------------------
WriteVal	PROC
  PUSH		EBP 
  MOV		EBP, ESP 
  PUSH		EAX
  PUSH		EBX
  PUSH		EDX 
  PUSH		ECX 

  MOV		EDI, [EBP + 8]					 ; load address of output into EDI
  MOV		EAX, [EBP + 12]					 ; load address of SDWORD into EAX 
  MOV		EAX, [EAX]						 ; loads element from SDWORD to be divided in convert2Chars
  MOV		ECX, 0							
  PUSH		ECX								 ; push 0 to indicate end of array

  CMP		EAX, 0
  JS		_makeNeg
  JMP		_convertToChars 

_makeNeg: 
  mDisplayString [EBP + 16]
  NEG		EAX
  
  
_convertToChars: 
  XOR		EDX, EDX						 ; clears remainder in EDX for division 
  MOV		EBX, 10							 
  IDIV		EBX								 ; divide by 10 due to decimal/base-10 

  ADD		EDX, 48							 ; add 48 to remainder stored in EDX to get ASCII character  
  PUSH		EDX
  CMP		EAX, 0
  JNZ		_convertToChars					 ; if quotient != 0 keep looping 

_displayChars:
  POP		EAX								 ; pop digits to EAX in reverse 		
  MOV		EDX, EAX						 ; move to EDX for printing 

  mDisplayString[EBP + 8]					 ; display individual character 

  STOSB
  DEC		EDI 
  CMP		EAX, 0
  JNZ		_displayChars 

  POP		ECX 
  POP		EDX
  POP		EBX
  POP		EAX
  POP		EBP 
  RET		12
WriteVal	ENDP 


;-------------------------------------------------------------------
; Procedure: listOfNums 
;	Loops through the filled array of numbers in the SDWORD
;   and prints all 10 user-entered numbers. 
;
; Receives:		[EBP + 8]	=	address of SDWORD array of numbers
;				[EBP + 12]	=	address of character BYTE 
;-------------------------------------------------------------------
listOfNums	PROC
  PUSH		EBP
  MOV		EBP, ESP 
  PUSH		ECX							; ECX will be counter to loop through SDWORD of numbers
  PUSH		EBX							; EBX will hold the address of the filled SDWORD 
  PUSH		EAX							
  PUSH		EDX							; EDX points to address of negative sign 

  MOV		EDX, [EBP + 16]				; address of minus sign 
  MOV		EAX, [EBP + 12]				; address of SDWORD array of numbers
  MOV		EBX, [EBP + 8]				
  MOV		ECX, 10						; loop though all 10 numbers 

  mDisplayString [EBP + 28]				; Writes title to screen 

loopNums: 
  PUSH		EDX 
  PUSH		EAX
  PUSH		EBX 
  CALL		WriteVal					; Call WriteVal to convert each number 
  CMP		ECX, 1 
  JE		_finish 
  ADD		EAX, 4 
  mDisplayString [EBP + 24]				; Write comma after number 
  mDisplayString [EBP + 20]			    ; Write space after comma 
  LOOP		loopNums



_finish: 
  POP		EDX 
  POP		EAX 
  POP		EBX 
  POP		ECX 
  POP		EBP 
  RET		24
listOfNums	ENDP
			
END main