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
  MOV		EDI, count 
  MOV		[EDI], EAX 
  POP		ECX 
  POP		EAX
  POP		EDX
ENDM 


.data
intro1		BYTE	 "Programming assignment 6: Designing low-level I/O procedures",13,10,
					 "Written by: Patrick Culley",13,10,13,10,0
intro2		BYTE	 "Please provide 10 signed decimal integers.",13,10,
					 "Each number needs to be small enough to fit inside a 32 bit register. After you have finished",13,10,
					 "inputting the raw numbers I will display a list of the integers, their sum, and their average",13,10, 
					 "value",13,10,13,10,0
prompt		BYTE	 "Please enter a signed integer: ",0
invalidMsg	BYTE	 "ERROR: You did not enter a signed number or your number was too big.",13,10,
					 "Please try again: ",0
inputNum	BYTE	  11 DUP (?)
counter		DWORD	  ? 
inputSize	DWORD	  11 


.code
main PROC
  mDisplayString	OFFSET intro1													; print intro1 to screen  
  mDisplayString	OFFSET intro2													; print intro2 to screen 

  PUSH		OFFSET invalidMsg
  PUSH		inputSize
  PUSH		OFFSET prompt 
  PUSH		OFFSET inputNum
  PUSH		OFFSET counter 
  CALL		ReadVal 

  INVOKE	ExitProcess,0																; exit to operating system
main ENDP


ReadVal		PROC
  PUSH		EBP 
  MOV		EBP, ESP 
  PUSH		ECX
  PUSH		ESI
  PUSH		EBX 
  PUSH		EAX 
  PUSH		EDX

  mGetString  [EBP + 16], [EBP + 12], [EBP + 8], [EBP + 20]
  PUSH		EBX 
  MOV		ESI, [EBP + 12]				; move character array to ESI 
  MOV		EBX, [EBP + 8]				 
  MOV		ECX, [EBX]					; move count of characters to ECX
  POP		EBX 

_loopChars:	
  LODSB														; compares if number is in-range from 48 to 57
  PUSH		EBX
  MOV		EBX, [EBP + 8]
  CMP		ECX, [EBX]										; compare counter to length
  JE		_checkSign										; compare if first char is negative 
  CMP		AL, 48
  JB		_invalidInput
  CMP		AL, 57
  JA		_invalidInput
  LOOP		_loopChars
  JMP		_theEnd 

_checkSign:
  POP		EBX
  CMP		AL, 45 
  JE		_changeSign 
  CMP		AL, 43 
  JE		_changeSign
  JMP		_invalidInput 

_changeSign: 
  LOOP		_loopChars


_invalidInput: 
  mGetString  [EBP + 24], [EBP + 12], [EBP + 8], [EBP + 20]
  PUSH		EBX 
  MOV		ESI, [EBP + 12]				; move character array to ESI 
  MOV		EBX, [EBP + 8]				 
  MOV		ECX, [EBX]					; move count of characters to ECX
  POP		EBX 
  JMP		_loopChars 


_theEnd:
  POP		EDX 
  POP		EAX 
  POP		EBX 
  POP		ESI 
  POP		ECX
  POP		EBP 
  RET  20
ReadVal		ENDP 




END main