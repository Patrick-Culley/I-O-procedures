TITLE Low-level I/O procedures     (Proj6_culleyp.asm)

; Author: Patrick Culley
; Last Modified: 3/8/2022 
; OSU email address: culleyp@oregonstate.edu
; Course number/section:   CS271   Section 400
; Project Number: #6       Due Date: 3/13/2022
; Description: Program obtains and prints user input, converting ASCII characters into numbers
;			   using two macros, and returns the numbers entered, their sum, and the truncated 
;			   average. Instructions are written to screen and input gathered by macros/procedures. 
;			   User is prompted to enter 10 signed decimals, which are gathered using a loop in 
;			   the main procedure. Input is verified to ensure number can fit into a 32-bit 
;			   register and contains no symbols or is blank. If invalid, a prompt is written 
;			   to the screen and user is instructed to keep entering numbers until 10 valid 
;			   integers are gathered. Once input has been gathered, the numbers are written to 
;			   the screen along with the sum and truncated average. At end of program a goodbye
;			   message is written to the screen. 


INCLUDE Irvine32.inc

; --------------------------------------------------------------------------
; Name: mDisplayString
;
; Given an address of a string, prints a string a string of characters using
;	the WriteString procedure.
;
; Preconditions: Input must be an address containing an array of characters
;
; Receives: chars	=	string input 
;
; Returns: A string of ASCII characters
; --------------------------------------------------------------------------

mDisplayString	 MACRO	 chars					; displays strings using WriteString method 
  PUSH		EDX 
  MOV		EDX, chars 
  CALL		WriteString 
  POP		EDX 
ENDM 


; --------------------------------------------------------------------------
; Name: mGetString
;
; Displays prompt and stores input into an address. Uses the WriteString and 
;	ReadString Irvine procedures to write prompt and store characters, 
;	respectively. Prompt, input, and size are passed by reference. Input 
;	count is passed by value. 
;
; Preconditions: None. 
; 
; Receives: chars	=	address of prompt to get user input  
;			input	=	address of input stored in memory location 
;			count	=	value for the length of the input 
;			size	=	address for number of bytes read by macro
;
; Returns: Prompt displayed to screen. 
; --------------------------------------------------------------------------

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
comma			BYTE		  ", ",0
sumTitle		BYTE		  "The sum of all numbers is: ",0
avgTitle		BYTE		  "The truncated average of all numbers is: ",0
goodbyeMsg		BYTE		  "Thank you and have a nice day!",13,10,0
inputNum		BYTE		  13 DUP (?)						  
outputArr		SDWORD		  10 DUP (?)
num2String		BYTE		  1 DUP (?)
sumTotal		SDWORD		  0
avgTotal		SDWORD		  0 
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
  CALL		CrLf 
				
  PUSH		OFFSET listTitle					; title of list 
  PUSH		OFFSET comma						; insert commas and spaces between nums 
  PUSH		OFFSET outputArr
  CALL		listOfNums 

  PUSH		OFFSET sumTitle
  PUSH		OFFSET outputArr
  PUSH		OFFSET sumTotal
  CALL		calcSum 

  PUSH		sumTotal 
  PUSH		OFFSET avgTitle 
  CALL		calcAvg

  mDisplayString OFFSET goodbyeMsg

  INVOKE	ExitProcess,0						 
main ENDP


;------------------------------------------------------------------------------
; Name: ReadVal 
;	Uses the mGetString macro to obtain user input as a string of digits.
;	If no valid input (I.E., nothing entered, number too large/small, or
;	input is not a number), error is displayed and user prompted to 
;	enter a valid integer. Input stored in an array of SDWORDs. 
;
; Preconditions: None
;
; Postconditions: None
;
; Receives: [EBP + 8]	=	counter, used to act as loop counter 
;			[EBP + 12]	=	EBX, contains address of output array of SDWORDs
;			[EBP + 16]	=	prompt, address of user input prompt 
;			[EBP + 20]	=	length of input number 
;			[EBP + 24]	=	invalidMsg, address of invalid message prompt
;			[EBP + 28]	=	inputNum, address of input number BYTE 
;
; Returns: None.
;------------------------------------------------------------------------------

ReadVal		PROC
  LOCAL		loopCounter:DWORD, signCount:DWORD         
  PUSH		ECX
  PUSH		ESI
  PUSH		EBX 
  PUSH		EDX		
  PUSH		EAX 

  mGetString  [EBP + 16], [EBP + 28], [EBP + 8], [EBP + 20]

; -----------------------------------------------------------------------------
; Outer loop iterates through user input, stored as array of BYTEs, and checks
;	to verify is input is valid. Input is checked if positive and negative and 
;   if valid, array of SDWORDs is converted in converToNum.
; -----------------------------------------------------------------------------
_outerLoop: 
  MOV		ESI, [EBP + 28]						; move character input array stored in InputNum to ESI 
  MOV		EBX, [EBP + 8]						 
  MOV		ECX, [EBX]							; move char count from EBX to ECX to act as loop counter 
  MOV		loopCounter, ECX					; local procedure variable used as loop counter 

  MOV		EAX, 0								; begins accumulator for convertToNum 
  MOV		ECX, 0								; this will initialize the holding number for our calculations 
  MOV		signCount, 0						; local procedure variable used to keep track of sign 

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
	  INC		signCount						; if sign count is set to 1 then negation is made in isNegative 

	_innerLoop:	
	  XOR		EAX, EAX						; clear EAX from previous calculation 
	  LODSB

	_signContinue:								; verifies if number is below 48 or above 57. If not, continue to convertToNum
	  CMP		AL, 48
	  JB		_invalidInput
	  CMP		AL, 57
	  JA		_invalidInput
	  JMP		_convertToNum					; if input is valid, then jump to conversion

	; ------------------------------------------------------------------------------------------
	; convertToNum completes the conversion by subtracting each representation by 48. This is 
	;	then stored in EBX and the next power of 10 is calculated, so that each time the character 
	;	is moved this is multiplied by that power of 10 and added to the accumulator. We check 
	;	with each iteration if the carry flag has been set, and if so the number is too large or
	;	small and it is invalid. Continues until loopCount is 0.  
	; ------------------------------------------------------------------------------------------
	_convertToNum:								
	  SUB		AL, 48							; subtract 48 to obtain number
	  MOV		EBX, EAX
	  MOV		EAX, ECX 
	  MOV		EDX, 10
	  MUL		EDX

	  JC		_invalidInput					; if carry flag is set input is too large

	  ADD		EAX, EBX
	  JC		_invalidInput					; if carry flag is set input is too large

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
  CMP		ECX, 7FFFFFFFH						; 0111 1111 1111 1111 1111 1111 1111 1111 = 7FFFFFFFH
  JA		_invalidInput
  JMP		_exitReadVal

_isNegative:
  CMP		ECX, 80000000H						; 1000 0000 0000 0000 0000 0000 0000 0000 = 80000000H
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

;-----------------------------------------------------------------------------
; Name: WriteVal 
;
; Converts user input, stored as an SDWORD, into a string of ASCII
;	characters. Uses the mDisplayString macro to display the SDWORD value to 
;	the output. Local space is reserved for output, which is iterated through 
;   beginning at the end of the SDWORD. 
;
; Preconditions: Valid user input stored in an array of SDWORDs.
;
; Postconditions: None. 
;
; Receives: [EBP + 8]	=  SDWORD value to be displayed  
;
; Returns: None. 
;-----------------------------------------------------------------------------
WriteVal	PROC 
  PUSH		EBP 
  MOV		EBP, ESP
  SUB		ESP, 12								; local space reserved for output, loads into EDI 
  PUSH		EAX
  PUSH		EBX
  PUSH		EDX 
  PUSH		EDI 
  PUSHFD 
  
  STD											; direction flag set to iterate starting at ending of SDWORD 	

  MOV		EDI, EBP							; load address of output into EDI
  DEC		EDI 
  XOR		EAX, EAX
  STOSB

  MOV		EBX, 10		

  MOV		EDX, [EBP + 8]						; loads element at SDWORD address to be divided in convert2Chars
  CMP		EDX, 0
  JS		_makeNeg
  JMP		_convertToChars 

_makeNeg: 
  NEG		EDX						

; ---------------------------------------------------------------------------------
; convertToChars begins conversion of number to ASCII output. Number is continually
;	divided by 10 until quotient is 0. If non-zero, 48 is added to AL to obtain
;   the ASCII character with each division. 
; ---------------------------------------------------------------------------------
_convertToChars: 
  MOV		EAX, EDX 
  XOR		EDX, EDX  
  DIV		EBX									; divide by 10 due to decimal/base-10 

  XCHG		EDX, EAX 
  ADD		AL, 48								; add 48 to remainder stored in EDX to get ASCII character  
  STOSB
  CMP		EDX, 0
  JNZ		_convertToChars						; if quotient != 0 keep looping 

  CMP		DWORD PTR [EBP + 8], 0
  JS		_isNeg
  JMP		_writeStr
  
_isNeg:  
  MOV		AL,'-'
  STOSB				 

_writeStr: 
  INC		EDI 
  mDisplayString EDI					  

  POPFD
  POP		EDI 
  POP		EDX
  POP		EBX
  POP		EAX
  MOV		ESP, EBP 
  POP		EBP 
  RET		4
WriteVal	ENDP 


;---------------------------------------------------------------------------------
; Procedure: listOfNums 
;
; Loops through the filled array of numbers in the SDWORD and prints all 10 
;	user-entered numbers. 
;
; Preconditions: the array contains only positive/negative values which can fit 
;	in a 32-bit SDWORD. 
;
; Postconditions: None. 
;
; Receives:		[EBP + 8]	=	address of SDWORD array of numbers
;				[EBP + 12]	=	address of comma and space to insert after number 
;				[EBP + 16]	=	address of title to be displayed 
;
; Returns: None. 
;---------------------------------------------------------------------------------
listOfNums	PROC
  PUSH		EBP
  MOV		EBP, ESP 
  PUSH		ECX							; ECX will be counter to loop through SDWORD of numbers
  PUSH		EAX							

  MOV		EAX, [EBP + 8]				; address of SDWORD array of numbers			
  MOV		ECX, 10						; loop though all 10 numbers 

  mDisplayString [EBP + 16]				; Writes title to screen 

loopNums: 
  PUSH		DWORD PTR [EAX]
  CALL		WriteVal					; Call WriteVal to convert each number 
  CMP		ECX, 1						; if last count print num and jump to end to avoid space and comma 
  JE		_finish 
  ADD		EAX, 4 
  mDisplayString [EBP + 12]				; Write comma and space after each number except for last 
  LOOP		loopNums

  CALL		CrLf

_finish: 
  POP		EAX 
  POP		ECX 
  POP		EBP 
  RET		12
listOfNums	ENDP


;---------------------------------------------------------------------------------------
; Name: calcSum 
;	Receives an array of SDWORDs and calculates the sum by iterating through the array 
;	and adding each number to the accumulator. Uses WriteVal to display number. 
;	mDisplayString macro is used to print the title. 
;
; Preconditions: Array of SDWORDs contains valid numbers 
;
; Postconditions: None. 
;
; Receives:			[EBP + 16]	=	address of sum title to be displayed
;					[EBP + 12]	=	address of outputArr where numbers are stored 
;					[EBP + 8]	=	address of sumTotal to be filled, passed to WriteVal
;
; Returns: sumTotal - the total sum of the array of numbers. 
;---------------------------------------------------------------------------------------

calcSum		PROC 
  PUSH		EBP 
  MOV		EBP, ESP 
  PUSH		ECX 
  PUSH		EAX 
  PUSH		EBX 
  PUSH		EDX 

  MOV		EBX, [EBP + 12]			; address of outputArr 
  MOV		EAX, [EBP + 8]			; address of sumTotal -- passed to WriteVal
  MOV		ECX, 10 
  XOR		EDX, EDX				; clears EDX to begin calculating sum 

  CALL		CrLf
  mDisplayString [EBP + 16]			; displays sum title 

_beginSum: 
  ADD		EDX, [EBX]
  ADD		EBX, 4 
  LOOP		_beginSum 

  MOV		[EAX], EDX 

  PUSH		EDX
  CALL		WriteVal				; address of SDWORD sum, BYTE, and minus sign are pushed and used by WriteVal
  CALL		CrLf

  POP		EDX 
  POP		EBX 
  POP		EAX
  POP		ECX
  POP		EBP 
  RET		12
calcSum		ENDP 


;----------------------------------------------------------------------------------------
; Name: calcAvg 
;	Calculates the average of all user-entered numbers by using the value from calcSum,
;	stored in sumTotal, and dividing by 10. Uses mDisplayString macro to display the 
;	title. WriteVal procedure is used to display the average. 
;
; Preconditions: sumTotal contains the sum used in the calcSum procedure - this is used 
;	to calculate the average. 
;
; Postconditions: None. 
;
; Receives:		[EBP + 8]	=	address of avgTitle -- title to be displayed 
;				[EBP + 12]	=	value of sumTotal, used to calculate average 
;
; Returns: value of average total. 
;----------------------------------------------------------------------------------------

calcAvg		PROC
  PUSH		EBP 
  MOV		EBP, ESP 
  PUSH		ECX
  PUSH		EDX
  PUSH		EAX

  MOV		ECX, 10 

  mDisplayString [EBP + 8]				; display average title 
  MOV		EAX, [EBP + 12]				; move value of sumTotal to EAX, to be divided by 10 (total numbers entered)
  CDQ		
  IDIV		ECX 

  PUSH		EAX
  CALL		WriteVal					; push EAX, containing the average, to be used by WriteVal
  CALL		CrLf 
  CALL		CrLf 

  POP		EAX
  POP		EDX 
  POP		ECX
  POP		EBP 
  RET		8
calcAvg		ENDP 
			
END main