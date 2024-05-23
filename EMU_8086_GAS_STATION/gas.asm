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
    
    ;UTILITIES
    CASH_SIZE DB 0
    PRICE_SIZE DB 0
    LEADING_ZERO DB 0
    LITER_SIZE DB 0
    
    
    
    
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
        MOV LITER_SIZE, 0
        MOV PRICE_SIZE, 0
        MOV CASH_SIZE, 0
        MOV CX, 10
        MOV SI, OFFSET CHANGE
        RESET_CHANGE:
            MOV [SI], 42
            INC SI
            LOOP RESET_CHANGE
            
        MOV CX, 0
        MOV BX, 0
        MOV DX, 0
        ; CLEAR SCREEN
        MOV AX, 03H
        INT 10H
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
        
        
        MOV CL, LITER_SIZE
        
        ;SETS THE INDEX TO THE LAST NUMBER OF THE LITER INPUT
        MOV BL, LITER_SIZE
        DEC BL
        
        CMP G_TYPE, 1
        ;UPDATES RATE
        JE  R_D
        JNE R_G
        
        R_D:
            MOV RATE, 5
            JMP CALCULATE_PRICE
        
        R_G:
            MOV RATE, 6
         
        CALCULATE_PRICE:
            ; ACCESS THE LAST LITER VARIABLE
            ; MULTIPLY IT BY RATE
            MOV AL, LITER[BX]
            MUL RATE
            ADD AL, CARRY
            
            ; OPERATION GOES
            ; E.G. 12 * 5
            ; 2 * 5 + CARRY(0) = 10
            ; 10/ 10 = 1 R. 0
            ; SAVES THE CARRY = 1
            ; PUSH REMAINDER TO THE STACK
            ; 1 * 5 + CARRY(1) = 5
            ; 5 / 10 = 0 R. 5
            ; SAVES THE CARRY = 0
            ; PUSH THE REMAINDER TO THE STACK
            ; STACK NOW HAS 5->0 
            
            
            ; SEPARATES THE REMAINDER AND THE QUOTIENT
            ; REMAINDER WILL SERVE AS THE VALUE WHILE QUOTIENT IS THE CARRY
            ; REMAINDER IS STORED IN AH, QUOTIENT IS IN AL
            
            MOV DL, 10
            DIV DL
            
            ; UPDATES CARRY
            MOV CARRY, AL
            
            ; MIGRATES THE REMAINDER TO THE DX REGISTER
            ; INSERT AH VALUE TO THE DH REGISTER
            ; CLEAR DL REGISTER
            ; PUSH DX REGISTER
            MOV DH, AH
            MOV DL, 0
            PUSH DX
            
            DEC BX
            
            INC PRICE_SIZE
            
            LOOP CALCULATE_PRICE
        ; CHECKS IF THERE IS A STILL REMAINING CARRY TO THE STACK AFTER EVALUATING ALL LITER DIGITS
        ; IF YES APPENDS IT TO THE STACK
        ; CLEARS THE CARRY
        CMP CARRY, 0
        JE  D_PRICE
        MOV DH, CARRY
        MOV DL, 0
        PUSH DX
        INC PRICE_SIZE
        
        MOV CARRY, 0
        
        D_PRICE:         
        
        MOV CL, PRICE_SIZE
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
        ; CREATES A COPY OF CASH TO KEEP CASH VALUE AND CHANGE FOR RECEIPT
        COPY_CASH:
            MOV DL, CASH[SI]
            MOV CHANGE[SI], DL
            
            INC SI
            LOOP COPY_CASH
        
        ; PREPARES REGISTER TO COMPUTE FOR CHANGE
        MOV CL, PRICE_SIZE
        ; MOVES TO THE LAST ELEMENT OF THE PRICE ARRAY
        MOV SI, OFFSET PRICE
        MOV DL, PRICE_SIZE
        MOV DH, 0
        ADD SI, DX
        DEC SI
        
        ; PREPARES ANOTHER POINTER TO POINT AT THE LAST ELEMENT OF THE CHANGE ARRAY
        MOV BL, CASH_SIZE
        DEC BL
        
        ; PERFORMS SUBTRACTION                       
        SUBTRACT:
            ; SUBTRACTION WORKS BY ALLOCATING A VARIABLE FOR BORROW
            ; TAKES ALL POSSIBLE CASES OF SUBTRACTION
            ; E.G. 110 - 100
            ; 0 - 0 CASE IS 0
            ; 0 - 1 CASE IS ADDS 10
            ; 7 - 8 LESSER THAN CASE ADDS 10
            ; 7 - BORROW - 7 LESSER THAN CASE ADDS 10
            ; 7 - BORROW - 6 UPDATES BORROW TO 0
            ; 6 - 6 UPDATES BORROW TO 0
            ; PERFORMS BORROW REDUCTION FIRST BEFORE PERFORMING SUBTRACTION
            ; NOTE: 0 - BORROW - 0 CASE REPLACES VALUE TO 9
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
            
            ; CLEARS THE REMAINING BORROW TO THE LEFT OF THE ARRAY UNTIL IT FINDS VALUES GREATER THAN 0 TO DECREMENT
            ; ELSE TURNS ALL 0 TO 9
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
                ; IGNORES LEADING ZEROES BY SIMPLE INCREMENTING THE SI POINTER TO THE NEXT VALUE IF THE CURRENT VALUE IS EQUAL TO 0
                IGNORE_LEADING_ZEROES:
                    MOV DL, [SI]
                    
                    CMP DL, 0
                    JNE END_ILZ
                    INC SI
                    LOOP IGNORE_LEADING_ZEROES
                    
                ; PRINTS THE REMAINDER OF THE ARRAY
                ; IF THE LOOP REACHES 0 OR ALL VALUES ARE EVALUATED PRINTS 0
                ; IF THE LOOP FOUNDS THE END OF THE CHANGE ASCII 42 CHARACTER(*) PRINTS 0    
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
            CMP AL, 13
            JE END_L
            SUB AL, 48
            
            MOV [SI], AL
            
            INC LITER_SIZE                        
            INC SI
            
            LOOP L_INPUT
        
        END_L:
        
        MOV CX, 0
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
        
        START:
        
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
            
            MOV AH, 01H
            INT 21H
            
            CALL RESET_VARIABLES
            JMP START
                
        MOV AH, 4CH
        INT 21H
    END MAIN
       
