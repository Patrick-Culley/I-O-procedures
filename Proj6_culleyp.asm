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

mGetString		 MACRO	 chars					; prints prompt to user and gathers integer 
  PUSH		EDX 
  PUSH		EAX 
  mDisplayString	chars
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
prompt		BYTE	 "Please enter a signed integer: ",13,10


.code
main PROC
  mDisplayString	OFFSET intro1				; print intro1 to screen 
  
  mDisplayString	OFFSET intro2				; print intro2 to screen 

  mGetString		OFFSET prompt				; print prompt and read/store user-entered integer 

  INVOKE ExitProcess,0							; exit to operating system
main ENDP


END main