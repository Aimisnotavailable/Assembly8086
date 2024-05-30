
.MODEL SMALL 

.DATA
    ;CONSTANT UTILS
    MAX_NAME_SIZE EQU 40
    MAX_ID_SIZE EQU 10
    MAX_VEHICLE_COUNT EQU 10
    
    ;UTILS
    NAME_MSG DB 'VEHICLE: $'
    ID_MSG DB 'ID: $'
    SLOT_MSG DB 'SLOT: $'
    NOT_FOUND_MSG DB 'VEHICLE NOT FOUND$'
    VEHICLE_DELETED_MSG DB 'VEHICLE DELETED$'
    
    EMPTY_REGISTRY_MSG DB 'THE PARKING LOT IS EMPTY$'
    FULL_LOT_MSG DB 'THE PARKING LOT IS FULL$'
    
    VEHICLE_PRINTED DB 0
    VEHICLE_SEARCHED DB 0
    
    ;COUNTERS
    CURRENT_VEHICLE_COUNT DB 0
    COUNTER DW 0
    
    ;STORAGE
    VEHICLE_NAMES      DB MAX_NAME_SIZE * MAX_VEHICLE_COUNT DUP('*')
    VEHICLE_IDS        DB MAX_ID_SIZE * MAX_VEHICLE_COUNT DUP('*')
    SEARCH_ID          DB MAX_ID_SIZE DUP ('*')
    TAKEN_LIST         DB MAX_VEHICLE_COUNT DUP (0)
    
    ;MENU OPTIONS
    MENU_TEXT          DB 'Options:', 0Dh, 0Ah, '[1] Add', 0Dh, 0Ah,
                       DB   '[2] Search', 0Dh, 0Ah, 
                       DB   '[3] Display All', 0Dh, 0Ah,
                       DB   '[4] Leave ', 0DH, 0AH, 
                       DB   '[5] Exit', 0Dh, 0Ah,
                       DB    0Dh, 0Ah, 'Enter your choice: $'
                           
    PROMPT_NAME        DB 0Dh, 0Ah, 'Enter vehicle: $'
    PROMPT_ID          DB 0Dh, 0Ah, 'Enter vehicle ID: $'
    PROMPT_SEARCH_ID   DB 0Dh, 0Ah, 'Enter vehicle ID to search: $' 
    
    CHOICE DB ?
    FOUND DB 0
    NEXT DW ?
    SEARCH_IND DW 0
    SLOT_SIZE DB 0
    CURRENT_SLOT DB 0
    
    AVAILABLE_SLOT DB 0
    
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
    
    CLEAR_UTILS PROC
        
        MOV CX, 10
        MOV SI, OFFSET SEARCH_ID
        
        CLEAR_LOOP:
            MOV DL, [SI]
            MOV [SI], 42
            INC SI
            LOOP CLEAR_LOOP 
        RET
    CLEAR_UTILS ENDP
    
    NAME_PROMPT PROC
        
        MOV AH, 09H
        LEA DX, NAME_MSG
        INT 21H
        
        RET
    NAME_PROMPT ENDP
        
        
    ID_PROMPT PROC
        
        MOV AH, 09H
        LEA DX, ID_MSG
        INT 21H
        
        RET
    ID_PROMPT ENDP
    ;DISPLAYS
    
    MENU PROC
        
        MOV AH, 09H
        LEA DX, MENU_TEXT
        INT 21H
         
        RET
    MENU ENDP
      
    ;INPUTS
    
    INPUT_PRMPT PROC
        
        MOV AH, 01H
        INT 21H
        
        RET
    INPUT_PRMPT ENDP
    
    INPUT_VEHICLE_DATA PROC
        
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
    INPUT_VEHICLE_DATA ENDP
    
    PRINT_VEHICLE_DATA PROC 
        MOV AH, 02H    
        PRINT_DATA:
            MOV DL, [SI]
            
            CMP DL, 42
            JE  END_PSD
            
            INT 21H
            INC SI
            
            JMP PRINT_DATA
            
        END_PSD:    
        RET
    PRINT_VEHICLE_DATA ENDP
    
    SEARCH_PROMPT PROC
        MOV AH, 09H
        LEA DX, PROMPT_SEARCH_ID
        INT 21H
        
        ; PARAM
        
        MOV CX, 0
        MOV CL, MAX_ID_SIZE
        
        MOV SI, OFFSET SEARCH_ID
        
        CALL INPUT_VEHICLE_DATA

        CALL SEARCH_VEHICLE
        RET
    SEARCH_PROMPT ENDP
    
    SEARCH_VEHICLE PROC
        
        MOV CX, 0
        
        SEARCH:
            MOV SI, OFFSET TAKEN_LIST
            ADD SI, COUNTER
            
            MOV AX, MAX_VEHICLE_COUNT
            CMP COUNTER, AX
            JE  END_SEARCH
            
            CMP [SI], 0
            JE CONTINUE_SEARCH
            
            MOV AH, 0
            MOV AL, CURRENT_VEHICLE_COUNT
            
            CMP VEHICLE_SEARCHED, AL
            JE END_SEARCH
            
            INC VEHICLE_SEARCHED
            
            MOV AX, COUNTER
            
            MOV BH, 0
            MOV BL, MAX_ID_SIZE
            MUL BX
              
            MOV BX, AX
            
            MOV SI, OFFSET SEARCH_ID
            
            MOV CL, MAX_ID_SIZE
            
            COMPARE:
                MOV AL, [SI] 
                
                MOV AH, VEHICLE_IDS[BX]
                
                CMP VEHICLE_IDS[BX], AL
                JNE CONTINUE_SEARCH
                
                
                CMP VEHICLE_IDS[BX], 42
                JE  FOUND_SEARCH
                
                INC BX
                INC SI                     
                LOOP COMPARE
                
            JMP FOUND_SEARCH
            
            CONTINUE_SEARCH:
                INC COUNTER
                JMP SEARCH
        
        FOUND_SEARCH:
            MOV FOUND, 1
        
        END_SEARCH:
        MOV CX, COUNTER
        MOV SEARCH_IND, CX        
        MOV COUNTER, 0
        MOV VEHICLE_SEARCHED, 0
        
        RET
    SEARCH_VEHICLE ENDP
    
    SEARCH_SLOT PROC
        MOV CX, 0
        MOV SI, OFFSET TAKEN_LIST
        
        SEARCH_AVAILABLE_SLOT:
            CMP [SI], 0
            JE  END_SEARCH_SLOT
            
            CMP CL, MAX_VEHICLE_COUNT
            JE  END_SEARCH_SLOT
            INC SI
            INC CL
            JMP SEARCH_AVAILABLE_SLOT
                
        END_SEARCH_SLOT:
        
            MOV AVAILABLE_SLOT, CL
         
        RET
    SEARCH_SLOT ENDP
    
    DELETE_VEHICLE_DATA PROC
        
        DELETE_LOOP:
            CMP [SI], 42
            JE END_D
            
            MOV [SI], 42
            INC SI
            JMP DELETE_LOOP
        
        END_D:
            
        RET
    DELETE_VEHICLE_DATA ENDP
    
    DISPLAY_SLOT PROC
        
        MOV AH, 09H
        LEA DX, SLOT_MSG
        INT 21H
        
        MOV AH, 0
        MOV AL, CURRENT_SLOT
        INC AL
        
        CONVERT_INT:
        
            MOV DL, 10
            
            DIV DL
            
            MOV DH, 0
            MOV DL, AH
            
            PUSH DX
            
            MOV AH, 0
            INC SLOT_SIZE
            CMP AL, 0
            JNE  CONVERT_INT
            
        MOV CL, SLOT_SIZE
        MOV AH, 02H
        
        DISPLAY_INT:
            
            POP DX
            
            ADD DL, 48
            
            INT 21H
            LOOP DISPLAY_INT
         
        MOV SLOT_SIZE, 0        
        
        RET
    DISPLAY_SLOT ENDP
    
    MAIN PROC
        
        MOV AX, @DATA
        MOV DS, AX
        
        MENU_INTERFACE:
            
            MOV AX, 03H
            INT 10H
             
            CALL MENU
            
            CALL INPUT_PRMPT
            
            MOV CHOICE, AL
            
            CALL NEW_LINE
                   
            CMP CHOICE, 31H
            JE  INPUT_VEHICLE_NAME
            CMP CHOICE, 32H
            JE  SEARCH_VEHICLE_LABEL       
            CMP CHOICE, 33H
            JE  PRINT_VEHICLE_DATA_LABEL
            CMP CHOICE, 34H
            JE  LEAVE_VEHICLE
            CMP CHOICE, 35H
            JE  EXIT
            JMP MENU_INTERFACE
            
            INPUT_VEHICLE_NAME:
                
                CALL SEARCH_SLOT
                
                MOV  AL, AVAILABLE_SLOT
                
                CMP AL, MAX_VEHICLE_COUNT - 1
                JE  FULL_PARKING
                
                MOV  CURRENT_SLOT, AL
                    
                CALL DISPLAY_SLOT
                MOV  CURRENT_SLOT, 0
                CALL NEW_LINE
                
                ;PARAM
                MOV AH, 09H
                LEA DX, PROMPT_NAME
                INT 21H
                
                MOV AH, 0
                MOV AL, AVAILABLE_SLOT
                
                MOV BH, 0
                MOV BL, MAX_NAME_SIZE
                
                MUL BX
                
                MOV CX, 0
                MOV CL, MAX_NAME_SIZE
                
                MOV SI, OFFSET VEHICLE_NAMES
                ADD SI, AX
                
                CALL INPUT_VEHICLE_DATA
                
                ;PARAM
                
                MOV AH, 09H
                LEA DX, PROMPT_ID
                INT 21H
                
                MOV AH, 0
                MOV AL, AVAILABLE_SLOT
                
                MOV BH, 0
                MOV BL, MAX_ID_SIZE
                
                MUL BX
                
                MOV CX, 0
                MOV CL, MAX_ID_SIZE
                
                MOV SI, OFFSET VEHICLE_IDS
                ADD SI, AX
                  
                CALL INPUT_VEHICLE_DATA                  
                
                MOV BH, 0
                MOV BL, AVAILABLE_SLOT
                MOV AVAILABLE_SLOT, 0
                MOV TAKEN_LIST[BX], 1
                                                         
                ;RETURN VALUES                           
                INC  CURRENT_VEHICLE_COUNT               
                                                         
                JMP MENU_INTERFACE                       
            
            SEARCH_VEHICLE_LABEL:
                
                CMP  CURRENT_VEHICLE_COUNT, 0
                JE   EMPTY_REGISTRY
                
                CALL SEARCH_PROMPT
                
                MOV AL, 1
                AND AL, FOUND
                JZ  NOT_FOUND
                
                CALL NEW_LINE
                
                CALL NAME_PROMPT
                
                ;PARAM
                MOV AX, SEARCH_IND
                MOV BL, MAX_NAME_SIZE
                MUL BX
                
                MOV SI, OFFSET VEHICLE_NAMES
                ADD SI, AX
                
                CALL PRINT_VEHICLE_DATA
                
                CALL NEW_LINE
                
                CALL ID_PROMPT
                
                ;PARAM
                
                MOV AX, SEARCH_IND
                MOV BL, MAX_ID_SIZE
                MUL BX
                
                MOV SI, OFFSET VEHICLE_IDS
                ADD SI, AX
                
                CALL PRINT_VEHICLE_DATA
                
                CALL NEW_LINE
                
                MOV BX, SEARCH_IND 
                MOV CURRENT_SLOT, BL
                CALL DISPLAY_SLOT
                
                MOV CURRENT_SLOT, 0
                
                MOV FOUND, 0
                MOV SEARCH_IND, 0
                
                CALL CLEAR_UTILS
                MOV AH, 01H
                INT 21H
                
                JMP MENU_INTERFACE
                                                             
            PRINT_VEHICLE_DATA_LABEL:
            
                CMP  CURRENT_VEHICLE_COUNT, 0
                JE   EMPTY_REGISTRY                          
                
                MOV CX, 0
                 
                PRINT_LOOP:
                    MOV SI, OFFSET TAKEN_LIST
                    ADD SI, CX
                    CMP [SI], 0
                    JE  CONTINUE_PRINT
                    
                    CALL NAME_PROMPT
                    ;PARAM
                    MOV AX, 0
                    
                    MOV AL, CL
                    MOV BX, 0
                    MOV BL, MAX_NAME_SIZE
                    
                    MUL BX
                    
                    MOV SI, OFFSET VEHICLE_NAMES
                    ADD SI, AX
                    CALL PRINT_VEHICLE_DATA
                    
                    CALL NEW_LINE
                    
                    CALL ID_PROMPT
                    
                    ;PARAM
                    MOV AX, 0                       
                    MOV AL, CL
                    MOV BX, 0
                    MOV BL, MAX_ID_SIZE
                    
                    MUL BX
                                           
                    MOV SI, OFFSET VEHICLE_IDS
                    ADD SI, AX
                    
                    CALL PRINT_VEHICLE_DATA
                    
                    CALL NEW_LINE
                    
                    CALL DISPLAY_SLOT
                    
                    INC VEHICLE_PRINTED
                    CALL NEW_LINE
                    CALL NEW_LINE
                    
                    CONTINUE_PRINT:
                         
                        INC CURRENT_SLOT
                        
                        MOV CL, CURRENT_SLOT
                        
                        MOV BH, 0
                        MOV BL, VEHICLE_PRINTED
                        CMP BL, CURRENT_VEHICLE_COUNT
                        
                    JNE PRINT_LOOP
                
                MOV VEHICLE_PRINTED, 0
                MOV CURRENT_SLOT, 0
                
                MOV AH, 01H
                INT 21H
                
                JMP MENU_INTERFACE
           
            LEAVE_VEHICLE:
                
                CMP  CURRENT_VEHICLE_COUNT, 0
                JE   EMPTY_REGISTRY
                
                CALL SEARCH_PROMPT
                
                MOV AL, 1
                AND AL, FOUND
                JZ  NOT_FOUND
                
                MOV AX, SEARCH_IND
                
                MOV BX, 0
                MOV BX, MAX_NAME_SIZE
                
                MUL BX
               
                MOV SI, OFFSET VEHICLE_NAMES
                ADD SI, AX
                
                CALL DELETE_VEHICLE_DATA
                
                MOV AX, SEARCH_IND
                
                MOV BX, 0
                MOV BX, MAX_ID_SIZE
                MUL BX
               
                MOV SI, OFFSET VEHICLE_IDS
                ADD SI, AX
                
                CALL DELETE_VEHICLE_DATA
                
                CALL NEW_LINE
                
                DEC CURRENT_VEHICLE_COUNT
                
                MOV BX, SEARCH_IND
                MOV TAKEN_LIST[BX], 0
                
                MOV AH, 09H
                LEA DX, VEHICLE_DELETED_MSG
                INT 21H
                
                MOV AH, 01H
                INT 21H
                
                CALL CLEAR_UTILS
            
                MOV FOUND, 0
                MOV SEARCH_IND, 0
                
                JMP MENU_INTERFACE
                
        
        NOT_FOUND:
            CALL NEW_LINE
            
            MOV AH, 09H
            LEA DX, NOT_FOUND_MSG
            INT 21H
            
            MOV AH, 01H
            INT 21H
            
            CALL CLEAR_UTILS
            
            MOV FOUND, 0
            MOV SEARCH_IND, 0
            
            JMP MENU_INTERFACE
        
        FULL_PARKING:
            CALL NEW_LINE
            
            MOV AH, 09H
            LEA DX, FULL_LOT_MSG
            INT 21H
            
            MOV AH, 01H
            INT 21H
            
            JMP MENU_INTERFACE
            
        EMPTY_REGISTRY:
            CALL NEW_LINE
            
            MOV AH, 09H  
            LEA DX, EMPTY_REGISTRY_MSG
            INT 21H
            
            MOV AH, 01H
            INT 21H
            
            JMP MENU_INTERFACE
                              
        EXIT:                
        MOV AH, 4CH
        INT 21H
        
    END MAIN