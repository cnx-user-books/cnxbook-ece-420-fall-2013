	.ARMS_off					;enable assembler for ARMS=0
	.CPL_on						;enable assembler for CPL=1
	.mmregs						;enable mem mapped register names

	.global _filter
	.global _gBufferRcvL
	.global _gBufferXmt

	.copy "macro.asm"				; Copy in macro declaration

	.sect ".data"

FIR_len1	.set 20					; This is a 20-tap filter
BUFFSIZE	.set 64					; 64 samples in a unit

	.align 16						; Align to a multiple of 16
coef1								; assign label "coef1"
	.copy "coef.asm"				; Copy in coefficients



	.align 32			
firState1	.space 16*FIR_len1			; Allocate 20 words of storage for
									; filter state.

firState1Index						; Allocate storage to save index
	.word	0						; in firState

;	.copy "testvect.asm"

	.sect ".text2"

_filter

	ENTER_ASM					; Call macro. Prepares registers for assembly
	
	mov		#0, AC0				; Clears AC0 and XAR3
	mov		AC0, XAR3			; XAR3 needs to be cleared due to a bug

	mov		dbl (*(#_gBufferRcvL)), XAR6	; XAR6 contains address to input
	mov		#_gBufferXmt, AR7		; AR7 contains address to output

	bset		AR1LC				; sets circular addressing for AR1
	bset		AR2LC				; sets circular addressing for AR2

	mov		#firState1, AR2			; State pointer is in AR2
	mov		#firState1Index, AR4		; State index pointer is in AR4
	mov		mmap(AR2), BSA23		; BSA23 contains address of firState1
	mov		*AR4, AR2			; AR2 contains the index of oldest state
	
	mov		#coef1, AR1			; initialize coefficient pointer
	mov		#FIR_len1, BK03			; initialize circular buffer length for register 0-3

	mov		#BUFFSIZE-1, BRC0		; Save repeat count into block repeat counter
	rptb		endblock-1			; Repeat between here and 'endblock' label

	mov		*AR6+ << #16, AC0		; Receive ch1 into AC0 accumulator
	mov		AC0, AC1			; Transfer AC0 into AC1 for safekeeping
	
	mov		HI(AC0), *AR2+			; store current input into state buffer
	mov		#0, AC0				; Clear AC0
	rpt		#FIR_len1-1			; Repeat next instruction FIR_len1 times
	macm		*AR1+,*AR2+,AC0,AC0		; multiply coef. by state & accumulate
	round		AC0						; Round off value in 'AC0' to 16 bits  

	mov		HI(AC0), *AR7+			; Store filter output (from AC0) into ch1
	mov		HI(AC1), *AR7+			; Store saved input (from AC1) into ch2
	
	mov		HI(AC1), *AR7+			; Store saved input (from AC1) into ch3
	mov		HI(AC1), *AR7+			; Store saved input (from AC1) into ch4
	mov		HI(AC1), *AR7+			; Store saved input (from AC1) into ch5
	mov		HI(AC1), *AR7+			; Store saved input (from AC1) into ch6
endblock:

	mov		AR2, *AR4			; Save the index of the latest state back into firState1Index

	LEAVE_ASM					; Call macro to restore registers

	RET
	