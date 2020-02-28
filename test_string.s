	.global encode

encode:
    push {lr}
    ldr r1, [r0] //load the char into r1
    ldr r2, [r2] //load second char into r2
    ldr r0, =fmt //load the format into r0
    bl printf //print

    sub r1, r1, #0x60
    sub r2, r2, #0x60
    add r3, r1, r2
    cmp r3, #26
    blt no_sub
    sub r3, r3, #26

no_sub:
    add r3, r3, #0x60
    mov r1, r3
    ldr r0, =fmt
    pop  {pc}

fmt:
    .ascii "\n\n The chars are %c and %c\n\n"

fmt2: 
    .ascii "\n\n the encoded char is %c \n\n"
