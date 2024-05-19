.MODEL SMALL
.DATA
    ;PROMPTS
    OPTION DB "GAS STATION$"
    OPTION1 DB "[1] DIESEL$"
    OPTION2 DB "[2] GAS$"
    OPTION3 DB "GAS TYPE: $"
    
    SELECTED_D DB "CURRENT GAS TYPE : DIESEL$"
    SELECTED_G DB "CURRENT GAS TYPE : GAS$"
    
    LITER_MSG DB "NO OF LITERS : $"
    PRICE_MSG DB "TOTAL PRICE: $"
    CASH_MSG DB "CASH : $"
    CHANGE_MSG DB "CHANGE : $"
    
    INVALID_MSG DB "INPUT IS INVALID$"
    
    ;INPUTS
    RATE DB ?
    LITER DB 2 DUP(?)
    CASH DB 10 DUP(?)
    CHANGE DB 10 DUP('*')
    PRICE DB 3 DUP(?)
    G_TYPE DB ?
    
    ;ARITHMETIC
    CARRY DB 0
    BORROW DB 0
    PRODUCT DB ?
    DIFFERENCE DB ?
    
    ;UTILITIES
    CASH_SIZE DB 0
    PRICE_SIZE DB 0
    LEADING_ZERO DB 0
    LITER_SIZE DB 1
    
    
    
    
.CODE                                                                                   
    ; FUNCTIONALS
    ; DISPLAYS SELECTION
    MENU PROC
        MOV AH, 09H
        
        LEA DX, OPTION
        INT 21H
        
        MOV AH, 02H
        MOV DX, 10
        INT 21H
        MOV DX, 13
        INT 21H
        
        MOV AH, 09H
        LEA DX, OPTION1
        INT 21H
        
        CALL NEW_LINE
        
        MOV AH, 09H
        LEA DX, OPTION2
        INT 21H
        
        CALL NEW_LINE
        
        MOV AH, 09H
        LEA DX, OPTION3
        INT 21H
        
        RET
    MENU ENDP
    ; DISPLAYS NEW LINE
    NEW_LINE PROC
        MOV AH, 02H
        MOV DL, 10
        INT 21H
        
        MOV DL, 13
        INT 21H
        RET
    NEW_LINE ENDP
    
    RESET_VARIABLES PROC
        RET
    RESET_VARIABLES ENDP
    
    ;DISPLAY
    ; DISPLAY GAS TYPE
    DISPLAY_GAS_TYPE PROC
        CALL NEW_LINE
                
        CMP G_TYPE, 1
        JE  DIESEL:
        CMP G_TYPE, 2
        JE  GAS 
        
        DIESEL:
            CALL DISPLAY_SELECTED_D
            JMP END_CHOICE
        
        GAS:
            CALL DISPLAY_SELECTED_G
            JMP END_CHOICE
            
        END_CHOICE:
        RET
    DISPLAY_GAS_TYPE ENDP
    
    ; DISPLAY DIESEL
    DISPLAY_SELECTED_D PROC
        MOV AH, 09H
        LEA DX, SELECTED_D
        
        INT 21H
        RET
    DISPLAY_SELECTED_D ENDP
    
    ; DISPLAY GAS    
    DISPLAY_SELECTED_G PROC
        MOV AH, 09H
        LEA DX, SELECTED_G
        
        INT 21H
        RET
    DISPLAY_SELECTED_G ENDP
    
    ; DISPLAY TOTAL PRICE
    ; CALCULATES THE TOTAL PRICE USING A MODIFIED ADDER
    ; IT WORKS BY SEPARATING THE CARRY(QUOTIENT) FROM THE REMAINDER
    ; REMAINDER FROM THE AH REGISTER IS PUSH TO THE STACK
    ; WHILE THE QUOTIENT IS MOVED TO THE CARRY
    ; IF THERE IS EXCESS CARRY APPENDS THE REMAINING CARRY TO THE STACK
      
    DISPLAY_TOTAL_PRICE PROC
        MOV AH, 09H
        LEA DX, PRICE_MSG
        INT 21H
        
        MOV CX, 2
        MOV BL, LITER_SIZE
        
        CMP G_TYPE, 1
        JE  R_D
        JNE R_G
        
        R_D:
            MOV RATE, 5
            JMP CALCULATE_PRICE
        
        R_G:
            MOV RATE, 6
        
        CALCULATE_PRICE:
            
            MOV AL, LITER[BX]
            MUL RATE
            ADD AL, CARRY
            
            MOV DL, 10
            DIV DL
            
            MOV CARRY, AL
            
            MOV DH, AH
            MOV DL, 0
            PUSH DX
            
            DEC BX
            
            LOOP CALCULATE_PRICE
        
        CMP CARRY, 0
        JE  D_PRICE
        MOV DH, CARRY
        MOV DL, 0
        PUSH DX
        
        D_PRICE:         
        
        MOV CX, 2
        MOV AH, 02H
        MOV SI, OFFSET PRICE
        
        DISPLAY_PRICE:
            POP DX
            MOV DL, DH
            ADD DL, 48
            MOV [SI], DL
            
            INC SI
            INT 21H
            LOOP DISPLAY_PRICE
            
        MOV PRICE_SIZE, 2
        CMP CARRY, 0
        JE  D_PRICE_E
        
        MOV PRICE_SIZE, 3
        POP DX
        MOV DL, DH
        ADD DL, 48
        MOV [SI], DL
        INT 21H
        
        D_PRICE_E:
        MOV BX, 0 
        RET
    DISPLAY_TOTAL_PRICE ENDP
    
    DISPLAY_CHANGE PROC
        MOV AH, 09H
        LEA DX, CHANGE_MSG
        INT 21H
        
        MOV CL, CASH_SIZE
        MOV SI, 0
        
        COPY_CASH:
            MOV DL, CASH[SI]
            MOV CHANGE[SI], DL
            
            INC SI
            LOOP COPY_CASH

        MOV CL, PRICE_SIZE
        
        MOV SI, OFFSET PRICE
        MOV DL, PRICE_SIZE
        MOV DH, 0
        ADD SI, DX
        DEC SI
        
        
        MOV BL, CASH_SIZE
        DEC BL
        
        
                                
        SUBTRACT:
            MOV AL, [SI]
            SUB AL, 48
            MOV DL, CHANGE[BX]
            CMP CHANGE[BX], 0
            JE  ZERO_C
            JMP CONTINUE_S
            
            ZERO_C:
                CMP CHANGE[BX], AL
                JE  CONTINUE_ZC
                
                JMP CONTINUE_ZCG
                
                CONTINUE_ZC:
                    MOV AL, 1
                    AND AL, BORROW
                    JE  REDUCE
                    
                CONTINUE_ZCG:
                    CMP BORROW, 1
                    JNE ADD_T
                    JE  REDUCE_SI
                    
                    ADD_T:
                        ADD CHANGE[BX], 10
                        JMP CONTINUE_Z
                                          
                    REDUCE_SI:
                        ADD CHANGE[BX], 9
                        DEC BORROW
                    
                    CONTINUE_Z:
                        INC BORROW
                        JMP REDUCE
                    
            CONTINUE_S:
                CMP BORROW, 1
                JE  REDUCE_BORROW
                JMP CONTINUE_B
                
                REDUCE_BORROW:
                    DEC CHANGE[BX]
                    DEC BORROW
                CONTINUE_B:
                    MOV DL, CHANGE[BX]
                    CMP CHANGE[BX], AL
                    JL  BORROW_LEFT
                    JMP REDUCE
            
            BORROW_LEFT:
                ADD CHANGE[BX], 10
                INC BORROW
                
            REDUCE:
                SUB CHANGE[BX], AL
                        
            DEC BX
            DEC SI
            
            LOOP SUBTRACT
            
            CMP BORROW, 1
            JE CLEAR_BORROW
            JMP DISPLAY_CHF
            
            CLEAR_BORROW:
                CMP CHANGE[BX], 0
                JE  UPDATE_LEFT
                JMP UPDATE_NZ_LEFT
                UPDATE_LEFT:
                    MOV CHANGE[BX], 9
                    DEC BX
                    JMP CLEAR_BORROW
                UPDATE_NZ_LEFT:
                    DEC CHANGE[BX]
                    DEC BX
                            
            MOV BORROW, 0
            
            DISPLAY_CHF:
                MOV CX, 10
                MOV SI, OFFSET CHANGE
                
                IGNORE_LEADING_ZEROES:
                    MOV DL, [SI]
                    
                    CMP DL, 0
                    JNE END_ILZ
                    INC SI
                    LOOP IGNORE_LEADING_ZEROES
                    
                END_ILZ:
                    MOV AH, 02H
                    CMP CL, 0
                    JE  DISPLAY_ZC
                    CMP DL, 42
                    JE  DISPLAY_ZC
                    JMP DISPLAY_CH
                    
                    DISPLAY_ZC:
                        MOV DL, 48
                        INT 21H
                        JMP END_CH
                        
                    DISPLAY_CH:
                        MOV DL, [SI]
                        CMP DL, 42
                        JE  END_CH
                        ADD DL, 48
                        INC SI
                        INT 21H
                        LOOP DISPLAY_CH
                                   
                          
        END_CH:
            MOV CX, 0    
            RET
    DISPLAY_CHANGE ENDP
       
    VALIDATE PROC
        CMP AL, 47
        JL INVALID
        CMP AL, 58
        JG INVALID
        
        RET
        
        INVALID:
            CALL INVALID_PROMPT
        
        RET
    VALIDATE ENDP
    
    INVALID_PROMPT PROC
        MOV AH, 09H
        LEA DX, INVALID_MSG
        INT 21H
        RET
    INVALID_PROMPT ENDP
    
    ;USER INPUT
    GAS_TYPE PROC
        
        MOV AH, 01H
        INT 21H  
        SUB AL, 48
        MOV G_TYPE, AL
        
        RET
    GAS_TYPE ENDP
    
    LITER_INPUT PROC
        MOV AH, 09H
        LEA DX, LITER_MSG
        INT 21H
        
        MOV AH, 01H
        MOV CX, 2
        MOV SI, OFFSET LITER
        
        L_INPUT:
            INT 21H
            SUB AL, 48
            MOV [SI], AL            
            
            
            INC SI
            
            LOOP L_INPUT
            
        RET
    LITER_INPUT ENDP
    
    CASH_INPUT PROC
        MOV AH, 09H
        LEA DX, CASH_MSG
        INT 21H
        
        MOV CX, 10
        MOV AH, 01H
       
        
        MOV SI, OFFSET CASH
        
        C_INPUT:
            INT 21H
            ;CALL VALIDATE
            
            CMP AL, 13
            JE END_LOOP
            
            INC CASH_SIZE
            SUB AL, 48
            MOV [SI], AL        
            
            INC SI
            LOOP C_INPUT
        END_LOOP:
            MOV CX, 0
            
        RET    
    CASH_INPUT ENDP
    
    MAIN PROC
        MOV AX, @DATA
        MOV DS, AX
        
        CALL MENU
        
        ;CALL CASH_INPUT
        
        CALL GAS_TYPE
        
        CALL DISPLAY_GAS_TYPE        
        CALL NEW_LINE
        
        CALL LITER_INPUT
        CALL  NEW_LINE
        
        CALL DISPLAY_TOTAL_PRICE
        CALL  NEW_LINE
        
        CALL CASH_INPUT
        CALL  NEW_LINE
        
        CALL DISPLAY_CHANGE   
        MOV AH, 4CH
        INT 21H
    END MAIN
       
