//CPSC 355 Assignment 6
//By: Evan Wheeler
//Student#: 30046173


								//Buffer will have 64bits of space (8 bytes)
								//The offset for the buffer in ram (just under fp and lr)
					//Alloctes space for fp, lr, and the buffer
							//How much to deallocate when main is done
//Registers
								//file descriptor register
								//pathname register
							//An x register to store the base address for the buffer
							//A register to hold the input value in main

	.balign 4								//Word alligns the .text section
	.global main								//Makes main visible globaly
main:										//Entrypoint for main
	stp	x29, x30, [sp, -(16 + 8) & -16]!					//Allocates ram for the main routine
	mov	x29, sp								//Moves a copy of sp into x29

	ldr	x19, [x1, 8]							//Moves the file name into x19
	add	x21, x29, 16					//Sets up the buffer base address

	cmp w0, 2								//Checks if the right number of args are supplied
	b.ne	mainError							//If there are not 2 args supplied then branch to the error code

	ldr	x20, [x1, 8]							//Loads the pathname into its register


//Opening the File
	mov	w0, -100			//-100 because it is in the same directory
	mov	x1, x20			//Pathname as second arg
	mov	w2, 0				//Read only  access
	mov	w3, 0				//No 4th arg
	mov	x8,	56			//openat request
	svc	0				//Call svc

	mov	w19, w0			//Puts fd into its register
	cmp	w19, -1			//Checks if everything is okay with the open
	b.eq	mainError			//branches to error if it does not open properly


	ldr	x0, =tableHeadString		//Move the head of the table string into x0
	bl	printf				//Print the head of the table

mainReadLoop:
	mov	w0, w19			//fd into w0
	mov	x1, x21		//Buffer into x1
	mov	x2, 8			//The size of the buffer into x2
	mov	x8, 63				//Read request
	svc	0				//Call svc

	cmp	x0, 8			//Checks if the right # of bytes were read
	b.ne	mainCloseFile			//Branch to close the file if the wrong # if bytes were read

	ldr	x22, [x21]	//Loads the buffer into x9
	fmov	d0, x22			//Moves the buffer (as a floating point) into d0

	bl	newtonMethod			//Calls the method to find the cube root given a double in d0

	ldr	x0, =cubeRootString		//Loads the formatted string to print into x0
	fmov	d1, d0				//The cube root returned is moved into d1
	fmov	d0, x22			//Moves the input into d0
	bl	printf				//Calls printf

	b	mainReadLoop			//Branch to the top of the loop, if it gets here then there was no error reading the file so it will try to read another line

	b	mainError			//The code should never get here



mainCloseFile:					//Closes the file
	mov 	w0, w19			//Moves file descriptor into w0
	mov	x8, 57				//Close request
	svc 	0				//Calls svc
	b	mainDone			//Branches over the error code to exit the program

mainError:					//Gets here if the # of terms are wrong or if the file doesn't open
	ldr	x0, =errorString		//Loads a string stating that there is an error
	bl	printf				//Calls printf

mainDone:					//The end of the main routine
	mov	w0, wzr				//Moves 0 into w0 to return
	ldp	x29, x30, [sp], --(16 + 8) & -16	//Deallocates ram for main
	ret					//Return call for main


//-----------------------------------------------------
						//Defining a register to hold x
						//Defining a register to hold y
					//Defining a register to hold the input as a double
						//Defining a register to hold dy
						//Defining a register to hold dy/dx
					//How much to allocate for the newtonMethod subroutine
			//How much to deallocate from ram when newtonMethod is done
newtonMethod:							//Entry point for newtonMethod, a double must be suplied in d0 and the cube root of that double will be returned in d0 as output
	stp	x29, x30, [sp, -16]!		//Allocating space in ram for newtonMethod
	mov	x29, sp						//Copying sp into x29

	fmov	d18, d0				//copy input into it's register

	adrp	x9, inputNumber	 				//Movs the address of the double 1.0e-10 from the .data section
	add	x9, x9,:lo12:inputNumber			//Gets the low 12 bits of the number
	ldr	d31, [x9]					//Moves 1.0e-10 into d31

	fmul	d31, d18, d31				//d31 = input * 1.0e-10 

	fmov	d29, 3.0					//Moves 3.0 into d29
	fdiv	d16, d18, d29				//Start with x=input/3.0

newtonMethodLoop:						//The top of the loop
	fmul	d17, d16, d16					//y = x*x
	fmul	d17, d17, d16					//y = y*x
	fsub	d19, d17, d18			//dy = y - input
	fmul	d20, d29, d16				//dy/dx = 3.0*x
	fmul	d20, d20, d16			//dy/dx = 3.0*x*x

	fdiv	d30, d19, d20				//d30 = dy / (dyOverDx)
	fsub	d16, d16, d30					//x = x-d30

newtonMethodTest:
	fabs	d30, d19					//Gets the absolute value of dy
	fcmp	d30, d31					//Compares |dy| and input*10e-10
	b.ge	newtonMethodLoop				//If dy is not small enough continue looping

newtonMethodLoopDone:						//Done the loop if the code falls through to here
	fmov	d0, d16						//Moves x into d0 to return

newtonMethodDone:						//The end of the newtonMethod Subroutine
	ldp	x29, x30, [sp], --16		//Deallocates memory from ram
	ret							//Return call for newtonMethod


errorString: .string "You have supplied the wrong number of terms or the file does not open. Usage a6 filename\n"	//The string that will be printed if there is an error wiith the input
cubeRootString: .string "%.10f\t%.10f\n"		//The string to print out the table,"input \t  cube root"
tableHeadString: .string "Input\t\tCube Root\n"		//The header that will be printed before displaying the table
	.data
inputNumber: .double 0r1.0e-10				//Storing 1.0e-10 to be used in the newtonMethod subroutine

