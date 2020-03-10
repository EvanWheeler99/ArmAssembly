	
	
	
	


//GLOBAL VARIABLES
	.data
//QUEUE?
	.global	queue_m
queue_m:
	.skip	(8 * 4)	//An Int array of size 8

	.global head_m
head_m:	.word	-1

	.global	tail_m
tail_m:	.word	-1

	.text

	
	
	
	.balign 4
	.global	enqueue
enqueue:
	stp	x29, x30, [sp, -(16 + 8)& -16]!
	mov	x29, sp

	str	x19, [x29, 16]	//Stores x19 into ram

	mov	w19, w0
	bl	queueFull
	cmp	w0, 0
	b.eq	enqueueNotFull
//Queue is full to get here
	ldr	w0, =enqueueString
	bl	printf
	b	enqueueDone

enqueueNotFull:
	bl	queueEmpty
	cmp	w0, 0
	b.eq	enqueueElse
//Queue is empty to get here
	mov	w10, 0

	adrp	x9, head_m
	add	x9, x9,:lo12:head_m
	str	w10, [x9]	//head_m = 0

	adrp	x9, tail_m
	add	x9, x9,:lo12:tail_m
	str	w10, [x9]	//tail_m = 0
	b	enqueueDoneIf

enqueueElse:
	adrp	x9, tail_m
	add	x9, x9,:lo12:tail_m
	ldr	w10, [x9]		//Load tail_m into w10

	add	w10, w10, 1	//++tail?
	and	w10, w10, 0x7
	str	w10, [x9]		//Store w10 ito tail_m

enqueueDoneIf:
	adrp	x9, tail_m
	add	x9, x9,:lo12:tail_m
	ldr	w10, [x9]		//Load tail_m into w10

	adrp	x11, queue_m
	add	x11,x11,:lo12:queue_m

	str	w19, [x11, w10, SXTW 2]	//Store value into queue[tail]

enqueueDone:
	ldr	x19, [x29, 16]
	ldp	x29, x30, [sp], --(16 + 8)& -16
	ret



//DEQUEUE
	
	
	
	.global dequeue
dequeue:
	stp	x29, x30, [sp, -(16 + 8)& -16]!
	mov	x29, sp

	str	x19, [x29, 16]

	bl	queueEmpty
	cmp	w0, 0
	b.eq	dequeueIf1False
	ldr	x0, =dequeueString
	bl	printf
	mov	w0, -1
	b	dequeueDone

dequeueIf1False:
	adrp	x10, head_m
	add	x10, x10,:lo12:head_m	//x10 = register for head
	ldr	w11, [x10]	//w11 = head_m

	adrp	x12, tail_m
	add	x12, x12,:lo12:tail_m	//x12 = register for tail
	ldr	w13, [x12]	//w13 = tail_m

	adrp	x14, queue_m
	add	x14, x14,:lo12:queue_m	//x14 = start of queue

	ldr	w19, [x14, w11, SXTW 2]	//value = queue[head]

	cmp	w11, w13		//Compare head with tail
	b.ne	dequeueElse
//Tail == Head
	mov	w16, -1
	str	w16, [x10]	//head = -1
	str	w16, [x12]	//tail = -1

dequeueElse:
	add	w11, w11, 1	//++head?
	and	w11, w11, 0x7	//head & 0x7
	str	w11, [x10]		//stores head into memory

	mov	w0, w19		//move value to w0 to return

dequeueDone:
	ldr	x19, [x29, 16]		//loading x19 back from ram
	ldp	x29, x30, [sp], --(16 + 8)& -16
	ret



//QUEUEFULL
	
	
	.global queueFull
queueFull:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp

	adrp	x9, head_m
	add	x9, x9,:lo12:head_m
	ldr	w10, [x9]
	adrp	x11, tail_m
	add	x11, x11,:lo12:tail_m
	ldr	w12, [x11]

	add	w13, w12, 1	//w13 = tail + 1
	and	w13, w13, 0x7	//w13 & 0x7
	cmp	w13, w10		//Compares w13 with head
	b.ne	queueFullFalse
//Must be true
	mov	w0, 1
	b	queueFullDone

queueFullFalse:
	mov	w0, 0

queueFullDone:
	ldp	x29, x30, [sp], - -16
	ret



//QUEUE EMPTY
	
	
	.global queueEmpty
queueEmpty:
	stp	x29, x30, [sp, -16]!
	mov	x29, sp

	adrp	x9, head_m
	add	x9, x9,:lo12:head_m
	ldr	w10, [x9]

	cmp	w10, -1
	b.ne	queueEmptyFalse
	//Queue is full
	mov	w0, 1
	b	queueEmptyDone

queueEmptyFalse:
	mov	w0, 0

queueEmptyDone:
	ldp	x29, x30, [sp], - -16
	ret


//DISPLAY
	
	

	
	
	

	
	
	

	.global display
display:
	stp	x29, x30, [sp, -(16 + (8 * 6)) & -16]!
	mov	x29, sp

//Storing registers
	str	x19, [x29, 16]
	str	x20, [x29, 16 + 4]
	str	x21, [x29, 16 + (4*2)]
	str	x22, [x29, 16 + (4*3)]
	str	x23, [x29, 16 + (4*4)]
	str	x24, [x29, 16 + (4*5)]

	bl	queueEmpty
	cmp	w0, 0
	b.eq	displayQueueNotEmpty
//Queue is empty
	ldr	x0, =dispEmptyQueueString
	bl	printf
	b	displayDone

displayQueueNotEmpty:
	adrp	x9, tail_m
	add	x9, x9,:lo12:tail_m
	ldr	w19, [x9]

	adrp	x9, head_m
	add	x9, x9,:lo12:head_m
	ldr	w20, [x9]

	adrp	x21, queue_m
	add	x21, x21,:lo12:queue_m

	sub	w9, w19, w20	//w9 = head - tail
	add	w9, w9, 1				//w9++
	mov	w24, w9				//count = tail - head + 1

displayIf0:
	cmp	w24, wzr
	b.gt	displayOverIf0
	add	w24, w24, 8		//count += 8


displayOverIf0:
	ldr	x0, =queueContentsString
	bl	printf

	mov	w22, w20			//i = head	

	mov	w23, wzr				//j = 0
	b	displayForTest

displayFor:
	ldr	x0, =displayString1
	ldr	w1, [x21, w23, SXTW 2]
	bl	printf

displayIf1:
	cmp	w22, w20
	b.ne	displayOverIf1
	ldr	x0, =queueHeadString
	bl	printf
displayOverIf1:

displayIf2:
	cmp	w22, w19
	b.ne	displayOverIf2
	ldr	x0, =queueTailString
	bl	printf
displayOverIf2:

	ldr	x0, =newlineString
	bl	printf

	add	w22, w22, 1			//i++
	and	w22, w22, 0x7		//i = i++ & 0x7

	add	w23, w23, 1				//j++

displayForTest:
	cmp	w23, w24
	b.lt	displayFor




displayDone:
//Restoring Registers
	ldr	x19, [x29, 16]
	ldr	x20, [x29, 16 + 4]
	ldr	x21, [x29, 16 + (4*2)]
	ldr	x22, [x29, 16 + (4*3)]
	ldr	x23, [x29, 16 + (4*4)]
	ldr	x24, [x29, 16 + (4*5)]

	ldp	x29, x30, [sp], - -(16 + (8 * 6)) & -16
	ret


enqueueString:	.asciz "\nQueue Overflow. Cannot enqueue into a full queue.\n"
dequeueString:	.asciz "\nQueue underflow. Cannot dequeue from an empty queue.\n"
dispEmptyQueueString:	.asciz "\nEmpty queue\n"
queueContentsString:	.asciz "\nCurrent queue contents:\n"
displayString1:	.asciz "  %d"
queueHeadString: .asciz " <-- head of queue"
queueTailString: .asciz " <-- tail of queue"
newlineString: .asciz "\n"

