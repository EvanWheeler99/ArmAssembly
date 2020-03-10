//Assignment 5 a
//By: Evan Wheeler
//Student #: 30046173

	define(QUEUESIZE, 8)				//The size of the queue
	define(MODMASK, 0x7)				//Defining the modmask
	define(FALSE, 0)				//False
	define(TRUE, 1)					//True


//GLOBAL VARIABLES
	.data
//QUEUE?
	.global	queue_m					//Making the queue global
queue_m:
	.skip	(QUEUESIZE * 4)				//An Int array of size QUEUESIZE

	.global head_m					//Making head_m global
head_m:	.word	-1					//Initializing head as -1

	.global	tail_m					//Making tail global
tail_m:	.word	-1					//Initializing tail as -1

	.text

	define(enqValue_r, w19)				//The register for value
	define(enqueueAlloc, -(16 + 8)& -16)		//Alloc for enqueue
	define(enqueueDealloc, -enqueueAlloc)		//How much to dealloc
	.balign 4					//Alligning memory
	.global	enqueue					//Making enqueue global
enqueue:
	stp	x29, x30, [sp, enqueueAlloc]!		//Allocationg memory for enqueue
	mov	x29, sp					//Move sp into x29

	str	x19, [x29, 16]				//Stores x19 into ram

	mov	enqValue_r, w0				//Move the passed in value into it's register
	bl	queueFull				//Branch to queueFull
	cmp	w0, FALSE				//Compares the result of queueFull with FALSE
	b.eq	enqueueNotFull				//Branch over if the queue is not full
//Queue is full to get here
	ldr	w0, =enqueueString			//Load the string into x0 to print
	bl	printf					//Calls printf
	b	enqueueDone				//Branches to the end of enqueue

enqueueNotFull:
	bl	queueEmpty				//Calls queueEmpty
	cmp	w0, FALSE				//Checks if queueEmpty is False
	b.eq	enqueueElse				//Branches to else if it is false
//Queue is empty to get here
	mov	w10, wzr				//Moves 0 into w10	

	adrp	x9, head_m				//Setting up the address of head into x9
	add	x9, x9,:lo12:head_m			//Getting the low 12 bits
	str	w10, [x9]				//head_m = 0

	adrp	x9, tail_m				//Setting up tail into x9
	add	x9, x9,:lo12:tail_m			//Getting the low 12 bits
	str	w10, [x9]				//tail_m = 0
	b	enqueueDoneIf				//Branches to enqueueDoneIf

enqueueElse:
	adrp	x9, tail_m				//Setting up the address of tail in x9
	add	x9, x9,:lo12:tail_m			//Getting the low 12 bits
	ldr	w10, [x9]				//Load tail_m into w10

	add	w10, w10, 1				//++tail
	and	w10, w10, MODMASK			//++tail & modmask
	str	w10, [x9]				//Store w10 into tail_m

enqueueDoneIf:
	adrp	x9, tail_m				//Setting upthe address of tail into x9
	add	x9, x9,:lo12:tail_m			//Getting the low 12 bits
	ldr	w10, [x9]				//Load tail_m into w10

	adrp	x11, queue_m				//Setting up the address of queue into x11
	add	x11,x11,:lo12:queue_m			//Getting the low 12 bits

	str	enqValue_r, [x11, w10, SXTW 2]		//Store value into queue[tail]

enqueueDone:
	ldr	x19, [x29, 16]				//Re-loads x19 from RAM
	ldp	x29, x30, [sp], enqueueDealloc		//Deallocation memory
	ret						//Ending enqueue


//DEQUEUE
	define(dequeueAlloc, -(16 + 8)& -16)		//How much to allocate for dequeue
	define(dequeueDealloc, -dequeueAlloc)		//How much to deallocate
	define(deqValue_r, w19)				//The register for Value
	.global dequeue					//Making dequeue global
dequeue:
	stp	x29, x30, [sp, dequeueAlloc]!		//Allocating space for the stack frame of dequeue
	mov	x29, sp					//Moving sp into x29

	str	x19, [x29, 16]				//Storing x19 into memory

	bl	queueEmpty				//Calling queueEmpty
	cmp	w0, FALSE				//Comparing w0 with False
	b.eq	dequeueIf1False				//If it is false branch over
	ldr	x0, =dequeueString			//Loads the string into x0
	bl	printf					//Calls printf
	mov	w0, -1					//Moves -1 into w0 to return
	b	dequeueDone				//Branches to the end of dequeue

dequeueIf1False:
	adrp	x10, head_m				//Setting up the address of head
	add	x10, x10,:lo12:head_m			//x10 = register for head
	ldr	w11, [x10]				//w11 = head_m

	adrp	x12, tail_m				//Setting up the address of tail
	add	x12, x12,:lo12:tail_m			//x12 = register for tail
	ldr	w13, [x12]				//w13 = tail_m

	adrp	x14, queue_m				//Setting up the base register for queue
	add	x14, x14,:lo12:queue_m			//x14 = start of queue

	ldr	deqValue_r, [x14, w11, SXTW 2]		//value = queue[head]

	cmp	w11, w13				//Compare head with tail
	b.ne	dequeueElse				//If head != tail branch to else
//Tail == Head to get here
	mov	w16, -1					//Puts -1 into a register
	str	w16, [x10]				//head = -1
	str	w16, [x12]				//tail = -1
	b 	dequeueDone				//Branches over the else	

dequeueElse:
	add	w11, w11, 1				//++head
	and	w11, w11, MODMASK			//head & MODMASK
	str	w11, [x10]				//stores head into memory

	mov	w0, deqValue_r				//move value to w0 to return

dequeueDone:
	ldr	x19, [x29, 16]				//loading x19 back from ram
	ldp	x29, x30, [sp], dequeueDealloc		//Deallocating memory
	ret						//Return call for dequeue


//QUEUEFULL
	define(queueFullAlloc, -16)			//How much to allocate for queueFull
	define(queueFullDealloc, - queueFullAlloc)	//How much momory to deallocate
	.global queueFull				//making queueFull global
queueFull:
	stp	x29, x30, [sp, queueFullAlloc]!		//Storing the stack frame to ram
	mov	x29, sp					//Moving sp into x29

	adrp	x9, head_m				//Setting up head_m
	add	x9, x9,:lo12:head_m			//Getting the low 12 bits
	ldr	w10, [x9]				//loads head into w10
	adrp	x11, tail_m				//Setting up tail_m
	add	x11, x11,:lo12:tail_m			//Getting the low 12 bits
	ldr	w12, [x11]				//Loads tail into w12

	add	w13, w12, 1				//w13 = tail + 1
	and	w13, w13, MODMASK			//w13 & MODMASK
	cmp	w13, w10				//Compares w13 with head
	b.ne	queueFullFalse				//If != branch over
//Must be true
	mov	w0, TRUE				//Move True into w0 to return
	b	queueFullDone				//Branch to the end of queueFull

queueFullFalse:
	mov	w0, FALSE				//Move False into w0 to return

queueFullDone:
	ldp	x29, x30, [sp], queueFullDealloc	//Deallocating memory
	ret						//Return call for QueueFull



//QUEUE EMPTY
	define(queueEmptyAlloc, -16)			//How much to allocate for queueEmpty
	define(queueEmptyDealloc, - queueEmptyAlloc)	//How much to deallocate
	.global queueEmpty				//Making queueEmpty global
queueEmpty:
	stp	x29, x30, [sp, queueEmptyAlloc]!	//Allocating the stack frame into ram
	mov	x29, sp					//Moving sp into x29

	adrp	x9, head_m				//Setting up head
	add	x9, x9,:lo12:head_m			//Getting the low 12 bits
	ldr	w10, [x9]				//Loading head into w10

	cmp	w10, -1					//Comparing head with -1
	b.ne	queueEmptyFalse				//If it is != branch over
//Queue is full to get here
	mov	w0, TRUE				//Move TRUE into w0 to return
	b	queueEmptyDone				//Branch to the end of the function

queueEmptyFalse:
	mov	w0, FALSE				//Move False into w0 to return

queueEmptyDone:
	ldp	x29, x30, [sp], queueEmptyDealloc	//Pop the stack frame
	ret						//Return call for queueEmpty


//DISPLAY
	define(displayAlloc, -(16 + (8 * 6)) & -16)	//How much space to allocate for display
	define(displayDealloc, - displayAlloc)		//how much to deallocate

	define(displayTail_r, w19)			//A register for tail
	define(displayHead_r, w20)			//A register for head
	define(displayQueueBase_r, x21)			//A register for the base address of the queue

	define(i_r, w22)				//A register for i
	define(j_r, w23)				//A register for j
	define(count_r, w24)				//A register for count

	.global display					//Making display global
display:
	stp	x29, x30, [sp, displayAlloc]!		//Allocating space for display
	mov	x29, sp					//Moving sp into x29

//Storing registers
	str	x19, [x29, 16]				//Stores x19
	str	x20, [x29, 16 + 4]			//Stores x20
	str	x21, [x29, 16 + (4*2)]			//Stores x21
	str	x22, [x29, 16 + (4*3)]			//Stores x22
	str	x23, [x29, 16 + (4*4)]			//Stores x23
	str	x24, [x29, 16 + (4*5)]			//Stores x24

	bl	queueEmpty				//Calls queueEmpty
	cmp	w0, FALSE				//Checks if the queue is empty
	b.eq	displayQueueNotEmpty			//If it is not empty branch over
//Queue is empty
	ldr	x0, =dispEmptyQueueString		//load the string into x0 to print
	bl	printf					//Calls print
	b	displayDone				//Branch to the end of the subroutine

displayQueueNotEmpty:
	adrp	x9, tail_m				//Setting up tail
	add	x9, x9,:lo12:tail_m			//Getting the low 12 bits
	ldr	displayTail_r, [x9]			//Loads tail into it's register

	adrp	x9, head_m				//Setting up head
	add	x9, x9,:lo12:head_m			//Getting the low 12
	ldr	displayHead_r, [x9]			//Moving head into it's register

	adrp	displayQueueBase_r, queue_m		//setting up the base register for queue
	add	displayQueueBase_r, displayQueueBase_r,:lo12:queue_m	//Getting the low 12

	sub	w9, displayTail_r, displayHead_r	//w9 = head - tail
	add	w9, w9, 1				//w9++
	mov	count_r, w9				//count = tail - head + 1

displayIf0:
	cmp	count_r, wzr				//Compares count with 0
	b.gt	displayOverIf0				//Branches over if it is >= 0
	add	count_r, count_r, QUEUESIZE		//count += QUEUESIZE


displayOverIf0:
	ldr	x0, =queueContentsString		//Loads he string to print
	bl	printf					//Prints the string

	mov	i_r, displayHead_r			//i = head

	mov	j_r, wzr				//j = 0
	b	displayForTest				//Branches to the test of the for loop

displayFor:
	ldr	x0, =displayString1			//Loads the string into x0 to print
	ldr	w1, [displayQueueBase_r, j_r, SXTW 2]	//Loads queue[j] in as an argument to print
	bl	printf					//Calls print

displayIf1:
	cmp	i_r, displayHead_r			//Compares i with head
	b.ne	displayOverIf1				//Branches over if the are not equal
	ldr	x0, =queueHeadString			//Loads the string to print
	bl	printf					//Calls printf
displayOverIf1:

displayIf2:
	cmp	i_r, displayTail_r			//Compares tail and i
	b.ne	displayOverIf2				// if != branch over
	ldr	x0, =queueTailString			//Load the string to print
	bl	printf					//Calls printf
displayOverIf2:

	ldr	x0, =newlineString			//Loads a newline to print
	bl	printf					//Prints the newline

	add	i_r, i_r, 1				//i++
	and	i_r, i_r, MODMASK			//i = i++ & MODMASK

	add	j_r, j_r, 1				//j++

displayForTest:
	cmp	j_r, count_r				//Compares j with count
	b.lt	displayFor				//Continues looping if j < count


displayDone:
//Restoring Registers
	ldr	x19, [x29, 16]				//Restores x19
	ldr	x20, [x29, 16 + 4]			//Restores x20
	ldr	x21, [x29, 16 + (4*2)]			//Restores x21
	ldr	x22, [x29, 16 + (4*3)]			//Restores x22
	ldr	x23, [x29, 16 + (4*4)]			//Restores x23
	ldr	x24, [x29, 16 + (4*5)]			//Restores x24

	ldp	x29, x30, [sp], displayDealloc		//Deallocates memory for display
	ret						//Return call for display


enqueueString:	.asciz "\nQueue Overflow. Cannot enqueue into a full queue.\n"		//The string printed when enqueue is calle d with a full queue
dequeueString:	.asciz "\nQueue underflow. Cannot dequeue from an empty queue.\n"	//The string printed when dequeue is called with an empty queue
dispEmptyQueueString:	.asciz "\nEmpty queue\n"					//The string printed when display is called with an empty queue
queueContentsString:	.asciz "\nCurrent queue contents:\n"				//The first thing printed before displaying the queue
displayString1:	.asciz "  %d"								//A formatted string to represent the values in the queue
queueHeadString: .asciz " <-- head of queue"						//Tho show the head of the queue
queueTailString: .asciz " <-- tail of queue"						//To show the tail of the queue
newlineString: .asciz "\n"								//A newline character

