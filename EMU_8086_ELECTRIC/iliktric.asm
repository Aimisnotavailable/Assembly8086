         .MODEL SMALL

.DATA
    DISPLAY DB "ILICTRIC KUMPANY$"
    
    DISPLAY1 DB "[1] CALCULATE BILL$"
    DISPLAY2 DB "[2] PAY BILL$"
    DISPLAY3 DB "CHOICE : $"
    
    KWH DB "KWH: $"
    
    BILL_PRMPT DB "CURRENT ELECTRIC BILL: $"
    
    RATE DW 5 
    
    KWHA DB 6 DUP('0')
    
    KWHI DW ?
    BILL DW ?
    
    NUM DW ?
    MLP DW 10
    
    CHOICE DB ?    
    
   
.CODE

    MAIN_MENU PROC
        
        MOV AH, 09H
        LEA DX, DISPLAY
        INT 21H
        
        CALL NEW_LINE
        
        MOV AH, 09H
        LEA DX, DISPLAY1
        INT 21H
        
        CALL NEW_LINE
        
        MOV AH, 09H
        LEA DX,  DISPLAY2
        INT 21H
        
        CALL NEW_LINE
        
        MOV AH, 09H
        LEA DX, DISPLAY3
        INT 21H
        
        MOV AH, 01H
        SUB DL, 48
        INT 21H
        MOV CHOICE, DL
               
        RET
        
    MAIN_MENU ENDP
    
    CALCULATE_BILL PROC
        
        CALL NEW_LINE
        
        MOV AH, 09H
        LEA DX, KWH
        INT 21H
        
        CALL INPUT
        MOV  KWHI, CX
        
        CALL MULTIPLY
        
        CALL NEW_LINE
        
        MOV AH, 09H
        LEA DX, BILL_PRMPT
        INT 21H
         
        MOV  AX, KWHI
        CALL DISPLAY_BILL
        
        
        RET
        
    CALCULATE_BILL ENDP
    
    DISPLAY_BILL PROC
        CALL DISPLAY_INT
        RET
    DISPLAY_BILL ENDP
    
    DISPLAY_INT PROC
        MOV DX, 0
        MOV CX, MLP
        MOV DL, 0DH
        PUSH DX
        CNV_NUM:
            DIV CL
            
            MOV DL, AH
            MOV DH, 0
            
            PUSH DX
            MOV AH, 0
            CMP AL, 0
            JNE CNV_NUM
                        
        MOV AH, 02H
        PRNT_NUM:
            POP DX
            
            CMP DL, 0DH
            JE END_DI
            ADD DL, 48
            INT 21H
            
            JMP PRNT_NUM
        END_DI:                
        RET
    DISPLAY_INT ENDP
    
    MULTIPLY PROC            
        MOV AX, KWHI
        MUL RATE
        
        MOV KWHI, AX    
        RET
        
    MULTIPLY ENDP
    
    INPUT PROC
        MOV AH, 0AH
        LEA DX, KWHA 
        INT 21H
        
        CALL INPUT_INT

        RET
    INPUT ENDP
    
    INPUT_INT PROC
        MOV BX, 0
        MOV CX, 0
        MOV DX, 0
        MOV AX, 0
        MOV SI, OFFSET KWHA + 2
        CNV:
            
            CMP [SI], 0DH
            JE END_C
            
            MOV AL, [SI]
            SUB AL, 48
            MOV NUM, AX
            
            MOV AX, CX
            MUL MLP
            
            ADD AX, NUM
            MOV CX, AX
            
            INC SI
            JMP CNV
        END_C:         
        RET
    INPUT_INT ENDP
    
    NEW_LINE PROC
        
        MOV AH, 02H
        MOV DL, 10
        INT 21H
        
        MOV DL, 13
        INT 21H
        RET
        
    NEW_LINE ENDP

    MAIN PROC
        
        MOV AX, @DATA
        MOV DS, AX
        
        CALL MAIN_MENU
        
        CMP DL, 1
        JE  CB
        JMP END
        
        CB:
            CALL CALCULATE_BILL
        
        END:           
        
        MOV AH, 4CH
        INT 21H
        
    END MAIN