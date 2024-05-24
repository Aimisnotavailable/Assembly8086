.MODEL SMALL

.DATA

 POS_Y db 0
 POS_X db 0
 MAX_Y equ 10
 MAX_X equ 20
 MIN equ 1
 DIR_X db 1
 DIR_Y db 1
 
 
 W db 'w'
 A db 'a'
 S db 's'
 D db 'd'
 
 ROOF DB 20  DUP('='), '$'
 FLOOR DB 20 DUP('='), '$'
 
 LAST_PRESSED DB ?
 
 
 
 
 
.CODE
    DISPLAY_ROOF PROC
        ;CLEAR SCREEN
        MOV AX, 00H
        INT 10H
        
        MOV AH, 09H
        LEA DX, ROOF
        INT 21H
        RET
    DISPLAY_ROOF ENDP
    
    DISPLAY_BALL PROC 
        
        MOV AH, 02H 
        MOV DH, POS_Y
        MOV DL, POS_X
        INT 10H
        
        ;BALL       
        MOV DL, 42 
        INT 21H
        
        CMP POS_Y, MAX_Y
        JE  UP
        CMP POS_Y, MIN
        JE  DOWN
        JMP UPDATE_Y
        
        UP:
            MOV DIR_Y, 0
            JMP UPDATE_Y
        DOWN:
            MOV DIR_Y, 1
            JMP UPDATE_Y
        
        UPDATE_Y:
            MOV AL, 1
            AND AL, DIR_Y
            JZ  MOVE_UP

        MOVE_DOWN:
            INC POS_Y
            JMP X
        MOVE_UP:
            DEC POS_Y
            JMP X
        
        X:
            CMP POS_X, MAX_X
            JE  LEFT
            CMP POS_X, MIN
            JE  RIGHT
            JMP UPDATE_X
            
            LEFT:
                MOV DIR_X, 0
                JMP UPDATE_X
            RIGHT:
                MOV DIR_X, 1
                JMP UPDATE_X
            
            UPDATE_X:
                MOV AL, 1
                AND AL, DIR_X
                JZ  MOVE_LEFT
    
            MOVE_RIGHT:
                INC POS_X
                JMP END_IF
            MOVE_LEFT:
                DEC POS_X
                JMP END_IF
            
        END_IF:
                
        MOV CX, 1
     
        
        RET 
    DISPLAY_BALL ENDP
    
    DISPLAY_FLOOR PROC
        
        MOV AH, 02H
        MOV DH, MAX_Y + 1
        MOV DL, 0
        INT 10H
        
        MOV AH, 09H
        LEA DX, FLOOR
        INT 21H
        
        RET
    DISPLAY_FLOOR ENDP
    
    KEY_INPUT PROC
        MOV AH, 1
        INT 16H
        RET
    KEY_INPUT ENDP
    
    OVERRIDE_DIR PROC

        CMP AL, W
        JE  OV_UP
        CMP AL, S
        JE  OV_DOWN
        CMP AL, A
        JE  OV_LEFT
        CMP AL, D
        JE  OV_RIGHT
        JMP END_OV
        
        OV_UP:
            MOV dir_y,0
            JMP END_OV
        OV_DOWN:
            MOV dir_y, 1
            JMP END_OV
        OV_LEFT:
            MOV dir_x, 0
            JMP END_OV
        OV_RIGHT:
            MOV dir_x, 1
            JMP END_OV
        
        IGNORE_BUFFER:
            MOV AH, 0
            INT 16H
                
        END_OV:
 
        RET
    OVERRIDE_DIR ENDP
    
    MAIN PROC
        MOV AX, @DATA
        MOV DS, AX
        MOV CX, 1
        MOVE:
            CALL DISPLAY_ROOF
            CALL DISPLAY_FLOOR
            CALL DISPLAY_BALL 
            CALL KEY_INPUT
            JNZ  CHANGE_DIR
                        
            JMP CONTINUE
            
            CHANGE_DIR:
            
                CALL OVERRIDE_DIR
                MOV AH, 00H
                INT 16H
                
            CONTINUE:

                
                INC CX
        LOOP MOVE
        
        MOV AH, 4CH
        INT 21H
    MAIN ENDP
END MAIN        