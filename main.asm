include "constants.asm"
include "task.asm"
include "longcalc.asm"


Section "Core Stack", WRAM0

CoreStackBase::
	ds CORE_STACK_SIZE


Section "Temp Stacks", WRAM0

TempStack1:
	ds CORE_STACK_SIZE
TempStack2:
	ds CORE_STACK_SIZE


Section "Core Functions", ROM0


; Temporary code for testing task switching
Start::
	TaskNewHelper 0, TempStack1, Task1
	TaskNewHelper TASK_SIZE, TempStack2, Task2
	jp SchedLoadNext ; does not return


Task1::
	ld A, 1
	ld B, 2
	ld C, 3
	ld D, 4
	ld E, 5
	ld HL, $face
.loop
	inc A
	call z, T_TaskYield
	jp .loop


Task2::
	ld B, 10
	call Fib
.loop
	jp .loop

; return Bth fibbonacci number in DE
; clobbers A
Fib:
	ld A, B
	cp 2
	jr nc, .noUnderflow
	ld D, 0
	ld E, 1
	ret ; return 1
.noUnderflow
	dec B
	call Fib ; DE = Fib(n-1)
	dec B
	push DE
	call Fib ; DE = Fib(n-2)
	ld H, D
	ld L, E
	pop DE
	LongAdd D,E, H,L, D,E ; DE += HL, ie. DE = Fib(n-1) + Fib(n-2)
	inc B
	inc B ; return B to initial value
	call T_TaskYield ; demonstrate yielding. Fib(B) should equal DE.
	ret