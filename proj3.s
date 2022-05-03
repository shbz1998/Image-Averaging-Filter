			AREA PROJECT_2, CODE, Readonly
			ENTRY ;The first instruction to execute follows
			MOV r0, #0
			
row			EQU 16; number of row
ele			EQU 16; number of elements
eleNEW		EQU 196; number of elements in the 14x14 
preVAL		EQU 30
activate	EQU	40; to check if the hist is used for image averaging filter or not	
black		EQU 0
white		EQU 255
	
;address	    0     4     8     12    16    20    24    28    32    36    40     44     48     52    56      60
matrix		DCD row0, row1, row2, row3, row4, row5, row6, row7, row8, row9, row10, row11, row12, row13, row14, row15
value		DCD value1, value2, value3
	
		
			LDR r6, =row0 ;address of the row
			LDR r5, =matrix ;address of the matrix
hist		
			MOV r0, #0; number of pixels with 0s
			MOV r1, #0; number of pixels with 1s
			MOV r9, #row; row counter
			CMP r12, #activate; is this being used for the filtered image?
			MOVEQ r10, #eleNEW; if yes then total elements = 196 (14x14)
			MOVEQ r0, #preVAL; there will already by 30 0s
			MOVEQ r1, #preVAL; there will also be 30 1s because the filtered image is 14x14 and we are putting into the 16x16 matrix
			MOVEQ r5, #0; reserve r5 for GRAY color
			BLEQ loopB; if yes then directly move to loop B and start from there

;------------image histogram----------------;

loopA		;go through each row
			MOV r10, #ele; element counter
			LDR r2, [r5], #4; through each row
			
loopB		;go through each element in the row
			LDR r3, [r2], #4; through each element of the row
			CMP r3, #black; is value = 0?
			ADDEQ r0, r0, #1; if the value is 0, increment r0
			CMP r3, #white
			ADDEQ r1, r1, #1
			CMP r3, #black
			CMPNE r3, #white
			ADDNE r5, #1 ;when r3 is not equal to 0 and 255, we increment r5 which represents GRAY
			SUBS r10, r10, #1; decrement the counter
			BNE loopB; end loop
			CMP r12, #40
			BLEQ stop
			SUBS r9, r9, #1; decrement the counter
			BNE loopA

			CMP r12, #40; was the instruction called for image averaging filter?
			BLEQ stop; if yes then this is the last instruction/tast of the project, stop the program

			
;-------------image averaging filter----------;

			;multiply element by element;
rowB		EQU	3; number of rows in the image average filter
eleB		EQU 3; number of columns in the image averaging filter
index		EQU 16; starting	
	
			LDR r12, =0x40000060 ;starting address to store new answers at
			LDR r5, =matrix ;address of the matrix
			
			MOV r4, #0;counting row number 
			
loopMAJOR			
			
			MOV r9, #rowB; row counter
			LDR r1, =value1; address of that row in the kernel
			LDR r7, =value ;address for the kernel operation
			
			;[2D matrix * multiplying value];
			
			MOV r0, #0; sum accumulator
			MOV r10, #5; just an inital value for branching purposes

			MOV r11, #0; start from 0
	


loopE		;go through each possibility
			MOV r0, #0; sum accumulator

loopC		;go through each row
			MOV r10, #eleB; element counter=3
			LDR r2, [r5], #4; through each row
			LDR r3, [r7], #4; through each row of the value

loopD		;go through each element
			LDR r3, [r2, r11]; through each element of the row
			LDR r8, [r1],#4; through multiplying value
			MUL r8, r3, r8; multiply them
			ADD r0, r0, r8; add the answers
			ADD r11, r11, #4; move to next element
			SUBS r10, r10, #1; first element done, move to next element
			BNE loopD
			CMP r10, #0
			SUBEQ r11, r11, #12
			SUBS r9, r9, #1; move to next row 
			BNE loopC
			LSR r0, #4 ;divide our answer by 16
			STR r0, [r12]; store the answer at address
			
			;next possibility;
			ADD r11, r11, #4; next possibility
			ADD r12, r12, #4; next possiblity stored at new address
			MOV r9, #rowB
			SUB r5, r5, #12
			LDR r1, =value1; address of the kernel row
			LDR r7, =value ;address of the kernel matrix
			CMP r11, #56
			
			BNE loopE ;one entire row is complete
			;start from row 0 + x, where x is 1,2,3,4,5,6....15	
			ADD r5, r5, #4; next address
			ADD r4, r4, #1 ;counter
			CMP r4, #14
			BNE loopMAJOR
			
			LDR r2, =0x40000060 ;address where our starting value is stored at
			MOV r12, #activate ;this value indicates the histogram program that it is being used for image filtering values
			BL hist ;go to the histogram program


			

		
stop		B stop



;2D matrix
;address 0  4  8  12  16  20   24   28  32  36 40 44 48  52    56   60

	 
row0 DCD 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255	;0
row1 DCD 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255
row2 DCD 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255
row3 DCD 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255
	
row4 DCD 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0 
row5 DCD 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0
row6 DCD 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0
row7 DCD 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0
	
row8 DCD  0, 0, 0, 0, 255, 255, 255,  255, 0, 0, 0, 0, 255, 255, 255, 255	;0
row9 DCD  0, 0, 0, 0, 255, 255, 255,  255, 0, 0, 0, 0, 255, 255, 255, 255
row10 DCD 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255
row11 DCD 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255
	
row12 DCD 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0 
row13 DCD 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0
row14 DCD 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0
row15 DCD 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0

;kernel

value1 DCD 1, 2, 1 
value2 DCD 2, 4, 2
value3 DCD 1, 2, 1	
	
			END
			