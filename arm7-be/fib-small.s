	.text;				@ Store in ROM

Reset_Handler:
	.global Reset_Handler;	@ The entry point on reset
	
;	@ Pointers to the variables
	ldr r2, =var_a;
	ldr r3, =var_b;
	
;	@ Load a 64-bit 1 into both variables
	mov r12, #0;	@ Constant used for initializing the variables
	str r12, [r2, #0];	@ Set the value of var_a
	str r12, [r3, #0];	@ Set the value of var_b
	mov r12, #1;	@ Constant used for initializing LSW of variables
	str r12, [r2, #4];
	str r12, [r3, #4];
	
;	@ Counter to specify how many terms we want to calculate
	mov r4, #90

loop:
;	@ Add the least-significant word (LSW) from each variable
	ldr r0, [r2, #4];	@ Load the LSW of var_a	
	ldr r1, [r3, #4];	@ Load the LSW of var_b

;	@ We add the two words without carry for the LSW.
;	@ We add all other words using a carry.
;	@ We set the status register for subsequent operations
	adds r0, r0, r1;	@ Add lower word, set status register

	str r1, [r2, #4];	@ Move the LSW of var_b into the LSW of var_a
	str r0, [r3, #4];	@ Store the LSW result into the LSW of var_b

;	@ Add the most significant word (MSW) from each variable, with the carry.
	ldr r0, [r2, #0];	@ Load the MSW of var_a	
	ldr r1, [r3, #0];	@ Load the MSW of var_b

	adcs r0, r0, r1;	@ Add upper word using carry bit, set status register

	str r1, [r2, #0];	@ Move the MSR of var_b into the MSR of var_a
	str r0, [r3, #0];	@ Store the MSW result into the MSW of var_b

	subs r4, r4, #1;	@ Decrement the loop counter
	bne loop;			@ Have we reached the desired term yet?
		
	;@subs r4, r4, #1;	@ Decrement the loop counter (r4)
	;@bne loop;			@ Branch to "loop" if we haven't finished

done:
	b done;				@ Program done! Loop forever.
	
.data;					@ Store in RAM			
var_a:	.space 8;		@ Variable A (64-bit)
var_b:	.space 8;		@ Variable B (64-bit)

	.end;				@ End of program	
