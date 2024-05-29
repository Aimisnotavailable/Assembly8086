.MODEL SMALL 

.DATA
    ;CONSTANT UTILS
    MAX_NAME_SIZE EQU 40
    MAX_ID_SIZE EQU 10
    MAX_STUDENT_COUNT EQU 40
    
    ;UTILS
    NAME_MSG DB 'Name: $'
    ID_MSG DB 'ID: $'
    ;COUNTERS
    CURRENT_STUDENT_COUNT DB 0
    
    ;STORAGE
    STUDENT_NAMES      DB MAX_NAME_SIZE * MAX_STUDENT_COUNT DUP('*')
    STUDENT_IDS        DB MAX_ID_SIZE * MAX_STUDENT_COUNT DUP('*')
    SEARCH_ID          DB MAX_ID_SIZE DUP ('*')
    STUDENT_NAME_SIZES DB MAX_STUDENT_COUNT DUP(0)
    
    ;MENU OPTIONS
    MENU_TEXT          DB 'Options:', 0Dh, 0Ah, '[1] Add', 0Dh, 0Ah, '[2] Search', 0Dh, 0Ah, '[3] Display All', 0Dh, 0Ah, '[4] Exit', 0Dh, 0Ah, 0Dh, 0Ah, 'Enter your choice: $'
    PROMPT_NAME        DB 0Dh, 0Ah, 'Enter student name: $'
    PROMPT_ID          DB 0Dh, 0Ah, 'Enter student ID: $'
    PROMPT_SEARCH_ID   DB 0Dh, 0Ah, 'Enter student ID to search: $'
    ; CURRENT_DATE       DB DATE_LEN DUP('$')  ; Buffer to store the current date 
    
    CHOICE DB ?
    FOUND DB 0
    NEXT DW ?
    COUNTER DW 0
    SEARCH_IND DW 0
    SINGLE_STUDENT DB 0
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
    
    INPUT_STUDENT_DATA PROC
        
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
    INPUT_STUDENT_DATA ENDP
    
    PRINT_STUDENT_DATA PROC 
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
    PRINT_STUDENT_DATA ENDP
    
    SEARCH_STUDENT PROC
        
        
        SEARCH:
            
            MOV AX, COUNTER
            
            CMP AL, CURRENT_STUDENT_COUNT
            JE END_SEARCH
            
            MOV BH, 0
            MOV BL, MAX_ID_SIZE
            MUL BX
              
            MOV BX, AX
            MOV SI, OFFSET SEARCH_ID
            
            MOV CL, MAX_ID_SIZE
            
            COMPARE:
                MOV AL, [SI] 
                
                MOV AH, STUDENT_IDS[BX]
                
                CMP STUDENT_IDS[BX], AL
                JNE CONTINUE_SEARCH
                
                
                CMP STUDENT_IDS[BX], 42
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
        
        RET
    SEARCH_STUDENT ENDP
    
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
            JE  INPUT_STUDENT_NAME
            CMP CHOICE, 32H
            JE  SEARCH_STUDENT_LABEL       
            CMP CHOICE, 33H
            JE  PRINT_STUDENT_DATA_LABEL
            CMP CHOICE, 34H
            JE  EXIT
            JMP MENU_INTERFACE
            
            INPUT_STUDENT_NAME:
                MOV AL, MAX_STUDENT_COUNT
                CMP CURRENT_STUDENT_COUNT, AL
                JE MENU_INTERFACE
                
                ;PARAM
                MOV AH, 09H
                LEA DX, PROMPT_NAME
                INT 21H
                
                MOV AH, 0
                MOV AL, CURRENT_STUDENT_COUNT
                
                MOV BH, 0
                MOV BL, MAX_NAME_SIZE
                
                MUL BX
                
                MOV CX, 0
                MOV CL, MAX_NAME_SIZE
                
                MOV SI, OFFSET STUDENT_NAMES
                ADD SI, AX
                
                CALL INPUT_STUDENT_DATA
                
                ;PARAM
                
                MOV AH, 09H
                LEA DX, PROMPT_ID
                INT 21H
                
                MOV AH, 0
                MOV AL, CURRENT_STUDENT_COUNT
                
                MOV BH, 0
                MOV BL, MAX_ID_SIZE
                
                MUL BX
                
                MOV CX, 0
                MOV CL, MAX_ID_SIZE
                
                MOV SI, OFFSET STUDENT_IDS
                ADD SI, AX
                  
                CALL INPUT_STUDENT_DATA                  
                                                         
                ;RETURN VALUES                           
                INC  CURRENT_STUDENT_COUNT               
                                                         
                JMP MENU_INTERFACE                       
                                                         
            PRINT_STUDENT_DATA_LABEL:                          
                
                MOV CX, 0
                
                PRINT_LOOP:

                    CALL NAME_PROMPT
                    ;PARAM
                    MOV AX, 0
                    
                    MOV AL, CL
                    MOV BX, 0
                    MOV BL, MAX_NAME_SIZE
                    
                    MUL BX
                    
                    MOV SI, OFFSET STUDENT_NAMES
                    ADD SI, AX
                    CALL PRINT_STUDENT_DATA
                    
                    CALL NEW_LINE
                    
                    CALL ID_PROMPT
                    
                    ;PARAM
                    MOV AX, 0                       
                    MOV AL, CL
                    MOV BX, 0
                    MOV BL, MAX_ID_SIZE
                    
                    MUL BX
                                           
                    MOV SI, OFFSET STUDENT_IDS
                    ADD SI, AX
                    
                    CALL PRINT_STUDENT_DATA
                    
                    INC CL
                    CMP CL, CURRENT_STUDENT_COUNT
                    
                    CALL NEW_LINE
                    JL PRINT_LOOP
                
                MOV AH, 01H
                INT 21H
                
                JMP MENU_INTERFACE
            
            SEARCH_STUDENT_LABEL:
                
                MOV AH, 09H
                LEA DX, PROMPT_SEARCH_ID
                INT 21H
                
                ; PARAM
                
                MOV CX, 0
                MOV CL, MAX_ID_SIZE
                
                MOV SI, OFFSET SEARCH_ID
                
                CALL INPUT_STUDENT_DATA

                CALL SEARCH_STUDENT
                
                MOV AL, 1
                AND AL, FOUND
                JZ  NOT_FOUND
                
                CALL NEW_LINE
                
                CALL NAME_PROMPT
                
                ;PARAM
                MOV AX, SEARCH_IND
                MOV BL, MAX_NAME_SIZE
                MUL BX
                
                MOV SI, OFFSET STUDENT_NAMES
                ADD SI, AX
                
                CALL PRINT_STUDENT_DATA
                
                CALL NEW_LINE
                
                CALL ID_PROMPT
                
                ;PARAM
                
                MOV AX, SEARCH_IND
                MOV BL, MAX_ID_SIZE
                MUL BX
                
                MOV SI, OFFSET STUDENT_IDS
                ADD SI, AX
                
                CALL PRINT_STUDENT_DATA
                
                NOT_FOUND:
                CALL NEW_LINE
                
                MOV FOUND, 0
                
                CALL CLEAR_UTILS
                MOV AH, 01H
                INT 21H
                
                JMP MENU_INTERFACE
                   
        
        
        EXIT:                
        MOV AH, 4CH
        INT 21H
    END MAIN