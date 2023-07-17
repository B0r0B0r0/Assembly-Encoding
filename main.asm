    DOSSEG
    .MODEL SMALL
    .STACK 32
    .DATA
encoded     DB  80 DUP(0)
temp        DB  '0x', 160 DUP(0)
fileHandler DW  ?
filename    DB  'in/in.txt', 0          ; Trebuie sa existe acest fisier 'in/in.txt'!
outfile     DB  'out/out.txt', 0        ; Trebuie sa existe acest director 'out'!
message     DB  80 DUP(0)
msglen      DW  ?
padding     DW  0
iterations  DW  0 
encodeLen   DW  0
x           DW  ?
x0          DW  ?
a           DW  0
b           DW  0
nume        DB 'Bordei0'
prenume     DB 'Alin0'
CODE64      DB 'Bqmgp86CPe9DfNz7R1wjHIMZKGcYXiFtSU2ovJOhW4ly5EkrqsnAxubTV03a=L/d'
    .CODE
START:
    MOV     AX, @DATA
    MOV     DS, AX

    


    CALL    FILE_INPUT                  ; NU MODIFICATI!
    
    CALL    SEED                        ; TODO - Trebuie implementata

    CALL    ENCRYPT                     ; TODO - Trebuie implementata
    
    CALL    ENCODE                      ; TODO - Trebuie implementata
    
                                        ; Mai jos se regaseste partea de
                                        ; afisare pe baza valorilor care se
                                        ; afla in variabilele x0, a, b, respectiv
                                        ; in sirurile message si encoded.
                                        ; NU MODIFICATI!
    MOV     AH, 3CH                     ; BIOS Int - Open file
    MOV     CX, 0
    MOV     AL, 1                       ; AL - Access mode ( Write - 1 )
    MOV     DX, OFFSET outfile          ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    CALL    WRITE                       ; NU MODIFICATI!

    MOV     AH, 4CH                     ; Bios Int - Terminate with return code
    MOV     AL, 0                       ; AL - Return code
    INT     21H
FILE_INPUT:
    MOV     AH, 3DH                     ; BIOS Int - Open file
    MOV     AL, 0                       ; AL - Access mode ( Read - 0 )
    MOV     DX, OFFSET fileName         ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    MOV     AH, 3FH                     ; BIOD Int - Read from file or device
    MOV     BX, [fileHandler]           ; BX - File handler
    MOV     CX, 80                      ; CX - Number of bytes to read
    MOV     DX, OFFSET message          ; DX - Data buffer
    INT     21H
    MOV     [msglen], AX                ; Return: AX - number of read bytes

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H

    RET
SEED:
    MOV     AH, 2CH                     ; BIOS Int - Get System Time
    INT     21H



    ;Primul termen

    MOV     [x],DX
    MOV     AX,3600
    MOV     BL,CH
    MOV     BH,0
    MUL     BX
    MOV     [x0], DX     
    MOV     [x0+2], AX


    ;Al doilea termen

    MOV     AX,60
    MOV     BL,CL
    MOV     BH,0
    MUL     BX
    CLC
    ADD     AX,[x0+2]
    MOV     [x0+2],AX
    ADC     DX,[x0]
    MOV     [x0],DX

    ;Al treilea termen

    MOV     BX,[x]
    MOV     AX,0
    MOV     DX,0
    MOV     AL,BH
    CLC
    ADD     AX,[x0+2]
    MOV     [x0+2],AX
    ADC     DX,[x0]
    MOV     [x0],DX    

    ;Paranteza

    MOV     AX,0
    MOV     DX,0
    MOV     BX,[x0]
    MOV     AX,64h
    MUL     BX
    MOV     [x0],AX
    MOV     AX,0
    MOV     DX,0
    MOV     BX,[x0+2]
    MOV     AX,64H
    MUL     BX
    CLC
    MOV     [x0+2],AX
    MOV     BX,[x0]
    ADD     BX,DX
    MOV     [x0],BX   

    ;Al patrulea termen

    MOV     BX,[x]
    MOV     AX,0
    CLC
    MOV     AX,[x0+2]
    MOV     BH,0
    ADD     AX,BX
    MOV     [x0+2],AX
    MOV     BX,[x0]
    ADC     BX,0
    MOV     [x0],BX
    MOV     [x],0

    ;Ecuatia finala

    MOV     AX,[x0]
    MOV     BX,255
    MOV     DX,0
    DIV     BX
    MOV     [x0],DX
    MOV     AX,[x0+2]
    MOV     DX,0
    DIV     BX
    MOV     [x0+2],DX
    MOV     AX,[x0]
    MOV     BX,[x0+2]
    ADD     AX,BX
    MOV     BX,255
    MOV     DX,0
    DIV     BX
    MOV     [x0+2],0
    MOV     [x0],DX
    

    MOV     AX,[x0]
    MOV     [x],AX

                                        ; TODO1: Completati subrutina SEED
                                        ; astfel incat la final sa fie salvat
                                        ; in variabila 'x' si 'x0' continutul 
                                        ; termenului initial
    RET
ENCRYPT:
    MOV     CX, [msglen]
    MOV     DI, OFFSET message
    buclaEncrypt:
        MOV     AL,[DI]
        MOV     AH,0
        XOR     AX,[x]
        MOV     [DI],AL
        INC     DI
        CMP     CX,1
        JE      afterRand
        CALL    RAND
        afterRand:

    loop buclaEncrypt

                                            ; TODO3: Completati subrutina ENCRYPT
                                            ; astfel incat in cadrul buclei sa fie
                                            ; XOR-at elementul curent din sirul de
                                            ; intrare cu termenul corespunzator din
                                            ; sirul generat, iar mai apoi sa fie generat
                                            ; si termenul urmator
    RET
RAND:
    MOV     AX, [x]


    ;calculam a

    MOV     SI,OFFSET prenume
    MOV     DX,0
    
    bucla1:

        MOV BL,[SI]
        ADD DX,BX
        INC SI
        push CX
        MOV CL, '0'
        CMP [SI],CL
        pop CX
        JE sf_bucla1
        JMP bucla1

    sf_bucla1:

    MOV     AX,DX
    MOV     BX,255
    MOV     DX,0
    DIV     BX

    MOV     [a],DX

    ;calculam b

    MOV     SI,OFFSET nume
    MOV     DX,0
    
    
    bucla2:

        MOV BL,[SI]
        ADD DX,BX
        INC SI
        MOV BL,[SI]
        CMP BL,'0'
        
        JE sf_bucla2
        JMP bucla2

    sf_bucla2:

    MOV     AX,DX
    MOV     BX,255
    MOV     DX,0
    DIV     BX

    MOV [b],DX

    ;calculam ax

    MOV     AX,[x]
    MOV     BX,[a]
    MUL     BX

    ;calculam ax+b

    ADD     AX,[b]


    ;calculam (ax+b)/255

    MOV     BX,255
    MOV     DX,0    
    DIV     BX
    MOV     [x],DX

                                            ; TODO2: Completati subrutina RAND, astfel incat
                                            ; in cadrul acesteia va fi calculat termenul
                                            ; de rang n pe baza coeficientilor a, b si a 
                                            ; termenului de rang inferior (n-1) si salvat
                                            ; in cadrul variabilei 'x'

    RET
ENCODE:

    MOV     [padding],0

    bucla3:
        MOV     AX,[msglen]
        MOV     BX,8
        MUL     BX
        MOV     DX,0
        MOV     BX,6
        DIV     BX
        CMP     DX,0
        JE      sf_bucla3

        MOV     AL,0
        MOV     SI,OFFSET message
        ADD     SI,[msglen]
        MOV     [SI],AL
        INC     [msglen]
        INC     [padding]
        JMP     bucla3
    sf_bucla3:

    MOV     AX,[msglen]
    MOV     BX,3
    DIV     BX
    MOV     CX,AX
    MOV     SI, OFFSET message
    MOV     DI, OFFSET encoded
    translate:
        MOV     BL,[SI]
        SHR     BL,2
        INC     [encodeLen]

        CALL TRL
 


        MOV     BX,[SI]
        MOV     DL,BL
        MOV     DH,BH
        MOV     BH,DL
        MOV     BL,DH
        SHL     BX,6
        MOV     BL,BH
        MOV     BH,0
        SHR     BL,2
        INC     [encodeLen]
        CALL TRL

        INC SI

        MOV     BX,[SI]
        MOV     DL,BL
        MOV     DH,BH
        MOV     BH,DL
        MOV     BL,DH
        SHL     BX,4
        MOV     BL, BH
        MOV     BH,0

        SHR     BL,2
        INC     [encodeLen]
        CALL TRL
        
        INC     SI

        MOV     BL,[SI]
        SHL     BL,2
        SHR     BL,2
        INC     [encodeLen]
        CALL TRL
        INC SI

    LOOP translate



                                            ; TODO4: Completati subrutina ENCODE, astfel incat
                                            ; in cadrul acesteia va fi realizata codificarea
                                            ; sirului criptat pe baza alfabetului COD64 mentionat
                                            ; in enuntul problemei si rezultatul va fi stocat
                                            ; in cadrul variabilei encoded
    MOV     AX,[padding]
    SUB     [msglen],AX

    MOV     AX,[msglen]
    MOV     DX,0
    MOV     BX,3
    DIV     BX
    CMP     DX,0
    JE      sf_Iterations
    ADD     AX,1
    sf_Iterations:
    MOV     [iterations],AX
    RET
WRITE_HEX:
    MOV     DI, OFFSET temp + 2
    XOR     DX, DX
DUMP:
    MOV     DL, [SI]
    PUSH    CX
    MOV     CL, 4

    ROR     DX, CL
    
    CMP     DL, 0ah
    JB      print_digit1

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     next_digit

print_digit1:  
    OR      DL, 30h
    MOV     byte ptr [DI] ,DL
next_digit:
    INC     DI
    MOV     CL, 12
    SHR     DX, CL
    CMP     DL, 0ah
    JB      print_digit2

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     AGAIN

print_digit2:    
    OR      DL, 30h
    MOV     byte ptr [DI], DL
AGAIN:
    INC     DI
    INC     SI
    POP     CX
    LOOP    dump
    
    MOV     byte ptr [DI], 10
    RET
WRITE:
    MOV     SI, OFFSET x0
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21h

    MOV     SI, OFFSET a
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET b
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET x
    MOV     CX, 1
    CALL    WRITE_HEX    
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET message
    MOV     CX, [msglen]
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, [msglen]
    ADD     CX, [msglen]
    ADD     CX, 3
    INT     21h

    MOV     AX, [iterations]
    MOV     BX, 4
    MUL     BX
    MOV     CX, AX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET encoded
    INT     21H

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H
    RET

TRL:
    PUSH    BX
    MOV     AX,[msglen]
    MOV     DX,[padding]
    SUB     AX,DX
    MOV     DX,4
    MUL     DX
    MOV     BX,3
    DIV     BX
    CMP     DX,0
    JNE      rest
    JMP     norest
    rest:
    ADD     AX,1
    norest:

    POP     BX
    PUSH    BX
    CMP     AX,[encodeLen]
    JGE     fals
    JMP     adv

    adv:
    MOV     AL,'+'
    MOV     [DI],AL
    INC     DI
    JMP     dupaif

    fals:
    PUSH    DI
    MOV     DI,OFFSET CODE64
    ADD     DI,BX
    MOV     AL,[DI]
    POP     DI
    MOV     [DI],AL
    INC     DI
    JMP     dupaif

    dupaif:
    POP BX
    RET




    END START