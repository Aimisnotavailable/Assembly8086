.MODEL SMALL

.DATA
 
 M1 DB "SAGI-SAGI BALL$"
 M2 DB "[1] AUTO PLAY$"
 M3 DB "[2] CONTROL THE BALL$"
 M4 DB "CHOICE: $"
 
 ; UTILS FOR MOVEMENT
 POS_Y db 8
 POS_X db 15
 MAX_Y equ 15
 MAX_X equ 30
 MIN equ 1
 WR_Y DB 8
 WL_Y DB 8
 
 ; X & Y DIRECTION
 DIR_X db 1
 DIR_Y db 1
 
 ; KEY INPUT
 W db 'w'
 A db 'a'
 S db 's'
 D db 'd'
 
 
 ; DISPLAY
 ROOF DB 30  DUP('='), '$'
 FLOOR DB 30 DUP('='), '$'
 
 WALL_RIGHT DB 124
 WALL_LEFT  DB 124
 
 MODE DB ?
  
.CODE
    ; NEW LINE UTILS
    NEW_LINE PROC
        MOV AH, 02H
        
        MOV DL, 10
        INT 21H
        
        MOV DL, 13
        INT 21H
        
        RET
    NEW_LINE ENDP
    
    DISPLAY_ROOF PROC
        ;CLEAR SCREEN
        MOV AX, 03H
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
    
    DISPLAY_WALL_L PROC
        MOV AH, 02H
        MOV DH, WL_Y
        MOV DL, MIN - 1
        INT 10H
        
        MOV DL, WALL_LEFT
        INT 21H
        
        MOV AL, 1
        AND AL, DIR_X
        JZ  FOLLOW_BL
        
        MOV AL, 8
        JMP F_CON_L
        
        FOLLOW_BL:
            MOV AL, POS_Y
        
        F_CON_L:
            CMP AL, WL_Y
            JE  END_DWL
            JL  DEC_DWL
            JG  INC_DWL
        
        DEC_DWL:
            DEC WL_Y
            JMP END_DWL
            
        INC_DWL:
            INC WL_Y
        
        END_DWL:
        RET
    DISPLAY_WALL_L ENDP
    
    DISPLAY_WALL_R PROC
        MOV AH, 02H
        MOV DH, WR_Y
        MOV DL, MAX_X
        INT 10H
        
        MOV DL, WALL_RIGHT
        INT 21H
        
        MOV AL, 1
        AND AL, DIR_X
        JNZ  FOLLOW_BR
        
        MOV AL, 8
        JMP F_CON_R
        
        FOLLOW_BR:
            MOV AL, POS_Y
        
        F_CON_R:
            CMP AL, WR_Y
            JE  END_DWR
            JL  DEC_DWR
            JG  INC_DWR
        
        DEC_DWR:
            DEC WR_Y
            JMP END_DWL
            
        INC_DWR:
            INC WR_Y
        
        END_DWR:
        RET
    DISPLAY_WALL_R ENDP
    
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
        
        MOV AH, 09H
        LEA DX, M1
        INT 21H
        
        CALL NEW_LINE
        
        MOV AH, 09H
        LEA DX, M2
        INT 21H
        
        CALL NEW_LINE
        
        MOV AH, 09H
        LEA DX, M3
        INT 21H
        
        CALL NEW_LINE
        
        MOV AH, 09H
        LEA DX, M4
        INT 21H
        
        MOV AH, 01H
        INT 21H
        MOV MODE, AL
        
        MOV CX, 1
        MOVE:
            CALL DISPLAY_ROOF
            CALL DISPLAY_FLOOR
            CALL DISPLAY_WALL_L
            CALL DISPLAY_WALL_R
            

            CALL DISPLAY_BALL
            
            MOV AL, 1
            AND AL, MODE
            JNZ CONTINUE
             
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