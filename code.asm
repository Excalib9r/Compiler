.MODEL SMALL
.STACK 1000H
.DATA
	number DB "00000$"
.CODE
foo_0 PROC
	PUSH BP
	MOV BP, SP
	MOV AX, BP[4]
	PUSH AX
	MOV AX, BP[6]
	PUSH AX
	POP CX
	POP DX
	ADD DX, CX
	PUSH DX
	MOV AX, 5
	PUSH AX
	POP DX
	POP CX
	CMP CX, DX
	JLE FOR_RELOP1
	MOV CX, 0
	JMP END1
FOR_RELOP1:
	MOV CX, 1
END1:
	PUSH CX
	POP AX
	CMP AX, 0
	JNE TL0
	JMP EL0
TL0:
	MOV AX, 7
	PUSH AX
	POP AX
	JMP RETURN0
EL0:
	MOV AX, BP[6]
	PUSH AX
	MOV AX, 1
	PUSH AX
	POP CX
	POP DX
	SUB DX, CX
	PUSH DX
	MOV AX, BP[4]
	PUSH AX
	MOV AX, 2
	PUSH AX
	POP CX
	POP DX
	SUB DX, CX
	PUSH DX
	CALL foo_0
	PUSH AX
	MOV AX, 2
	PUSH AX
	MOV AX, BP[6]
	PUSH AX
	MOV AX, 2
	PUSH AX
	POP CX
	POP DX
	SUB DX, CX
	PUSH DX
	MOV AX, BP[4]
	PUSH AX
	MOV AX, 1
	PUSH AX
	POP CX
	POP DX
	SUB DX, CX
	PUSH DX
	CALL foo_0
	PUSH AX
	POP BX
	POP AX
	IMUL BX
	PUSH AX
	POP CX
	POP DX
	ADD DX, CX
	PUSH DX
	POP AX
	JMP RETURN0
	ADD SP, 2
	ADD SP, 2
RETURN0:
	MOV SP, BP
	POP BP
	RET 4
foo_0 ENDP
main PROC
	PUSH BP
	MOV BP, SP
	MOV AX, @DATA
	MOV DS, AX
	SUB SP, 2
	SUB SP, 2
	SUB SP, 2
	MOV AX, 7
	PUSH AX
	POP AX
	MOV BP[-2], AX
	PUSH AX
	POP AX
	MOV AX, 3
	PUSH AX
	POP AX
	MOV BP[-4], AX
	PUSH AX
	POP AX
	MOV AX, BP[-4]
	PUSH AX
	MOV AX, BP[-2]
	PUSH AX
	CALL foo_0
	PUSH AX
	POP AX
	MOV BP[-6], AX
	PUSH AX
	POP AX
	MOV AX, BP[-6]
	CALL PRINTLN
	MOV AX, 0
	PUSH AX
	POP AX
	JMP RETURN1
	ADD SP, 2
	ADD SP, 2
	ADD SP, 2
RETURN1:
	MOV SP, BP
	POP BP
	MOV AH, 4CH
	INT 21H
main ENDP
println proc  ;print what is in ax
    push ax
    push bx
    push cx
    push dx
    push si
    lea si,number
    mov bx,10
    add si,4
    cmp ax,0
    jnge negate
print:
    xor dx,dx
    div bx
    mov [si],dl
    add [si],'0'
    dec si
    cmp ax,0
    jne print
    inc si
    lea dx,si
    mov ah,9
    int 21h
    mov ah,2
    mov dl,0DH
    int 21h
    mov ah,2
    mov dl,0AH
    int 21h
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
negate:
    push ax
    mov ah,2
    mov dl,'-'
    int 21h
    pop ax
    neg ax
    jmp print
println endp
END MAIN
