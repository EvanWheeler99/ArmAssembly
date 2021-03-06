//Assignment 5b
//Takes in 2 args from the command line and reports the corresponding season
//By: Evan Wheeler
//Student#: 30046173

	define(TRUE, 1)						//Defines TRUE as 1
	define(FALSE, 0)					//Defines FALSE as 0

	.text
errorString_m:	.asciz "usage: a5b mm dd\n"			//The string that will be printed if the arguments are invalid
stringFormat:	.string "%s %s is %s.\n"			//The format of the string to print out.
//Making the Month Array, An array of strings for all of the months
	.text
jan_m:	.string	"January"
feb_m:	.string	"February"
mar_m:	.string	"March"
apr_m:	.string	"April"
may_m:	.string	"May"
jun_m:	.string	"June"
jul_m:	.string	"July"
aug_m:	.string	"August"
sep_m:	.string	"September"
oct_m:	.string	"October"
nov_m:	.string	"November"
dec_m:	.string	"December"

	.data
	.global	monthArray_m		//Maknig the array of month strings accessible globaly, the error string in [0] to make indexing into the array easier
monthArray_m:	.dword	errorString_m, jan_m, feb_m, mar_m, apr_m, may_m, jun_m, jul_m, aug_m, sep_m, oct_m, nov_m, dec_m

//Making the Season Array, these are the strings that will be printed out to the screen
	.text
win_m:	.string	"winter"
spr_m:	.string	"spring"
sum_m:	.string	"summer"
fal_m:	.string	"fall"

	.data
	.global	seasonArray_m		//Making the array of season strings accessible globaly
seasonArray_m:	.dword	win_m, spr_m, sum_m, fal_m

//Making the array of the dates, this way I will not have to do more checks to determine weather to put "st", "nd", or "th" after the day
	.text
day1_m:	.string	"1st"
day2_m:	.string	"2nd"
day3_m:	.string	"3rd"
day4_m:	.string	"4th"
day5_m:	.string	"5th"
day6_m:	.string	"6th"
day7_m:	.string	"7th"
day8_m:	.string	"8th"
day9_m:	.string	"9th"
day10_m:	.string	"10th"
day11_m:	.string	"11th"
day12_m:	.string	"12th"
day13_m:	.string	"13th"
day14_m:	.string	"14th"
day15_m:	.string	"15th"
day16_m:	.string	"16th"
day17_m:	.string	"17th"
day18_m:	.string	"18th"
day19_m:	.string	"19th"
day20_m:	.string	"20th"
day21_m:	.string	"21st"
day22_m:	.string	"22nd"
day23_m:	.string	"23rd"
day24_m:	.string	"24th"
day25_m:	.string	"25th"
day26_m:	.string	"26th"
day27_m:	.string	"27th"
day28_m:	.string	"28th"
day29_m:	.string	"29th"
day30_m:	.string	"30th"
day31_m:	.string	"31st"

	.data
	.global	dayArray_m				//Making the array of day strings available globally, errorString is in[0] to make indexing easier
dayArray_m:	.dword	errorString_m, day1_m, day2_m, day3_m, day4_m, day5_m, day6_m, day7_m, day8_m, day9_m, day10_m, day11_m, day12_m, day13_m, day14_m, day15_m, day16_m, day17_m, day18_m, day19_m, day20_m, day21_m, day22_m, day23_m, day24_m, day25_m, day26_m, day27_m, day28_m, day29_m, day30_m, day31_m

//----------------------------------------------------------------------------
//The Main routine
	define(mainAlloc, -16)				//How much space to allocate for main	
	define(mainDealloc, -mainAlloc)			//How much space to deallocate
	define(mainDay_r, w19)				//Naming a register that will hold the day
	define(mainMonth_r, w20)			//Naming a register that will hold the month
	.text
	.balign 4					//Alligning memory (word alligned)
	.global	main
main:
	stp	x29, x30, [sp, mainAlloc]!		//Allocating a stack frame for main
	mov	x29, sp					//Move sp into x29

//# of args is in w0
//The array of args is in x1
	bl	errorCheck				//Branches to the error checking subroutine
	cmp	w0, FALSE				//Checks if there is an error
	b.eq	mainError				//Branches to the a section in main for when there is an error
	mov	mainMonth_r, w1				//Moves the month (as an int) into it's register
	mov	mainDay_r, w2				//Moves the day (as an int) into it's register

	mov	w0, mainMonth_r				//Setting up month for printDate
	mov	w1, mainDay_r				//Setting up day for printDate

//Going through all of the months to determine the season.
mainJan:
	cmp	mainMonth_r, 1				//Checks if month is January
	b.eq	mainWinter				//If it is the season is winter

mainFeb:
	cmp	mainMonth_r, 2				//Checks if month is February
	b.eq mainWinter					//If it is the season is winter

mainMar:
	cmp	mainMonth_r, 3				//Checks  if month is March
	b.ne	mainApr					//If not go to the check for April
	cmp	mainDay_r, 21				//Checks if the day is before or after 21
	b.lt	mainWinter				//If day < 21 it is winter
	b	mainSpring				//If day >= 21 it is Spring

mainApr:
	cmp	mainMonth_r, 4				//Checks to see if the month is April
	b.eq	mainSpring				//If it is the season is Spring

mainMay:
	cmp	mainMonth_r, 5				//Check to see if theh month is may
	b.eq	mainSpring				//May is in the spring

mainJun:
	cmp	mainMonth_r, 6				//Checks if the month is June
	b.ne	mainJul					//If not branch to the check for July
	cmp	mainDay_r, 21				//Compares the day with 21
	b.lt	mainSpring				//If day < 21 it is spring
	b	mainSummer				//If day >= 21 it is Summer

mainJul:
	cmp	mainMonth_r, 7				//Checks if month is July
	b.eq	mainSummer				//July is in the summer

mainAug:
	cmp	mainMonth_r, 8				//Checks if month is August
	b.eq	mainSummer				//August is in the Summer

mainSep:
	cmp	mainMonth_r, 9				//Checks if month is September
	b.ne	mainOct					//If not branch to the check for October
	cmp	mainDay_r, 21				//Compare the day with 21
	b.lt	mainSummer				//If day < 21 it is Summer
	b	mainFall				//If day >= 21 it is Fall

mainOct:
	cmp	mainMonth_r, 10				//Checks if month is October
	b.eq	mainFall				//October is in the Fall

mainNov:
	cmp	mainMonth_r, 11				//Checks if month is November
	b.eq	mainFall				//November is in the Fall

mainDec:
	cmp	mainMonth_r, 12				//Checks if the month is december
	b.ne	mainError				//Has to be december to get here or there is an error
	cmp	mainDay_r, 21				//Compares Day with 21
	b.lt	mainFall				//If day < 21 it is Fall
//	b	mainWinter				//The code  will fall through into mainWinter so there is no need to run this line

mainWinter:
	mov	w2, 0					//Set the season as Winter
	bl	printDate				//Call the print date function
	b	mainDone				//Branch to the end of main

mainSpring:
	mov	w2, 1					//Set the season as Spring
	bl	printDate				//Call the print date function
	b	mainDone				//Branch to the end of main

mainSummer:
	mov	w2, 2					//Set the season as Summer
	bl	printDate				//Call the print date function
	b	mainDone				//Branches to the end of main

mainFall:
	mov	w2, 3					//Set the season as Fall
	bl	printDate				//Calls the printDate function
	b	mainDone				//Branch to the end of main

//There is an error if the code gets  to here
mainError:
	adrp	x0, errorString_m			//Loads the address of the formatted error string
	add	x0, x0,:lo12:errorString_m		//Gets the low 12
	bl	printf					//Prints the error string to the screen

mainDone:
	ldp	x29, x30, [sp], mainDealloc		//Deallocates the stack frame from ram
	ret						//Return call for main

//---------------------------------------------------------------------------
//The error checking subroutine

	define(errorCheckAlloc, -(16 + 16) & -16)	//How much memory to allocate for errorCheck
	define(errorCheckDealloc, -errorCheckAlloc)	//How much memory to deallocate
	define(errorCheckDay_r, w9)			//Naming a register thet will hold the day
	define(errorCheckMonth_r, w10)			//Naming a register that will hold the month
errorCheck:						//The entry point for errorCheck
	stp	x29, x30, [sp, errorCheckAlloc]!	//Pushes a stack frame onto the stack for errorCheck
	mov	x29, sp					//Moves sp into x29

	str	x19, [x29,16]				//Saves x19 into ram
	str	x20, [x29, 16+8]			//Saves x20 into ram

//w0 has the # of args in it
	cmp	w0, 3					//3 args, first is the filename
	b.ne	errorCheckFalse				//Branches to False if there are not 3 args

//Getting the args into their registers as integers
	ldr	x20, [x1, 16]				//Moves the address of the second string into x20

	ldr	x0, [x1, 8]				//moves address of the first string into x0
	bl	atoi					//Calls atoi to change the string to an integer
	mov	w19, w0					//Stores the first arg (as an int) into w19

	mov	x0, x20					//Moves the address of the second string into x0
	bl	atoi					//Changes the string to an integer
	mov	errorCheckDay_r, w0			//Moves the day into its register
	mov	errorCheckMonth_r, w19			//Moves the month into its registerr

	cmp	errorCheckMonth_r, wzr			//If month <= 0
	b.le	errorCheckFalse				//Branch to false because there are no negative months / 0th month

	cmp	errorCheckMonth_r, 12			//If month > 12
	b.gt	errorCheckFalse				//Branch to false because 12 (december) is the last month

	cmp	errorCheckDay_r, wzr			//If day <= 0
	b.le	errorCheckFalse				//Branch to false because there are no negative days / 0th day

	cmp	errorCheckDay_r, 31			//If day > 31
	b.gt errorCheckFalse				//The maximum number of days in a month is 31

//To get here day and month are int's in range

	cmp	errorCheckDay_r, 31			//Compares the day with 31
	b.ne	errorCheckNot31				//If it is not 31 tehn branch over
//Day == 31 to get here
	cmp	errorCheckMonth_r, 2			//Checks for February 31st
	b.eq	errorCheckFalse				//Feb 31st doesn't exist

	cmp	errorCheckMonth_r, 4			//Checks for April 31st
	b.eq	errorCheckFalse				//April 31st doesn't exist

	cmp	errorCheckMonth_r, 6			//Checks for June 31st
	b.eq	errorCheckFalse				//june 31st doesn't exist

	cmp	errorCheckMonth_r, 9			//Checks for September 31st
	b.eq	errorCheckFalse				//September 31st doesn't exist

	cmp	errorCheckMonth_r, 11			//Checks for november 31st
	b.eq	errorCheckFalse				//November 31st doesn't exist

	b	errorCheckTrue				//There are no errors if the code gets here so branch to true

errorCheckNot31:					//The day is not 31 to get here
	cmp	errorCheckDay_r, 30			//Checks if the day is 30
	b.ne	errorCheckTrue				//Branch over to true if the day is not 30

	cmp	errorCheckMonth_r, 2			//Check for February 30th
	b.eq	errorCheckFalse				//False if "2 30" is given
//note: February 29th IS a valid input because it is a leap day
errorCheckTrue:						//To get here it must be TRUE
	mov	w0, TRUE				//Moves w0 into w0 to return
	mov	w1, errorCheckMonth_r			//Moves the month into w1 to return (I could return a struct but that's just more instruction cycles)
	mov	w2, errorCheckDay_r			//Moves the day into w2 to return
	b	errorCheckDone				//Branch over errorCheckFalse

errorCheckFalse:					//There is an error if it gets here
	mov	w0, FALSE				//moves False into w0 to return

errorCheckDone:
	ldr	x19, [x29, 16]				//Restores x19 from ram
	ldr	x20, [x29, 16+8]			//Restores x20 from ram
	ldp	x29, x30, [sp], errorCheckDealloc	//Deallocates memory from ram
	ret						//Return call for the error check subroutine

//------------------------------------------------------------------------
//The subroutine that takes in the month, day, and season and prints out the corresponding string to the screen

	define(printDateAlloc, -16)				//How much space to allocate for the printDate function
	define(printDateDealloc, -printDateAlloc)		//How much to deallocate
	define(printMonth_r, w9)				//A register for the month
	define(printDay_r, w10)					//A register for the day
	define(printSeason_r, w11)				//A register for the season
	define(printBase_r, x12)				//An x register to hold the addresses for the string arrays
printDate:							//Entry point for printDate
	stp	x29, x30, [sp, printDateAlloc]!			//Pushing a stack frame onto the stack for printDate
	mov	x29, sp						//Moves sp into x29

	mov	printMonth_r, w0				//Moves the month into its register
	mov	printDay_r, w1					//Moves the day into its register
	mov	printSeason_r, w2				//Moves the season into it's register

	ldr	x0, =stringFormat				//Loads the formatted string into x0 for printf

	adrp	printBase_r, monthArray_m			//Loads the base of the month array
	add	printBase_r, printBase_r,:lo12:monthArray_m	//Gets the low 12
	ldr	x1,[printBase_r, printMonth_r, SXTW 3]		//Loads the monthArray[month] into x1 to print

	adrp	printBase_r, dayArray_m				//Loads the base of the day array
	add	printBase_r, printBase_r,:lo12:dayArray_m	//Gets the low 12
	ldr	x2,[printBase_r, printDay_r, SXTW 3]		//Loads dayArray[day] into x2 to print

	adrp	printBase_r, seasonArray_m			//Loads the base fo the season array
	add	printBase_r, printBase_r,:lo12:seasonArray_m	//Gets the low 12
	ldr	x3,[printBase_r, printSeason_r, SXTW 3]		//Loads seasonArray[Season] into x3 to print

	bl	printf						//Calls printf

printDateDone:
	ldp	x29, x30, [sp], printDateDealloc		//Deallocating memory from ram for printDate
	ret							//Return call for printDate

