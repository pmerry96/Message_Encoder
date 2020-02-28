/*
Name: Philip Merry
Class: CPSC 2310 - section 2
Assignment: Message Encoder
Due: 12/3/2019 @ midnight
*/

    .global encode
//ASSUMPTIONS
/*
    All letters are lower case
    Strings will end with the u\0000 (ascii 0) character
    There arent output parameters, only side effects
*/


//note the folloing register convention in this project
// r0 = address of input string
// r1 = address of output string
// r2 = address of key string
// r3 = encode/decode switch
    // r3 - boolean in which
    // False / 0 = encode
    // True  / 1 = decode
//beyond these registers, we must allocate on the stack or push the
//preserved registers
encode:
    push {r4, r5, r6, r7, r8, r9, lr}
	message_addr	.req r0
	out_addr	.req r1
	key_addr	.req r2
	moff		.req r7
	ooff		.req r8
	koff		.req r9

    mov moff, #0
    mov ooff, #0
    mov koff, #0

    cmp r3, #1
    beq decode //this is the first check we will evaluate. 
	//further, becuase it is not another subroutine, registers will be
	//preserved on the branch I believe. 
    //the length of the phrase is significant, but not in reading, only in
    //the evaluation. We need to use the Key OR the Message as a circular
    //buffer such that we dont accidentally run off the end of the shorter 
    //string and segfualt
    //ldr r0, =in_encode
    //bl printf
    
    //so here we start the encoding process
encode_loop:
	ldrb r4, [message_addr, moff] //char is one byte
	cmp r4, #0
	beq end
	ldrb r5, [key_addr, koff]
	add moff, moff, #1
	add koff, koff, #1
	cmp r5, #0
	bne skip
	mov koff, #0
	ldrb r5, [key_addr, koff]
	add koff, koff, #1

	//I need to check for a space and skip past if so.
	    //Ie push the space into ouput and move past
skip:
	cmp r4, #97
	blt space_skip
	cmp r4, #122
	bgt space_skip
	cmp r5, #97
	blt space_skip
	cmp r5, #122
	bgt space_skip

not_message_space:
	sub r4, r4, #0x60
	sub r5, r5, #0x60
	add r6, r4, r5
	cmp r6, #26
	subgt r6, r6, #26 //sub only greater than 26
	add r6, r6, #0x60
	strb r6, [out_addr, ooff]
	add ooff, ooff, #1
	b encode_loop
	
space_skip:
	//this skips encoding the space chars
	//strb r5, [out_addr, ooff] //store the space to out addr + out_offset
	//add ooff, ooff, #1 //advance the output by 1 past space just placed
	strb r4, [out_addr, ooff]
	add ooff, ooff, #1
	//ldrb r5, [key_addr, koff] //load a new char from the key + key_offset
	//add koff, koff, #1 //advance key past space as well
	b encode_loop

decode:
    //label exists just as a target to get us into the decode block
   
decode_loop:
	ldrb r4, [message_addr, moff] //char is one byte
	cmp r4, #0
	beq end
	ldrb r5, [key_addr, koff]
	add moff, moff, #1
	add koff, koff, #1
	cmp r5, #0
	bne decode_skip
	mov koff, #0
	ldrb r5, [key_addr, koff]
	add koff, koff, #1

	//I need to check for a space and skip past if so.
	    //Ie push the space into ouput and move past
decode_skip:
	cmp r4, #97
	blt decode_space_skip
	cmp r4, #122
	bgt decode_space_skip
	cmp r5, #97
	blt decode_space_skip
	cmp r5, #122
	bgt decode_space_skip

decode_not_message_space:
	sub r4, r4, #0x60
	sub r5, r5, #0x60
	sub r6, r4, r5
	cmp r6, #0
	addlt r6, r6, #26 //sub only greater than 26
	add r6, r6, #0x60
	strb r6, [out_addr, ooff]
	add ooff, ooff, #1
	b decode_loop
	
decode_space_skip:
	//this skips encoding the space chars
	//strb r5, [out_addr, ooff] //store the space to out addr + out_offset
	//add ooff, ooff, #1 //advance the output by 1 past space just placed
	strb r4, [out_addr, ooff]
	add ooff, ooff, #1
	//ldrb r5, [key_addr, koff] //load a new char from the key + key_offset
	//add koff, koff, #1 //advance key past space as well
	b decode_loop

end:
    mov r6, #0
    strb r6, [out_addr, ooff]
    .unreq message_addr
    .unreq key_addr
    .unreq out_addr
    .unreq moff
    .unreq ooff
    .unreq koff
    pop {r4, r5, r6, r7, r8, r9, pc}
