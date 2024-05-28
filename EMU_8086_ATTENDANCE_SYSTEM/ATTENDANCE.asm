.MODEL SMALL 

.DATA
    MAX_NAME_SIZE EQU 40
    MAX_STUDENT_COUNT EQU 40
    
    CURRENT_STUDENT_COUNT DB 0
    
    STUDENT_NAMES DB MAX_NAME_SIZE * MAX_STUDENT_COUNT DUP('*')
    STUDENT_NAME_SIZES DB MAX_STUDENT_COUNT DUP(0)
    
    NEXT DW ?
.CODE
   
    ;UTILS
    NEW_LINE PROC
        MOV AH, 02H
        MOV DL, 10
        INT 21H
        
        MOV DL, 13
        INT 21H
        RET
    NEW_LINE ENDP
    
    ;INPUTS
    
    STUDENT_DATA_INPUT PROC
        
        MOV AH, 01H
        
        INPUT_LOOP:
            INT 21H
            
            CMP AL, 13
            JE END_INPUT
            
            MOV [SI], AL
            
            INC SI
            LOOP INPUT_LOOP
        
        END_INPUT:
        RET
    STUDENT_DATA_INPUT ENDP
    
    PRINT_STUDENT_DATA PROC
        
        MOV CX, 0
        
        PRINT_LOOP:
        
            MOV AX, 0
            
            MOV AH, 02H
            MOV NEXT, BX 
            
            PRINT_NAME:
                MOV DL, [SI]
                
                CMP DL, 42
                JE  BREAK_NAME
                
                INT 21H
                INC SI
                DEC NEXT
                
                JMP PRINT_NAME
            
            BREAK_NAME:
                CALL NEW_LINE
                
            ADD SI, NEXT
            
            INC CL    
            CMP CL, CURRENT_STUDENT_COUNT
            JL  PRINT_LOOP:
            
        RET
    PRINT_STUDENT_DATA ENDP
    
    MAIN PROC
        MOV AX, @DATA
        MOV DS, AX
         
        TEST_LOOP:
            MOV AX, 0
            
            MOV AL, CURRENT_STUDENT_COUNT
            MOV BX, MAX_NAME_SIZE
            MUL BX
            MOV SI, OFFSET STUDENT_NAMES
            
            ADD SI, AX 
          
            MOV CL, MAX_NAME_SIZE

            CALL STUDENT_DATA_INPUT
            
            INC CURRENT_STUDENT_COUNT
            
            CMP CURRENT_STUDENT_COUNT, 5
            
            CALL NEW_LINE
            
            JL TEST_LOOP
        
        MOV BL, MAX_NAME_SIZE    
        MOV SI, OFFSET STUDENT_NAMES
         
        CALL PRINT_STUDENT_DATA
        
        
                        
        MOV AH, 4CH
        INT 21H
    END MAIN