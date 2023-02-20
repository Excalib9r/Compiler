.MODEL SMALL
.STACK 1000H
.DATA
	number DB "00000$"
	i_0 DW 0
	j_1 DW 0
.CODE
main PROC
	PUSH BP
	MOV BP, SP
	MOV AX, @DATA
	MOV DS, AX
	SUB SP, 2
	SUB SP, 2
	SUB SP, 2
	SUB SP, 2
	SUB SP, 2
	SUB SP, 2
	MOV AX, 1
	PUSH AX
	POP AX
	MOV i_0, AX
	PUSH AX
	POP AX
	MOV AX, i_0
	CALL PRINTLN
	MOV AX, 5
	PUSH AX
	MOV AX, 8
	PUSH AX
	POP CX
	POP DX
	ADD DX, CX
	PUSH DX
	POP AX
	MOV j_1, AX
	PUSH AX
	POP AX
	MOV AX, j_1
	CALL PRINTLN
	MOV AX, i_0
	PUSH AX
	MOV AX, 2
	PUSH AX
	MOV AX, j_1
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
	MOV BP[-2], AX
	PUSH AX
	POP AX
	MOV AX, BP[-2]
	CALL PRINTLN
	MOV AX, BP[-2]
	PUSH AX
	MOV AX, 9
	PUSH AX
	POP BX
	POP AX
	CWD
	IDIV BX
	PUSH DX
	POP AX
	MOV BP[-6], AX
	PUSH AX
	POP AX
	MOV AX, BP[-6]
	CALL PRINTLN
	MOV AX, BP[-6]
	PUSH AX
	MOV AX, BP[-4]
	PUSH AX
	POP DX
	POP CX
	CMP CX, DX
	JLE FOR_RELOP0
	MOV CX, 0
	JMP END0
FOR_RELOP0:
	MOV CX, 1
END0:
	PUSH CX
	POP AX
	MOV BP[-8], AX
	PUSH AX
	POP AX
	MOV AX, BP[-8]
	CALL PRINTLN
	MOV AX, i_0
	PUSH AX
	MOV AX, j_1
	PUSH AX
	POP DX
	POP CX
	CMP CX, DX
	JNE FOR_RELOP1
	MOV CX, 0
	JMP END1
FOR_RELOP1:
	MOV CX, 1
END1:
	PUSH CX
	POP AX
	MOV BP[-10], AX
	PUSH AX
	POP AX
	MOV AX, BP[-10]
	CALL PRINTLN
	MOV AX, BP[-8]
	PUSH AX
	MOV AX, BP[-10]
	PUSH AX
	POP DX
	POP CX
	JG FOR_LOGICOP2
	MOV CX, 0
	JMP END2
FOR_LOGICOP2:
	MOV CX, 1
	END2:
	PUSH CX
	POP AX
	MOV BP[-12], AX
	PUSH AX
	POP AX
	MOV AX, BP[-12]
	CALL PRINTLN
	MOV AX, BP[-8]
	PUSH AX
	MOV AX, BP[-10]
	PUSH AX
	POP DX
	POP CX
	CMP CX, 0
	JG FOR_LOGICOP3
	MOV CX, 0
	JMP END3
FOR_LOGICOP3:
	MOV CX, 1
	END3:
	PUSH CX
	POP AX
	MOV BP[-12], AX
	PUSH AX
	POP AX
	MOV AX, BP[-12]
	CALL PRINTLN
	PUSH BP[-12]
	ADD BP[-12], 1
	POP AX
	MOV AX, BP[-12]
	CALL PRINTLN
	MOV AX, BP[-12]
	PUSH AX
	POP CX
	NEG CX
	PUSH CX
	POP AX
	MOV BP[-2], AX
	PUSH AX
	POP AX
	MOV AX, BP[-2]
	CALL PRINTLN
	ADD SP, 2
	ADD SP, 2
	ADD SP, 2
	ADD SP, 2
	ADD SP, 2
	ADD SP, 2
RETURN0:
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
