 ;@============================================================================
;@
;@ Student Name 1: Isaac Cheng Hui Tan
;@ Student 1 #: 301247997
;@ Student 1 userid (email): isaact@sfu.ca
;@
;@ Student Name 2: Dayton Pukanich
;@ Student 2 #: 301252869
;@ Student 2 userid (email): dpukanic@sfu.ca
;@
;@ Below, edit to list any people who helped you with the code in this file,
;@      or put ‘none’ if nobody helped (the two of) you.
;@
;@ Helpers: _everybody helped us/me with the assignment (list names or put ‘none’)__
;@			Zhen,
;@			BC Liquor
;@			The water fountain outside the lab
;@ Also, reference resources beyond the course textbooks and the course pages on Canvas
;@ that you used in making your submission.
;@
;@ Resources:  ___________
;@
;@% Instructions:
;@ * Put your name(s), student number(s), userid(s) in the above section.
;@ * Edit the "Helpers" line and "Resources" line.
;@ * Your group name should be "<userid1>_<userid2>" (eg. stu1_stu2)
;@ * Form groups as described at:  https://courses.cs.sfu.ca/docs/students
;@ * Submit your file to courses.cs.sfu.ca
;@
;@ Name        : fib-full.s
;@ Description : Submission for Assignment 1.
;@============================================================================

.text; @ Store in ROM
 
Reset_Handler:
 .global Reset_Handler; @ The entry point on reset
 
testing_initialisation:
	ldr sp, =#0x40004000; // Initialize SP just past the end of RAM
	ldr r11, =TestTable; // Test the TestTable
	ldr r10, =test_offset;
	ldr r10, [r10, #0];
	mov r10, #0; 
	ldr r0, [r11,r10];
	cmp r0, #0xFFFFFFFF;
	beq done_testing; 

init:
	mov r0, #128; // Number of words to wipe. (PARAMETER)
	ldr r1, =var_a ;
	ldr r2, =var_b ; 
	mov r3, #0; // Offset, increases by 4
	mov r4, #0; // Set N value to 0
	mov r5, #0; // Store 0;

main:
	// Used to clear and initialize memory
	str r5, [r1, r3]; 
	str r5, [r2, r3];
	add r4, #1;
	add r3, #4;
	cmp r0, r4;
	bne main;
	
	str r5, [r2, r3];

	mov r0, #1; // Initialises the number of words to 1
	ldr r1, =var_numberofwords; //get the pointer to the variable number of words.
	str r0, [r1, #0]; // Initialsises the number of words to 0
	push {r8-r11};
	ldr R9, =test_offset;
	ldr R8, [R9,#0];
	ldr R11, =TestTable;
	ldr R10, [R11, R8];
	mov r0, R10; // Load value of N into first argument
	pop {R8 -R11};

	// Checks for non-standard test cases
	mov r1, #0; 
	cmp r0, r1; 
	beq n_is_0;
	mov r1, #1; 
	cmp r0, r1;
	beq n_is_1;
	mov r1, #2; 
	cmp r0, r1;
	beq n_is_2;
	
	bl sub_fib; // Find Nth value of the Fibonacci sequence

done: // Done for when overflow does not occur
	b checkresults; 
	
done_overflow: // For when overflow occurs 
	push {R0-R1};
	ldr R0, =var_n;
	ldr R1 , [R0,#0];
	//sub R1, R1, #1;
	str R1, [R0,#0];
	ldr R0, =flag_overflow;
	ldr R1 , [R0,#0];
	mov R1, #1;
	str R1, [R0,#0];
	ldr R0, =var_numberofwords;
	ldr R1, [R0, #0];
	sub R1, R1, #1;
	str R1, [R0, #0];
	pop {R0-R1};	
	b done;	
	
done_testing: // Fully done testing
	b done_testing; @
	
n_is_0:
	ldr r5, =var_n;
	ldr r2, =var_a;
	ldr r3, =var_b;
	
	mov r12, #0
	str r12, [r5, #0];
	str r12, [r2, #0];
	str r12, [r3, #0];
	b done; 
	
n_is_1:
	ldr r5, =var_n;
	ldr r2, =var_a;
	ldr r3, =var_b;
	
	str r0, [r5, #0];
	mov r12, #0;
	str r12, [r2, #0];
	mov r12, #1
	str r12, [r3, #0];
	b done; 
	
n_is_2:
	ldr r5, =var_n;
	ldr r2, =var_a;
	ldr r3, =var_b;
	
	str r0, [r5, #0];
	mov r12, #1
	str r12, [r2, #0];
	str r12, [r3, #0];
	b done; 

sub_fib:
	push {r4-r5} ;
	push {LR};
	
	// <128-bit Fibonacci Algorithm from Lab 3>
	mov r4, r0; @ bring the N value into R4 where it is used by the algorithm.
	ldr r5, =var_n;
	ldr r2, =var_a;
	ldr r3, =var_b;
	
	// Load a 128-bit 1 into both variables
	mov r12, #0; // Constant used for initializing the variables
	str r12, [r2, #0]; // Set the value of var_a
	str r12, [r3, #0]; // Set the value of var_b
	str r12, [R5, #0]; // Set the value of var_n

	mov r12, #1; // Constant used for initializing LSW of variables
	str r12, [r2, #0];
	str r12, [r3, #0];
	mov r12, #2;
	str r12, [r5, #0];
	sub R4, R4, #2;
	push {LR};
	
add_4096:
	ldr R6, =var_numberofwords; 
	ldr R7, [R6, #0]; // Actual number of words.
	mov R5, #0 ; // R5 is the current offset.
	push {R8 - R9}; // Resets the flag overflow.
	ldr R8 , =flag_overflow;
	ldr R9, [R8, #0];
	mov R9, #0;
	str R9, [R8, #0];
	pop {r8 - r9}
	mov R8, #0; // Resets the overflow.
	
add_arbit:
	bl add_32; // Perform a 32-bit add
	BLCS overflow; // Detect if our variable overflowed
	add R5, R5, #4;  // Increment the offset for the next word
	subs R7, R7, #1; // Decrement the number of words left to process counter
	BNE add_arbit; // Repeat for all words
	
	push {r5-r6};
	ldr R5, =var_n;
	ldr R6, [R5]
	ADD R6, R6,#1; // Increment counter for Var_n
	str R6, [R5, #0]; // Store Var_n
	pop {R5-r6};
	SUBS R4, R4, #1; // Decrement the loop counter 
	BNE add_4096; // Have we reached the desired term of N yet?
	b done;

add_32:	
	push {LR};
	push {r4};
	push {R0-R1};
	ldr R0, =var_numberofwords;
	ldr R1, [R0, #0]; // Load the value for number of words requied 
	cmp R1, #129; // Load maximum number of words (PARAMETER);
	beq done_overflow;
	pop {R0-R1};
	
	mov r4, R5; // Sets the offset to 0 for little endian.
	bl load_var	
	pop {r4};
	push {R4-R5};
	ldr R4, =flag_overflow;
	ldr R5, [R4, #0];
	cmp R5, #1
	ADDEQ R0, R0, #1;
	mov R5, #0;
	str R5, [R4,#0];
	pop {R4 -R5};
	adds r0, r0, r1; // Add word 0, set status register
	mov r1, R5;  // Sets the offset to 0 for little endian
	bl store_var
	pop {PC};		

overflow: // Increments the number of words, adds 1 to the next word in front of it.
	push {LR};
	push {R0-R3};
	
	ldr R0, =var_numberofwords;
	ldr R1, [R0, #0]; // Load the value for number of words requied 
	mov r2, #129; // Load maximum number of words for (PARAMETER)
	cmp r2, r1;
	beq done;
	cmp R7, #1;
	bleq largest_overflow;
	
	push {R0-R1};
	ldr R0, =flag_overflow; // Pointer to the overflow flag
	ldr R1, [R0, #0]; // Get the overflow flag
	mov R1, #1; // Set overflow flag = 1;
	str R1, [R0, #0]; // Store overflow flag to memory
	pop {R0 - R1};
	pop {R0-R3};
	pop {PC}; 

largest_overflow:
	push {LR};
	ADD R1, R1, #1; // Incredment the counter for number of words by one
	str R1, [R0,#0]; // Store that back into memory
	push {R0-R1}; 
	ldr R0, =var_b;
	push {R5}; // Saves the actual offset
	add R5, R5, #4; // Increments the offset to the next word
	ldr R1, [R0, R5]; // Loads R1 which is the value of the next word.
	add R1, R1, #1; // Add one to the next word ahead
	str R1, [R0, R5];
	pop {R5}; // Restores the actual offset
	pop {R0 - R1} 
	pop {PC};

load_var: // Inputs: R2 - var_a, R3 - var_b, R4 - offset. Outputs: R0 - var_a, R1 - var_b.
	ldr r0, [r2, R4]; // Load the value of var_a
	ldr r1, [r3, R4]; // Load the value of var_b
	mov PC, LR;		@ Return from subroutine
	
store_var: // R1 is the offset, R3 is pointer to var_b, R2 is pointer to var_a, R0 is the new var_b
	ldr	r12,[r3, r1]; // Move var_b ...
	str	r12,[r2, r1]; // ... into var_a
	str r0, [r3, r1]; // Store the result into var_b
	mov pc, lr;	// Return from subroutine

checkresults:
  	push {R0 - R12};
	mov R4, #0; // R4 counts the number of wrong answers and stores them in memory.
	ldr R8, =TestTable;
	ldr R5, =test_offset
	ldr R9, [R5, #0];
	add R9, #4;
	
	ldr R10, [R8,R9]; // Loads in TestTable var_n
	ldr R7, =var_n;
	ldr R6, [R7, #0]; // Loads in calc var_n
	cmp R6, R10;
	addne R4, #1;
	
	add R9, #4;
	ldr R10, [R8,R9]; // Loads in TestTable overflow
	ldr R7, =flag_overflow;
	ldr R6, [R7, #0]; // Loads in calc overflow
	cmp R6, R10;
	addne R4, #1;
	
	add R9, #4;
	ldr R10, [R8,R9]; // Loads in TestTable msw
	ldr R7, =var_b;
	ldr R1, =var_numberofwords;
	mov R2, #4;
	ldr R1, [R1,#0];
	sub R1, R1, #1;
	mul R3, R1, R2;
	ldr R6, [R7, R3]; // Loads in calculated msw
	cmp R6, R10;
	addne R4, #1;
	
	add R9, #4;
	ldr R10, [R8,R9]; // Loads in TestTable lsw
	ldr R7, =var_b;
	ldr R6, [R7, #0]; // Loads in calc lsw
	cmp R6, R10;
	addne R4, #1;
	
	ldr R1, =test_number; // Load test number
	ldr R2, [R1,#0];
	ldr R3, =Testresults; // Store test results
	str R4, [R3,R2];
	add R2, R2, #4; // Add 1 to test number
	str R2, [R1, #0]; 
	
	add r9, #4; // Offset the offset for TestTable.
	ldr r0, [r8,r9];
	
	cmp r0, #0xFFFFFFFF;
	beq done_testing;
	
	str r9, [R5,#0];
	pop {R0 - R12};
	b init;

	.data
	
var_n: .space 4;@ 1 word/32 bits (PARAMETER FOR CHANGE OF BITS)
var_a: .space 512;@ (512 for) 128 words/4096 bits
var_b: .space 516;@ (516 for) 128 words/4096 bits cause I need that extra word. 
var_numberofwords: .space 4; @ Max 512 words for 4096 bits.
flag_overflow: .space 4; //flag for overflowing variable.
test_n: .word  20;
test_offset: .word 0;
test_number: .word 0;
TestTable: 
//                  nin,nout,  of, fib msw,     fib lsw        
            .word    5,    5,    0, 5,             5           
            .word    1,    1,    0, 1,             1            
            .word    0,    0,    0, 0,             0         
            .word    2,    2,    0, 1,             1            
            .word    90,  90,    0, 0x27F80DDA,	   0xA1BA7878    
			.word  175,  175,    0, 0x014219F1,    0x792930BD   
            .word 1000, 1000,    0, 0x0021D8CB,    0x5CC0604B   
			.word 5901, 5901,	 0, 0xbcc7e2fa,	   0x1f2b5a82
			.word 5902, 5902, 	 1, 0x317429C5,	   0x38EA491F
			.word 6000, 5902,	 1, 0x317429C5,    0x38EA491F
            .word 0xFFFFFFFF                           

Testresults: .space 10;@ 7tests *4btyes = 28 needed to store test results.  