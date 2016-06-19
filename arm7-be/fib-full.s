 .text; @ Store in ROM
 
Reset_Handler:
 .global Reset_Handler; @ The entry point on reset
 
 /* testingloop:
	ldr sp, =#0x40004000; @ Initialize SP just past the end of RAM
	ldr r11, =TestTable; 
	mov r10, #0; 
	ldr r0, [r11,r10];
	cmp r0, #0xFFFFFFFF;
	beq actuallydone; */
; @ The main program
main:
	
	//ldr r0, [r11, r10]; @ Load value of N into first argument
	mov r0, #100; //For testing purposes.
	mov r1, #0; 
	cmp r0, r1;@ checks if N is 0
	beq n_is_0;
	mov r1, #1;@ checks if N is 1
	cmp r0, r1;
	beq n_is_1;
	mov r1, #2;@ checks if N is 2
	cmp r0, r1;
	beq n_is_2;
	
	
	bl sub_fib; @ Find Nth value of the Fibonacci sequence
stop:
	b checkresults;
	;@ ...
	
n_is_0:
	ldr r5, =var_n;

	;	@ Pointers to the variables
	ldr r2, =var_a;
	ldr r3, =var_b;
	
	mov r12, #0
	str r12, [r5, #0];
	str r12, [r2, #12];
	str r12, [r3, #12];
	b checkresults;
	
n_is_1:
	ldr r5, =var_n;

	;	@ Pointers to the variables
	ldr r2, =var_a;
	ldr r3, =var_b;
	
	str r0, [r5, #0];
	mov r12, #0;
	str r12, [r2, #12];
	mov r12, #1
	str r12, [r3, #12];
	b checkresults;
	
n_is_2:
	ldr r5, =var_n;

	;	@ Pointers to the variables
	ldr r2, =var_a;
	ldr r3, =var_b;
	
	str r0, [r5, #0];
	mov r12, #1
	str r12, [r2, #12];
	str r12, [r3, #12];
	b checkresults;

sub_fib:
	push {r4-r5} ;@<Store registers and LR to stack>
	push {LR};
	;@ ...
	;@ <128-bit Fibonacci Algorithm from Lab 3>
	
	mov r4, r0; @ bring the N value into R4 where it is used by the algorithm.
	ldr r5, =var_n;

	;	@ Pointers to the variables
	ldr r2, =var_a;
	ldr r3, =var_b;
	
;	@ Load a 128-bit 1 into both variables
	mov r12, #0;	@ Constant used for initializing the variables
	str r12, [r2, #0];	@ Set the value of var_a
	str r12, [r3, #0];	@ Set the value of var_b
	str r12, [R5, #0];  @ set the value of var_n
;	@ Complete the initialization for var_a and var_b

	mov r12, #1;	@ Constant used for initializing LSW of variables
	str r12, [r2, #12];
	str r12, [r3, #12];
	mov r12, #2;
	str r12, [r5, #0];
	sub R4, R4, #2;
	push {LR};

loop:	
	
	bl add_128;			@ Perform a 128-bit add
	BCS overflow;		@ Detect if our variable overflowed by looking
;						@ at the carry flag after the top word add
;						@ If so, branch to "overflow"
	ldr R6, [R5]
	ADD R6, R6,#1; 		@ increment counter for Var_n
	str R6, [R5, #0];	@ Store Var_n
	SUBS R4, R4, #1;	@ Decrement the loop counter 
	BNE loop;		@ Have we reached the desired term yet?

done:
	@ algorithm done
	pop {PC};
	pop {r4-r5} ;@ <Restore registers, and load LR into SP>


overflow:
	b overflow;
	//b checkresults;			@ Oops, the add overflowed the variable!
	
	; @ Subroutine to load two words from the variables into memory
add_128:	
	
;	@ Start with the least significant word (word 0)
;	@ We add the two words without carry for the LSW.
;	@ We add all other words using a carry.
;	@ We set the status register for subsequent operations
	push {LR};
	mov r1, #12;
	bl load_var	
;	@ 32-bit add
	adds r0, r0, r1;	@ Add word 0, set status register
	mov r1, #12;
	bl store_var

	/*mov r1, #12;
	bl load_var	
;	@ 32-bit add
	adcs r0, r0, r1;	@ Add word 2 with carry, set status register
	mov r1, #12;
	
	bl store_var
; 	@ Complete the 128-bit add */

; 	@ What issue do we have returning from the subroutine? How can we fix it?
	pop {PC};		@ Return from subroutine

; 	@ Subroutine to load two words from the variables into memory
load_var:
; 	@ Update this subroutine to take an argument so it can
; 	@ be reused for loading all four words
	ldr r0, [r2, #12];	@ Load the value of var_a
	ldr r1, [r3, #12];	@ Load the value of var_b
	mov PC, LR;		@ Return from subroutine

; 	@ Subroutine to shift move var_b into var_a and store
; 	@ the result of the add.
store_var:
; 	@ Update this subroutine to take an argument so it can
; 	@ be reused for storing all four words
	ldr	r12,[r3, r1];   @ Move var_b ...
	str	r12,[r2, r1];	@    ... into var_a
	str r0, [r3, r1];	@ Store the result into var_b
	mov pc, lr;		@ Return from subroutine
		


checkresults:

	push {R12};
	ldr R12, =var_a;
	mov r7, #0;
	add r10, #4; @ increments the r10 counter to next memory value (calculated n). 
	ldr r9, [r11, r10]; @loads the value into r9
	ldr r8, [r5, #12]; @loads the correct result of n into r8
	cmp r9, r8;
	movne r7, #1;
	add r10, #8; @ increments the r10 counter to next memory value (fib msw). 
	ldr r9, [r11, r10]; @loads the value into r9
	ldr r8, [r5, #8]; @loads the correct result of n into r8
	cmp r9, r8;
	movne r7, #1;
	add r10, #4; @ increments the r10 counter to next memory value (fib lsw). 
	ldr r9, [r11, r10]; @loads the value into r9
	ldr r8, [r5, #12]; @loads the correct result of n into r8
	cmp r9, r8;
	movne r7, #1;
	
	pop {R12};
	add r10, #4;
	ldr r0, [r11,r10];
	cmp r0, #0xFFFFFFFF;
	beq actuallydone;
	ldr R4, =main;
	mov PC, R4;
	
	

actuallydone: 
	ldr R12, =var_b;
	b actuallydone; @ it's actually done at this point. Loop forever.
	
	;@ ...

	;@ ...
	.data
var_n: .space 4;@ 1 word/32 bits
var_a: .space 16;@ (512 for) 128 words/4096 bits
var_b: .space 16;@ (512 for) 128 words/4096 bits 

;@ Testing parameters format 1
TestTable:
;@                   nin,nout,  of, fib msw,     fib lsw        ;@ test number
            .word    5,    5,    0, 0,             5            ;@ 1
            .word    1,    1,    0, 0,             1            ;@ 2
            .word    0,    0,    0, 0,             0            ;@ 3
            .word    2,    2,    0, 0,             1            ;@ 4
            .word    90,  90,    0, 0,             0xA1BA7878    ;@ 5
            .word  175,  175,    0, 0x014219F1,    0x792930BD    ;@ 6
            .word 1000,  186,    1, 0x9523A14F,    0x1AAB3E85    ;@ 7
            .word    0xFFFFFFFF                            ;@ mark end of table
			
Testresults: .space 28;@ 7tests *4btyes = 28 needed to store test results.  