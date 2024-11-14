	include "asl.inc"
        TTL     "FLEX            2.0"
        PAG

;* FLEX 2.0
;* DATE: 09/15/79  15:50
;* LAST CHANGE DATE 11.7.79  13:35

;* EQUATES

BASE    EQU     $A000           ;* BASE ADDR ($A000=FLEX2.0)

CRC     EQU     $D              ;* CARRIAGE RETURN
LFC     EQU     $A              ;* LINE FEED
;2SPC     EQU     $20             ;* SPACE
XFR     EQU     BASE+$D00       ;* DOS XFER ADDRESS
DRVREG  EQU     $8014           ;* DRIVE SELECT REGISTER FOR DC-2
COMREG  EQU     $8018           ;* 1771 COMMAND AND STATUS REGISTER
TRKREG  EQU     $8019           ;* 1771 CURRENT TRACK REGISTER
SECREG  EQU     $801A           ;* 1771 SECTOR REGISTER
DATREG  EQU     $801B           ;* 1771 DATA REGISTER
INCH1   EQU     $E1AC           ;* INPUT CHAR ROUTINE
INCH21  EQU     $E1AC           ;* INPUT CHAR ROUNTINE
OUTCH1  EQU     $E1D1           ;* OUTPUT CHAR ROUTINE
OUTC21  EQU     $E1D1           ;* OUTPUT CHAR ROUTINE
CTLPOR  EQU     $8004           ;* ADDR OF SERIAL CNTRL PORT
TIMERA  EQU     $8010           ;* TIMER BOARD BASE (PORT 4)
IRQVEC  EQU     $A000           ;* IRQ VECTOR LOCATION
SWIVEC  EQU     $A012           ;* SWI VECTOR LOCATION
MONITR  EQU     $E0D0           ;* MONITOR ENTRY ADDRESS
PCVEC   EQU     $A048           ;* MONITOR PC LOCATION
LBUFFR  EQU     BASE+$80        ;* LINE BUFFER (END = $A0FF)

;* TTYSET DEFINITIONS

        ORG     BASE+$C00

BSP     FCB     8               ;* BACKSPACE CHAR
DEL     FCB     $18             ;* DELETE CHAR
EOL     FCC     ':'             ;* END OF LINE CHAR
DEPTH   FCB     0               ;* DEPTH COUNT
WIDTH   FCB     0               ;* WIDTH COUNT
NULCNT  FCB     4               ;* NULL COUNT
TAB     FCB     0               ;* TAB CHAR
BSECHO  FCB     0               ;* BACKSPACE ECHO CHAR
EJECTC  FCB     0               ;* EJECT COUNT
PAUSEC  FCB     $FF             ;* PAUSE CONTROL
ESCCHR  FCB     $1B             ;* ESCAPE CHAR
SASN    FCB     0               ;* SYSTEM DRIVE NUMBER
WASN    FCB     0               ;* WORKING DRIVE NUMBER
ASN     EQU     WASN
TEMP1   FCB     0               ;* SYSTEM SCRATCH
DDATE    FCB     0               ;* MONTH-SYSTEM DDATE REGS
        FCB     0               ;* DAY
        FCB     0               ;* YEAR
LSTTRM  FCB     0               ;* LAST TERMINATOR
USRCMD  FDB     0               ;* USER COMMAND TABLE ADDR
BUFPNT  FDB     0               ;* LINE BUFFER POINTER
ESCRET  FDB     0               ;* ESCAPE RETURN REG
CURCHR  FCB     0               ;* CURRENT CHAR
PRVCHR  FCB     0               ;* PREVIOUS CHAR
CURLIN  FCB     0               ;* CURRENT LINE NUMBER
OFFSET  FDB     0               ;* LOADER ADDR OFFSET
XFERFL  FCB     0               ;* TRANSFER FLAG
XFERAD  FDB     0               ;* TRANSFER ADDRESS
ERRTYP  FCB     0               ;* ERROR TYPE
IOFLAG  FCB     0               ;* SPECIAL I/O FLAG
OUTCHN  FCB     0               ;* OUTPUT SWITCH
INSW    FCB     0               ;* INPUT SWITCH
FOUTAD  FDB     0               ;* FILE OUTPUT ADDRESS
FINADD  FDB     0               ;* FILE INPUT ADDRESS
CMDFLG  FCB     0               ;* COMMAND FLAG
CURCOL  FCB     0               ;* CURRENT OUTPUT COLUMN
TEMP2   FCB     0               ;* SYSTEM SCRATCH
MEMEND  FDB     0               ;* MEMORY END
ERRVEC  FDB     0               ;* ERROR NAME VECTOR
ECHOFL  FCB     1               ;* FILE INPUT ECHO FLAG
;*
;* SYSTEM SCRATCH
;*
FMSFLG  FCB     0
CURTSK  FDB     0
DTEMP3  FCB     0
MODE    FCB     0
;DTEMP5  EQU     $              ;* LST has 0000 but DTEMP5 isn't used in LST
DTEMP5  EQU     0
DTEMP6  EQU     FMSFLG+$B
INDEX   EQU     FMSFLG+$D       ;* COMMAND TABLE POINTER STORAGE
DTEMP8  EQU     FMSFLG+$E
DTEMP9  EQU     FMSFLG+$F
DTEMPA  EQU     FMSFLG+$10
DATPNT  EQU     FMSFLG+$11      ;* POINTER TO COMMAND BEING LOOKED UP
DTEMPC  EQU     FMSFLG+$13
DTEMPD  EQU     FMSFLG+$14
DTEMPE  EQU     FMSFLG+$15
DTEMPF  EQU     FMSFLG+$17
        ORG     FMSFLG+$19
DTEMPG  FCB     0               ;* ESCAPE FLAG
DTEMPH  EQU     DTEMPG+1
DTEMPI  EQU     DTEMPG+2
DTEMPJ  EQU     DTEMPG+3
DTEMPK  EQU     DTEMPG+4

;* SYSTEM CONSTANTS

        ORG     BASE+$C4E
SIGNON  FCC     'FLEX 2.0'
        FCB     4
PROMPT  FCC     '+++'
        FCB     4
CPRMPT  FCC     '???'
        FCB     4
WHAT    FCC     'WHAT?'
        FCB     4
NOXFER  FCC     'CAN\'T TRANSFER'
        FCB     4
NOTFND  FCC     'NOT FOUND'
        FCB     4
DISKER  FCC     'DISK ERROR #'
        FCB     4
DRNRDY  FCC     'DRIVES NOT READY'
        FCB     4

;* DOS COMMAND TABLE

GET     FCC     'GET'
        FCB     0
        FDB     LOAD10
        FCC     'MON'
        FCB     0
        FDB     JMONTR
        FCB     0
;*
;*  OUTPUT DECIMAL # CONSTANTS
;*
ODECON  FDB     $2710           ;* DECIMAL 10,000
        FDB     $3E8            ;* DECIMAL 1,000
        FDB     $64             ;* DECIMAL 100
        FDB     $A              ;* DECIMAL 10

;* RESERVED FOR PRINTER ROUNTINES

        ORG     BASE+$CC0
PRTINZ  RTS                     ;* PRINTER INITIALIZE
        ORG     BASE+$CD8
PRTRDY  RTS                     ;* PRINTER READY CHECK
        ORG     BASE+$CE4
PRTOUT  RTS                     ;* PRINTER OUTPUT

;* SYSTEM SCRATCH

        ORG     BASE+$CF8
FGTASK  FCB     1,0             ;* FIRST BYTE NON-ZERO IF RUNNING
        FDB     0               ;* EXECUTION ADDRESS SAVED HERE

BGTASK  FCB     0,0             ;* FIRST BYTE NON-ZERO IF RUNNING
        FDB     0               ;* EXECUTION ADDRESS SAVED HERE

;* JUMP TABLE FOR DOS

COLDS   JMP     COLDS1          ;* COLDSTART ENTRY POINT
WARMS   JMP     WARMS1          ;* WARMSTART ENTRY POINT
RENTER  JMP     RENTR1          ;* DOS MAIN LOOP RE-ENTRY
INCH    JMP     INCH1           ;* INPUT CHAR
INCH2   JMP     INCH21          ;* INPUT CHAR
OUTCH   JMP     OUTCH1          ;* OUTPUT CHAR
OUTCH2  JMP     OUTC21          ;* OUTPUT CHAR
GETCHR  JMP     GETCH1          ;* GET CHAR
PUTCHR  JMP     PUTCH1          ;* PUT CHAR
INBUFF  JMP     INBUF1          ;* INPUT INTO LINE BUFFER
PSTRNG  JMP     PSTRG1          ;* PRINT STRING
CLASS   JMP     CLASS1          ;* CLASSIFY CHAR
PCRLF   JMP     PCRLF1          ;* OUTPUT CR AND LF
NXTCH   JMP     NXTCH1          ;* GET NEXT BUFFER CHAR
RSTRIO  JMP     RSTIO1          ;* RESTORE I/O VECTORS
GETFIL  JMP     GETFI1          ;* GET FILE SPECIFICATION
LOAD    JMP     LOAD1           ;* FILE LOADER
SETEXT  JMP     SETXT1          ;* SET EXTENSION
ADDBX   JMP     ADDBX1          ;* ADD B-REG TO X-REG
OUTDEC  JMP     ODEC1           ;* OUTPUT DECIMAL NUMBER
OUTHEX  JMP     OHEX1           ;* OUTPUT HEX NUMBER
RPTERR  JMP     RPTER1          ;* REPORT ERROR
GETHEX  JMP     GETHX1          ;* GET HEX NUMBER
OUTADR  JMP     OADR1           ;* OUTPUT HEX ADDR
INDEC   JMP     INDEC1          ;* INPUT DECIMAL NUMBER
DOCMND  JMP     DOCMD1          ;* CALL DOS AS A SUBRTN
        JMP     RTS1
        JMP     RTS1
        JMP     RTS1

;* DOS = DISK OPERATING SYSTEM
;* COLD START OF FLEX 2.0

COLDS1  LDS     #LBUFFR-1       ;* INZ STACK POINTER SCRATCH PAD RAM
        LDX     #SIGNON
        JSR     PSTRG1          ;* DISPLAY 'FLEX 2.0'
        JSR     PCRLF1          ;* PRINT CR/LF
COLDS2  CLR     LSTTRM          ;* CLEAR LAST TERMINATOR
        JSR     FMSINZ          ;* INITIALIZE FMS
        CLR     CMDFLG          ;* CLEAR COMMAND FLAG
        JSR     JFMEME          ;* FIND END OF MEMORY

;* HOT RESTART ADDRESS

WARMS1  LDS     #LBUFFR-1       ;* INZ STACK POINTER
        LDX     #WARMS          ;* SET MONITOR PC LOCATION
        STX     PCVEC           ;* SWTBUG/MIKBUG 'GO' ADDRESS
        STX     ESCRET          ;* SET ESCAPE RETURN VECTOR
        LDX     #SWI            ;* SET SWI VECTOR
        STX     SWIVEC          ;* SWTBUG SWI VECTOR ADDRESS
        LDX     #IRQ            ;* SET IRQ VECTOR
        STX     IRQVEC          ;* SWTBUG IRQ VECTOR ADDRESS
        LDX     #FGTASK         ;* FOREGROUND TASK IS CURRENT TASK
        STX     CURTSK
        CLR     MODE            ;* ZERO MEANS FOREGROUND TASK IS RUNNING
        CLR     DTEMPJ
        BSR     RSTIO1          ;* RESTORE I/O VECTORS
        LDAA    LSTTRM          ;* GET LAST TERMINATOR
        CMPA    EOL             ;* IS IT MULTIPLE COMMANDS PER LINE
        BNE     WARMS2          ;* NO: CHECK FOR 'DOCMND'
        INC     BUFPNT+1        ;* INCREMENT BUFFER POINTER
        BRA     RENTR1          ;* AND GET SOME MORE
WARMS2  TST     CMDFLG          ;* CHECK FOR 'DOCMND' ENTRY
        BEQ     WARMS3          ;* NO: DO WARM START
        JMP     DOCMD3          ;* YES: RE-ENTER 'DOCMND'
WARMS3  JSR     FMSCLS          ;* CLOSE ALL FILES
        BNE     COLDS2          ;* IF ERROR IN CLOSING THEN REPORT IT
        LDX     #PROMPT         ;* POINT TO '+++' PROMPT
        JSR     PSTRG1          ;* PRINT IT
        JSR     INBUF1          ;* GET INPUT FROM TERMINAL INTO LINE BUFFER
;*
;* MAIN LOOP RE-ENTRY ADDRESS
;*
RENTR1  JSR     GETFIE          ;* GET NEXT CHAR IN LINEBUFFER
        CMPA    #CRC            ;* IS IT A CARRIAGE RETURN
        BEQ     WARMS2          ;* YES: WARM START
RENTR2  LDX     #FCB            ;* POINT TO FCB
        INC     TEMP1
        JSR     GETFI1          ;* GET FILE NAME FROM BUFFER
        BCS     RENTR5          ;* ERROR: SAY SO
        LDX     #GET            ;* RESIDENT CMD?
        BSR     FFILN1          ;* CHECK COMMAND TABLE
        BEQ     RENTR3          ;* YES: JUMP TO IT
        LDX     USRCMD          ;* NO, USER CMD?
        BEQ     RENTR4          ;* NO USER CMDS
        BSR     FFILN1          ;* IS IT ONE OF USER CMD?
        BNE     RENTR4          ;* NO: LOAD DISK FILE
RENTR3  LDX     1,X             ;* FOUND IT, NOW GET ADDRESS TO JUMP TO
        JMP     0,X             ;* AND JUMP TO IT
RENTR4  JSR     LOAD14          ;* LOAD FILE & RET IF ERROR
RENTR5  LDX     #WHAT           ;* ILLEGAL FILE
        LDAA    #$15            ;* SPECIFICATION
RENTR6  STAA    ERRTYP          ;* SAVE ERROR TYPE
RENTR7  JSR     PSTRG1          ;* DISPLAY ERROR MESSAGE
RENTR8  CLR     LSTTRM          ;* CLEAR REST OF COMMAND LINE
        JMP     WARMS1          ;* AND DO A WARM START
;*
;* RESTORE I/O VECTORS
;*
RSTIO1  LDX     OUTCH2+1        ;* TERMINL OUTPUT ADDRESS
        STX     OUTCH+1         ;* CHANGED OUTPUT ADDRESS
        LDX     INCH2+1         ;* TERMINAL INPUT ADDRESS
        STX     INCH+1          ;* CHANGED INPUT ADDRESS
        CLR     INSW            ;* CLEAR INPUT SWITCH
        CLR     OUTCHN          ;* CLEAR OUTPUT CHANNEL
        CLR     IOFLAG          ;* CLEAR SPECIAL I/O FLAG
        CLR     FINADD          ;* CLEAR FILE INPUT ADDRESS
        CLR     FOUTAD          ;* CLEAR FILE OUTPUT ADDRESS
RTS1    RTS                     ;* RETURN
;*
;* FIND FILENAME
;*
FFILN1  STX     INDEX           ;* SAVE COMMAND TABLE ADDRESS
        LDX     #FCB+4          ;* POINT TO FCB FILENAME
FFILN2  LDAA    0,X             ;* GET CHARACTER
        CMPA    #$5F            ;* UPPER CASE?
        BLS     FFILN3          ;* YES
        SUBA    #$20            ;* NO, MAKE UPPER CASE
FFILN3  STX     DATPNT          ;* SAVE FILENAME POINTER
        LDX     INDEX           ;* POINT TO COMMAND TABLE
        CMPA    0,X             ;* COMPARE CHARACTERS
        BNE     FFILN5          ;* NOT THE SAME THEN FIND NEXT ENTRY
        INX                     ;* BUMP POINTER
        STX     INDEX           ;* SAVE IT
        TST     0,X             ;* END OF ENRTY?
        BNE     FFILN4          ;* NO: COMPARE NEXT CHARACTER
        LDX     DATPNT          ;* YES: POINT TO COMMMAND
        LDAA    1,X             ;* GET LAST CHARACTER+1
        LDX     INDEX           ;* POINT TO COMMAND TABLE
        TSTA                    ;* END OF COMMAND?
        BEQ     FFILN6          ;* YES: EXIT
        BRA     FFILN5          ;* NO: FIND NEXT ENTRY
FFILN4  LDX     DATPNT          ;* POINT TO COMMAND POINTER
        INX                     ;* BUMP POINTER
        BRA     FFILN2          ;* CHECK NEXT CHARACTER
FFILN5  INX                     ;* FIND NEXT ENTRY
        TST     0,X             ;* END OF TABLE?
        BNE     FFILN5          ;* NO: LOOP UNTILL DONE
        INX                     ;* INCREMENT AROUND
        INX                     ;* END OF COMMAND BYTE
        INX                     ;* AND ADDRESS
        TST     0,X             ;* END OF TABLE?
        BNE     FFILN1          ;* NO: GET NEXT ENTRY
        CPX     #0              ;* SET 'Z' BIT FOR PROPER CODE FOR RETURN
FFILN6  RTS                     ;* RETURN
;*
;* INPUT TO LINE BUFFER
;*
INBUF1  LDX     #LBUFFR         ;* POINT TO START OF LINEBUFFER
        STX     BUFPNT          ;* RESET LINE BUFFER POINTER
INBUF2  JSR     GETCH1          ;* GET CHARACTER FROM TERMINAL
        CMPA    DEL             ;* IS IT A DELETE LINE CHARACTER
        BEQ     DOWHAT          ;* YES: PRINT ??? AND START AGAIN
        CMPA    BSP             ;* IS IT A BACKSPACE
        BEQ     BACKSP          ;* YES: DO BACKSPACE
        CMPA    #CRC            ;* IS IT A CARRIAGE RETURN
        BEQ     INBUF4          ;* YES: ENTER IT RESET POINTER AND EXIT
        CMPA    #LFC            ;* IS IT A LINEFEED
        BEQ     LINFED          ;* YES: ENTER SPACE AND ECHO CR/LF
        CMPA    #$1F            ;* IS IT A CONTROL CHARACTER?
        BLS     INBUF2          ;* YES: THEN IGNORE IT
INBUF3  CPX     #LBUFFR+$7F     ;* END OF INPUT BUFFER?
        BEQ     INBUF2          ;* YES: IGNORE IT
INBUF4  STAA    0,X             ;* STORE CHARACTER IN BUFFER
        INX                     ;* BUMP POINTER
        CMPA    #CRC            ;* IS IT A CARRAIGE RETURN
        BNE     INBUF2          ;* NO: CONTINUE
        RTS                     ;* RETURN
DOWHAT  LDX     #CPRMPT         ;* "???" PROMPT
        BSR     PSTRG1          ;* PRINT IT
        BRA     INBUF1          ;* AND DO AGAIN
BACKSP  CPX     #LBUFFR         ;* START OF BUFFER?
        BEQ     DOWHAT          ;* YES: SAY WHAT '???'
        DEX                     ;* DECRIMENT POINTER
        LDAA    BSECHO          ;* BACKSPACE ECHO CHAR?
        CMPA    #8              ;* IS IT AN $08
        BNE     NBSECH          ;* NO: DON'T ECHOE SPACE
        LDAA    #SPC            ;* YES, ERASE CHAR BY PRINTING SPACE
        JSR     PUTCH6          ;* PRINT IT
        LDAA    BSECHO          ;* GET ECHO CHARACTER
NBSECH  JSR     PUTCH6          ;* PRINT IT
        BRA     INBUF2          ;* INPUT MORE
LINFED  LDAA    #CRC            ;* CARRIAGE RETURN INTO A
        JSR     PUTCH1          ;* OUTPUT IT
        LDAA    #SPC            ;* SPACE INTO A
        BRA     INBUF3          ;* ENTER SPACE INTO LINE BUFFER
;*
;* PRINT STRING
;*
PSTRG1  BSR     PCRLF1          ;* PRINT CARRIAGE RETURN/LINEFEED
PSTRG2  LDAA    0,X             ;* GET NEXT CHARACTER TO PRINT
        CMPA    #4              ;* END OF STRING?
        BEQ     PCRLFA          ;* YES, CLEAR CARRY & RETURN
        JSR     PUTCHR          ;* NO: OUTPUT CHARACTER
        INX                     ;* INCREMENT POINTER
        BRA     PSTRG2          ;* GET NEXT CHARACTER
;*
;*  TTYSET PAUSE ROUTINE
;*
PAUSE   CLR     CURLIN          ;* CLEAR CURRENT LINA
        CLR     DTEMPG
PAUSE1  JSR     INCH            ;* RESTART OUTPUT,IF ESC
        CMPA    ESCCHR          ;* ESCAPE CHARACTER?
        BEQ     PCRLFA          ;* YES: PRINT CR/LFAND CONTINUE
        CMPA    #CRC            ;* CARRIAGE RETURN?
        BNE     PAUSE1          ;* NO: GET ANOTHER CHARACTER
        CLR     LSTTRM          ;* YES: CLEAR LAST TERMINATOR
        LDX     ESCRET          ;* GET ESCAPE RETURN ADDRESS
        JMP     0,X             ;* AND JUMP TO IT
;*
;* PRINT C/R, L/F
;*
PCRLF1  TST     IOFLAG          ;* IGNORE TTYSET?
        BNE     PCRLF7          ;* YES: BRANCH AROUND CHECKS
        TST     DTEMPG          ;* ESCAPE TYPED?
        BEQ     PCRLF2          ;* NO: CHECK DEPTH
        BSR     PAUSE           ;* YES: PAUSE
PCRLF2  LDAA    DEPTH           ;* DEPTH SET?
        BEQ     PCRLF7          ;* NO: DON'T CHECK CURLIN
        CMPA    CURLIN          ;* YES, CURRENT LINE > DEPTH?
        BHI     PCRLF6          ;* NO: PRINT AND EXIT
        CLR     CURLIN          ;* YES, CLEAR CURRENT LINE
        TST     PAUSEC          ;* PAUSE ENABLED?
        BEQ     PCRLF3          ;* NO: CONTINUE
        BSR     PAUSE           ;* YES: PAUSE
PCRLF3  PSHB                    ;* SAVE B
        LDAB    EJECTC          ;* GET EJECT COUNT
        BEQ     PCRLF5          ;* NOT SET CONTINUE
EJECTN  BSR     PCRLF7          ;* OUTPUT CR/LF
        DECB                    ;* DECRIMENT COUNTER
        BNE     EJECTN          ;* IF NOT DONE LOOP
PCRLF5  PULB                    ;* RESTORE B
PCRLF6  INC     CURLIN          ;* BUMP CURRENT LINE COUNTER
PCRLF7  LDAA    #CRC            ;* CARRIAGE RETURN
        BSR     PUTCH1          ;* OUTPUT IT
        LDAA    #LFC            ;* LINE FEED
        BSR     PUTCH1          ;* OUTPUT IT
        PSHB                    ;* SAVE B
        LDAB    NULCNT          ;* GET NULL COUNT
        BEQ     PCRLF9          ;* ZERO: RETURN
PNULL   CLRA                    ;* CLEAR A
        BSR     PUTCH1          ;* OUTPUT NULL
        DECB                    ;* DECRIMENT COUNTER
        BNE     PNULL           ;* NOT DONE THEN LOOP
PCRLF9  PULB                    ;* RESTORE B
PCRLFA  CLC                     ;* CLEAR CARRY FOR NO ERROR
        RTS                     ;* RETURN
;*
;* PREFERRED GET CHAR
;*
GETCH1  TST     INSW            ;* FILE INPUT?
        BNE     GETCH3          ;* NO, TERMINAL
        TST     FINADD          ;* FILE INPUT ADDRESS?
        BEQ     GETCH2          ;* NO, DEFAULT TO TERMINAL
        BSR     GETCH5          ;* YES, LOAD INPUT FILE
        TST     ECHOFL          ;* ECHO INPUT?
        BEQ     GETCH4          ;* NO: RETURN
        TST     FOUTAD          ;* YES, FILE OUTPUT ADDRESS?
        BEQ     GETCH4          ;* NO: RETURN
        JSR     PUTCH6          ;* YES, ECHO INPUT
        BRA     GETCH4          ;* AND RETURN
GETCH2  JSR     INCH            ;* INPUT CHAR FROM TERMINAL
        BRA     GETCH4          ;* AND RETURN
GETCH3  JSR     INCH2           ;* INPUT CHAR, ALTER INPUT
GETCH4  CLR     CURLIN          ;* RESET CURRENT LINE
        RTS                     ;* RETURN
;*
;* LOAD ALTERNATE INPUT FILE
;*
GETCH5  STX     DTEMPF          ;* GET FCB ADDRESS OF
        LDX     FINADD          ;* ALTERNATE INPUT FILE
        BRA     FILIO1          ;* GET CHARACTR FROM FILE
;*
;*  FILE I/O FOR 'PUTCHR'
;*
FILEIO  STX     DTEMPF          ;* SAVE INDEX REGISTER
        LDX     FOUTAD          ;* GET FILE OUTPUT ADDRESS
FILIO1  JSR     FMS             ;* WRITE ALTERNATE FILE
        BNE     FILERR          ;* IF ERROR, REPORT IT
        LDX     DTEMPF          ;* RESTORE INDEX REGISTER
        RTS                     ;* RETURN
;*
;*  FILE OUTPUT ERROR
;*
FILERR  CLR     FOUTAD          ;* CLEAR FILE OUTPUT ADDRESS
        JSR     RPTER1          ;* REPORT THE ERROR
        JMP     WARMS           ;* RE-ENTER FLEX THROUGH WARM START
;*
;* PERFERRED OUTPUT CHAR
;*
PUTCH1  TST     IOFLAG          ;* IGNORE TTYSET?
        BNE     PUTCH6          ;* YES: BRANCH AROUND CHECK
        CMPA    #$1F            ;* PRINTER CONTROL CHAR?
        BHI     PUTCH2          ;* NO: TAKE CARE OF PRINTABLE CHARACTER
        CLR     CURCOL          ;* YES, CLEAR CURRENT COLUMN
        BRA     PUTCH4          ;* BRANCH AROUND COLLUMN JUNK
PUTCH2  INC     CURCOL          ;* INC CURRENT COLUMN
        PSHA                    ;* SAVE A
        LDAA    WIDTH           ;* CURRENT COLUMN > WIDTH?
        BEQ     PUTCH3          ;* WIDTH NOT SET THEN BRANCH AROUND
        CMPA    CURCOL          ;* CURRENT COLUMN >=WIDTH?
        BCC     PUTCH3          ;* NO: CONTINUE
        JSR     PCRLF1          ;* YES: PRINT CR/LF
        INC     CURCOL          ;* SET FOR COLUMN #1
PUTCH3  PULA                    ;* RESTORE A
PUTCH4  PSHA                    ;* SAVE A
        LDAA    CTLPOR          ;* CHAR FROM TERMINAL?
        LSRA                    ;* GET RDRF FLAG INTO CARRY
        BCC     PUTCH5          ;* NOTHING TYPED
        LDAA    CTLPOR+1        ;* YES: GET CHARACTER TYPED
        ANDA    #$7F            ;* MAKE SURE IT'S ASCII
        CMPA    ESCCHR          ;* ESCAPE CHAR?
        BNE     PUTCH5          ;* NO: CONTINUE
        INC     DTEMPG          ;* YES: SET ESCAPE FLAG
PUTCH5  PULA                    ;* RESTORE A
PUTCH6  PSHA                    ;* SAVE A
        TST     OUTCHN          ;* OUTPUT CHANNEL 0 OR 1?
        BNE     PUTCH8          ;* OUTPUT TO CHANNEL 1
        TST     FOUTAD          ;* FILE OUTPUT?
        BEQ     PUTCH7          ;* NO: OUTPUT TO CHANNEL ZERO
        BSR     FILEIO          ;* OUTPUT TO FILE
        BRA     PUTCH9          ;* RETURN
;*
;*  ECHO INPUT TO OUTPUT FILE
;*
PUTCH7  TST     FINADD          ;* FILE INPUT ADDRESS?
        BNE     PUTCH9          ;* YES: RETURN
        JSR     OUTCH           ;* NO OUTPUT THROUGH NORMAL CHANNEL
        BRA     PUTCH9          ;* RETURN
PUTCH8  JSR     OUTCH2          ;* OUTPUT THROUGH ALTERNATE CHANNEL
PUTCH9  PULA                    ;* RESTORE A
        RTS                     ;* RETURN
;*
;* OUTPUT DECIMAL NUMBER
;*
ODEC1   CLR     DTEMPH
        STAB    XFERFL          ;* PUT B IN COMPRESSION FLAG
        LDAA    #4              ;* PASS COUNT
        STAA    DTEMPK          ;* SWVE IN PASS COUNTER
        LDAA    0,X             ;* GET 1ST BYTE OF NUMBER
        LDAB    1,X             ;* GET 2ND BYTE OF NUMBER
        LDX     #ODECON         ;* POINT TO DECIMAL CONSTANTS
ODEC2   BSR     ODEC3           ;* DIVIDE BY CONSTANT
        INX                     ;* BUMP TO NEXT
        INX                     ;* DECIMAL CONSTANT
        DEC     DTEMPK          ;* DECRIMENT PASS COUNTER
        BNE     ODEC2           ;* IF NOT DONE THEN LOOP
        TBA                     ;* PUTB IN A
        BRA     OHEX3           ;* OUTPUT LSB AND EXIT THROUGH OUTHEX
ODEC3   CLR     DTEMPI          ;* CLEAR DIVISOR COUNT
ODEC4   CMPA    0,X             ;* CONSTANT MSB>A
        BCS     ODEC6           ;* NO: FIGURE OUT MULTIPLIER
        BHI     ODEC5           ;* YES: FIGURE OUT MULTIPLIER
        CMPB    1,X             ;* IF EQUAL COMPARE LSB
        BCS     ODEC6           ;* IF GREATER THEN FIGURE OUT MULTIPLIER
ODEC5   SUBB    1,X             ;* SUBTRACT CONSTANT LSB FROM LSB
        SBCA    0,X             ;* SUBTRACT CONSTANT MSB FROM MSB
        INC     DTEMPI          ;* INCREMENT MULTIPLIER
        BRA     ODEC4           ;* REPEAT
ODEC6   PSHA                    ;* SAVE A (MSB)
        LDAA    DTEMPI          ;* GET MULTIPLIER
        BNE     ODEC7           ;* IF NOT ZERO THEN INCREMENT HIGH MULTIPLIER
        TST     DTEMPH          ;* HIGH MULTIPLIER=0
        BNE     ODEC7           ;* NO: INCREMENT HIGH MULTIPLIER
        TST     XFERFL          ;* SUPPRESS ZEROS?
        BEQ     ODEC8           ;* NO THEN RETURN
        LDAA    #$20            ;* SPACE
        BSR     OHEX4           ;* OUTPUT IT
        BRA     ODEC8           ;* RETURN
ODEC7   INC     DTEMPH          ;* BUMP HIGH MULTIPLIER
        BSR     OHEX3           ;* OUTPUT MSB
ODEC8   PULA                    ;* RESTORE A
        RTS                     ;* RETURN
;*
;* OUTPUT 2 HEX BYTE ( ADDR)
;*
OADR1   BSR     OHEX1           ;* OUTPUT FIRST BYTE
        INX                     ;* BUMP POINTER
;*
;* OUTPUT HEX BYTE
;*
OHEX1   LDAA    0,X             ;* GET BYTE TO OUTPUT
        BSR     OHEX2           ;* OUTPUT MOST SIGNIFICANT NIBBLE
        LDAA    0,X             ;* GET BYTE AGAIN
        BRA     OHEX3           ;* OUTPUT LEAST SIGNIFICANT NIBBLE
OHEX2   LSRA                    ;* SHIFT
        LSRA                    ;* MOST SIGNIFICANT
        LSRA                    ;* TO LEAST
        LSRA                    ;* SIGNIFICANT NIBBLE
OHEX3   ANDA    #$F             ;* MASK OUT HIGH ORDER NIBBLE
        ADDA    #'0'             ;* ADD ASCII CODE FOR ZERO
        CMPA    #'9'             ;* GREATER THEN '9'
        BLS     OHEX4           ;* NO: OUTPUT NUMBER
        ADDA    #7              ;* ADJUST FOR HEXIDECIMAL 'A' - 'F'
OHEX4   JMP     PUTCH1          ;* OUTPUT NIBBLE AND RETURN
;*
;* CLASSIFY CHAR
;*
CLASS1  CMPA    #'0'             ;* ZERO?
        BCS     CLASS2          ;* <0 SET CARRY
        CMPA    #'9'             ;* NINE?
        BLS     CLASS3          ;* <9 OKAY CLEAR CARRY
        CMPA    #'A'             ;* 'A'?
        BCS     CLASS2          ;* LESS THEN CHARACTER 'A' SET CARRY
        CMPA    #'Z'             ;* 'Z'?
        BLS     CLASS3          ;* LESS THEN 'Z' OKAY CLEAR CARRY
        CMPA    #'a'             ;* 'a'
        BCS     CLASS2          ;* LESS THEN 'a' SET CARRY
        CMPA    #'z'             ;* 'z'?
        BLS     CLASS3          ;* LESS THEN 'z' OKAY
CLASS2  SEC                     ;* SET CARRY FOR NON-ALPHANUMERIC
        STAA    LSTTRM          ;* SAVE A IN LAST TERMINATOR
        RTS                     ;* RETURN
CLASS3  CLC                     ;* CLEAR CARRY FOR ALPHA-NUMERIC
        RTS                     ;* RETURN
;*
;* NEXT CHAR
;*
NXTCH1  STX     INDEX           ;* SAVE INDEX REGISTER
        LDX     BUFPNT          ;* GET BUFFER POINTER
        LDAA    CURCHR          ;* GET CURRENT CHARACTER
        STAA    PRVCHR          ;* AND SAVE IN PREVIOUS CHARACTER
NXTCH2  LDAA    0,X             ;* GET CHARACTER
        STAA    CURCHR          ;* SAVE AS CURRENT CHARACTER
        CMPA    #CRC            ;* IS IT A CARRIAGE RETURN
        BEQ     NXTCH3          ;* YES: RETURN WITH CARRIAGE RETURN IN A
        CMPA    EOL             ;* IS IT AN END OF LINE CHARACTER
        BEQ     NXTCH3          ;* YES: RETURN WITH EOL IN A
        INX                     ;* BUMP POINTER TO NEXT CHARACTER
        STX     BUFPNT          ;* SAVE NEW BUFFER POINTER
        CMPA    #$20            ;* IS IT A SPACE
        BNE     NXTCH3          ;* NO: RETURN WITH CHARACTER IN A
        CMPA    0,X             ;* IS NEXT CHARACTER A SPACE
        BEQ     NXTCH2          ;* YES: LOOP UNTILL NO SPACES
NXTCH3  LDX     INDEX           ;* GET INDEX REGISTER
        BRA     CLASS1          ;* CLASSIFY CHARACTER AND RETURN
;*
;* PARSE FILE SPEC.
;*
GETFI1  LDAA    #$15            ;* SET $15 IN ERROR
        STAA    1,X             ;* STATUS OF FCB
        LDAA    #$FF            ;* SET DR # TO ALL
        STAA    3,X             ;* SAVE IN FCB DRIVE NUMBER
        CLR     4,X             ;* CLR 1ST BYTE OF
        CLR     12,X            ;* FILENAME & EXTENSION
        JSR     GETFIE          ;* GET NEXT CHAR FROM LINE BUFFER
        LDAA    #8              ;* BUFFER CHARACTER COUNT FOR FILE NAME
        STAA    DTEMPI          ;* SAVE COUNT
        BSR     GETFI7          ;* GET NEXT CHARACTER
        BCS     GETFI6          ;* IF NOT LEGAL CHARACTER EXIT WITH ERROR
        BNE     GETFI2
        BSR     GETFI7          ;* GET NEXT CHARACTER FROM BUFFER
        BCS     GETFI6          ;* IF NOT LEGAL CHARACTER EXIT WITH ERROR
        BNE     GETFI2          ;* CHECK FOR ERROR
        CPX     DTEMP9
        BEQ     GETFIC          ;* RETURN
        BSR     GETFI7          ;* GET NEXT CHARACTER
        BLS     GETFIC          ;* RETURN
;*
;* VERIFY FILENAME ENTERED, DRIVE ENTERED OR
;* DEFAULT AND EXTENSION ENTERED OR DEFAULT
;*
GETFI2  LDX     DTEMP9          ;* FCB ADDRESS
        TST     4,X             ;* CURRENT CHARACTER OF FILE NAME
        BEQ     GETFIC          ;* IF ZERO THEN RETURN
        TST     3,X             ;* DRIVE #
        BPL     GETFI5          ;* IF NOT ALL THEN RETURN
        TST     TEMP1           ;* COMMAND FILE OR PASSED FILE NAME
        BEQ     GETFI3          ;* PASSED: GET WORKING DRIVE
        LDAA    SASN            ;* COMMAND: GET SYSTEM DRIVE
        BRA     GETFI4          ;* STORE IT
GETFI3  LDAA    WASN            ;* GET WOKING DRIVE
GETFI4  STAA    3,X             ;* STORE IT IN DRIVE NUMBER OF FCB
GETFI5  CLR     TEMP1           ;* SET FOR PASSED FILE NAME
GETFI6  LDX     DTEMP9          ;* POINT TO FCB AGAIN
        RTS                     ;* RETURN
;*
;* PARSE DRIVE NUMBER
;*
GETFI7  BSR     NXTCH1          ;* GET NEXT CHARACTER FROM LINE BUFFER
        BCS     GETFIC          ;* TERMINATOR RETURN
        CMPA    #'9'             ;* IS IT A NINE
        BHI     GETFI9          ;* >9 IS NAME OR ILLEGAL
        LDX     DTEMP9          ;* GET FCB ADDRESS
        TST     3,X             ;* DRIVE 0?
        BPL     GETFIC          ;* IF ALL THEN RETURN
        ANDA    #3              ;* MASK OUT GARBAGE
        STAA    3,X             ;* SAVE IN DRIVE NUMBER
        JSR     NXTCH1          ;* GET NEXT CHARACTER
        BCC     GETFIC          ;* ERROR
GETFI8  CMPA    #'.'             ;* IS IT A PERIOD
        CLC                     ;* CLEAR CARRY FOR NO ERROR RETURN
        RTS                     ;* RETURN
;*
;* PARSE FILENAME AND EXTENSION
;*
GETFI9  LDAB    DTEMPI          ;* GET CHARACTER COUNT
        BMI     GETFIC
        PSHB                    ;* SAVE IT
        SUBB    #5              ;* B-5 NUMBER OF CHARACTERS IN EXTENSION
        STAB    DTEMPI          ;* SAVE IT
        PULB                    ;* RESTORE # OF CHARACTERS IN FILE NAME
GETFIA  STAA    4,X             ;* STORE CHARACTER IN FCB
        INX                     ;* BUMP POINTER
        DECB                    ;* DECRIMENT COUNTER
        JSR     NXTCH1          ;* GET NEXT CHARACTER
        BCC     GETFIB          ;* IF LEGAL DON'T CHECK FOR '-'
        CMPA    #'-'             ;* IS IT A '-'?
        BEQ     GETFIB          ;* YES: OKAY CONTINUE
        CMPA    #'_'             ;* IS IT AN UNDERLINE?
        BNE     GETFID          ;* NO: ERROR OUT
GETFIB  TSTB                    ;* LAST CHARACTER?
        BNE     GETFIA          ;* NO: GET ANOTHER
GETFIC  SEC                     ;* SET CARRY (ERROR OUT)
        RTS                     ;* RETURN
GETFID  TSTB                    ;* LAST CHARACTER OF FILE NAME
        BEQ     GETFI8          ;* YES: RETURN
        CLR     4,X             ;* CLEAR BYTE
        INX                     ;* POINT TO NEXT BYTE
        DECB                    ;* DECRIMENT COUNTER
        BRA     GETFID          ;* CLEAR TILL END OF FILE NAME
;*
;* GET NEXT CHAR IN LINE BUFFER
;*
GETFIE  STX     DTEMP9          ;* SAVE FCB ADDRESS
        LDX     BUFPNT          ;* GET LINE BUFFER POINTER
GETFIF  LDAA    0,X             ;* GET CHARACTER
        CMPA    #$20            ;* SPACE?
        BNE     GETFIG          ;* NO: CONTINUE
        INX                     ;* YES: BUMP POINTER
        BRA     GETFIF          ;* AND TRY AGAIN
GETFIG  STX     BUFPNT          ;* SAVE BUFFER POINTER ADDRESS
        LDX     DTEMP9          ;* RESTORE FCB ADDRESS
        RTS                     ;* RETURN TO GETFIL
;*
;* SET EXTENSION
;*
SETXT1  STX     DTEMP6          ;* SAVE FCB POINTER
        LDAB    12,X            ;* ALREADY EXTENSION THERE?
        BNE     SETXT3          ;* YES: RETURN
        STX     INDEX           ;* NO: SAVE INDEX REGISTER
        LDX     #EXTTBL         ;* POINT TO EXTENSION TABLE
        CMPA    #$B             ;* GREATER THAN LAST EXTENSION IN TABLE?
        BHI     SETXT3          ;* YES: RETURN
        TAB                     ;* SAVE A IN B
        ASLB                    ;* B=B*2
        ABA                     ;* A=3*A
        TAB                     ;* SAVE A IN B
        JSR     ADDBX1          ;* ADDB TO X FOR TABLE OFFSET
        LDAB    #3              ;* NUMBER OF CHARACTERS IN EXTENSION
SETXT2  LDAA    0,X             ;* GET CHARACTER FROM TABLE
        INX                     ;* BUMP POINTER
        STX     DATPNT          ;* SAVE POINTER
        LDX     INDEX           ;* GET FCB ADDRESS
        STAA    12,X            ;* SAVE IN EXTENSION BYTES
        INX                     ;* BUMP POINTER
        STX     INDEX           ;* SAVE FCB ADDRESS
        LDX     DATPNT          ;* GET TABLE POINTER
        DECB                    ;* BECRIMENT CONTER
        BNE     SETXT2          ;* IF NOT DONE THEN LOOP
SETXT3  LDX     DTEMP6          ;* RESTORE FCB ADDRESS
        RTS                     ;* RETURN
EXTTBL  FCC     'BINTXTCMDBASSYSBAK'
        FCC     'SCRDATBACDIRPRTOUT'
;*
;* GET HEX NUMBER FROM BUFFER
;*
GETHX1  CLRB                    ;* CLEAR B
        STAB    OFFSET          ;* CLEAR OFFSET
        STAB    OFFSET+1        ;* BYTES
GETHX2  JSR     NXTCH1          ;* GET CHARACTER FROM BUFFER
        BCS     GETHX5          ;* IF NOT ALPHA-NUMERIC SET TO ZERO AND RETURN
        BSR     GETHX6          ;* GET HEX VALUE
        BCS     GETHX4          ;* IGNORE ADDITIONAL CHARACTERS
        PSHB                    ;* SAVE B
        LDAB    #4              ;* NUMBER OF BITS TO ROTATE
GETHX3  ASL     OFFSET+1        ;* SHIFT MOST SIGNIFICANT BYTE
        ROL     OFFSET          ;* SHIFT LEAST SIGNIFICANT BYTE
        DECB                    ;* DECRIMENT SHIFT COUNTER
        BNE     GETHX3          ;* SHIFT SOME MORE
        PULB                    ;* RESTORE B
        ADDA    OFFSET+1        ;* ADD NEW NIBBLE TO OLD ONES
        STAA    OFFSET+1        ;* SAVE VALUE
        INCB
        BRA     GETHX2          ;* GET NEXT NIBBLE
GETHX4  JSR     NXTCH1          ;* GET NEXT DIGIT
        BCC     GETHX4          ;* IGNORE ALL CHARACTERS TILL TERMINATOR
        RTS                     ;* RETURN
GETHX5  LDX     OFFSET          ;* GET VALUE
        CLC                     ;* NO ERROR FLAG
        RTS                     ;* RETURN
GETHX6  SUBA    #$47            ;* SUBTRACT ASCII CODE FOR 'F'
        BPL     GETHX8          ;* IF GREATER THEN 'F' THEN ERROR
        ADDA    #6              ;* ADD SIX STRIPPED CODE FOR 0-9
        BPL     GETHX7          ;* IF NOT NEGATIVE THEN A-F
        ADDA    #7              ;* ADD SEVEN FOR 0-9
        BPL     GETHX8          ;* IF BETWEEN ':' AND '@' THEN ERROR
GETHX7  ADDA    #10             ;* ADD TEN FOR A-F
        BMI     GETHX8          ;* STILL NEGATIVE THEN ERROR
        CLC                     ;* CLEAR CARRY FOR NO ERROR FLAG
        RTS                     ;* RETURN
GETHX8  SEC                     ;* SET CARRY FOR ERROR FLAG
        RTS                     ;* RETURN
;*
;* INPUT DECIMAL NUMBER
;*
INDEC1  JSR     LOAD11          ;* CLEAR OFFSET ADDRESS
        CLRB                    ;* CLEAR B
INDEC2  JSR     NXTCH1          ;* GET CHARACTER FROM BUFFER
        BCS     GETHX5          ;* IF NOT LEGAL THEN SET FOR ZERO
        CMPA    #'9'             ;* GREATER THEN NINE?
        BHI     GETHX4          ;* YES: ERROR
        ANDA    #$F             ;* AND OUT LS NIBBLE
        PSHB                    ;* SAVE B
        PSHA                    ;* SAVE A
        LDAA    OFFSET          ;* GET MSB OF VALUE
        LDAB    OFFSET+1        ;* GET LSB OF VALUE
        ASLB                    ;* ROTATE
        ROLA                    ;* AROUND
        ASLB                    ;* FOR CONVERSION
        ROLA                    ;* FROM
        ASLB                    ;* THE
        ROLA                    ;* ASCII
        ASL     OFFSET+1        ;* CHARACTERS
        ROL     OFFSET          ;* MORE
        ADDB    OFFSET+1        ;* MATH
        ADCA    OFFSET          ;* FOR
        STAB    OFFSET+1        ;* THE CONVERSION
        PULB                    ;* RESTORE B
        ADDB    OFFSET+1        ;* MORE
        ADCA    #0              ;* CONVERSOIN
        STAB    OFFSET+1        ;* ROUTINE
        STAA    OFFSET          ;* GARBAGE
        PULB                    ;* RESTORE B
        INCB                    ;* NUMBER FOUND
        BRA     INDEC2          ;* GET NEXT DIGIT
;*
;* ADD "ACC-B" TO "X"
;*
ADDBX1  STX     DTEMP9          ;* SAVE X
        ADDB    DTEMPA          ;* ADD B TO LS BYTE
        STAB    DTEMPA          ;* SAVE IT
        BCC     ADDBX2          ;* IF NO CARRY THEN RETURN
        INC     DTEMP9          ;* BUMP MS BYTE WITH CARRY
ADDBX2  LDX     DTEMP9          ;* POINT TO NEW X VALUE
        RTS                     ;* RETURN
;*
;* FILE LOADER
;*
LOAD1   CLR     XFERFL          ;* CLEAR TRANSFER FLAG
LOAD2   BSR     LOAD5           ;* GET BYTE FROM FILE
        CMPA    #2              ;* IS IT AN ADDRESS CODE?
        BEQ     ADDRES          ;* YES: SET LOAD ADDRESS
        CMPA    #$16            ;* IS IT A TRANSFER ADDRESS CODE?
        BNE     LOAD2           ;* NO: GET ANOTHER CHARACTER
        BSR     LOAD5           ;* GET BYTE
        STAA    XFERAD          ;* SAVE IN TRANSFER ADDRESS MSB
        BSR     LOAD5           ;* GET BYTE
        STAA    XFERAD+1        ;* SAVE IN TRANSFER ADDRES LSB
        LDAA    #1              ;* SET TRANSFER FLAG
        STAA    XFERFL          ;* STORE IT
        BRA     LOAD2           ;* CONTINUE LOADING
ADDRES  BSR     LOAD5           ;* GET MSB OF LOAD ADDRESS
        PSHA                    ;* SAVE IT
        BSR     LOAD5           ;* GET LSB OF LOAD ADDRESS
        PULB                    ;* PUT MSB INTO B
        ADDA    OFFSET+1        ;* ADD IN CURRRENT LOAD OFFSET
        ADCB    OFFSET          ;* AND NOW MSB
        STAA    DTEMP8          ;* SAVE LSB OF ADDRESS
        STAB    INDEX           ;* SAVE MSB OF ADDRESS
        BSR     LOAD5           ;* GET NUMBER OF BYTES TO LOAD
        TAB                     ;* PUT # INTO B
        BEQ     LOAD2           ;* IF ZERO THEN GET NEXT ADDRESS
LOAD4   BSR     LOAD5           ;* GET BYTE FROM FILE
        LDX     INDEX           ;* GET ADDRESS TO LOAD INTO
        STAA    0,X             ;* SAVE BYTE IN MEMORY
        INX                     ;* BUMP POINTER
        STX     INDEX           ;* SAVE IT
        DECB                    ;* DECRIMENT COUNTER
        BNE     LOAD4           ;* IF NOT DONE THEN READ SOME MORE DATA
        BRA     LOAD2           ;* WHEN DONE LOOP AND START AGAIN
LOAD5   LDX     #FCB            ;* POINT TO FCB
        JSR     FMS             ;* READ SINGLE BYTE
        BEQ     LOAD7           ;* NO ERROR RETURN
        LDAA    1,X             ;* GET ERROR STATUS
        CMPA    #8              ;* END OF FILE ERROR
        BNE     LOAD8           ;* NO: REPORT ERROR
        PULA                    ;* YES: RESTORE STACK
        PULA                    ;* (NO RTS EXIT)
;*
;* CLOSE LOAD FILE
;*
LOAD6   LDAA    #4              ;* FMS CLOSE FILE CODE
        STAA    0,X             ;* FCB COMMAND BYTE
        JSR     FMS             ;* CLOSE FILE
        BNE     LOAD9           ;* ERROR, REPORT IT
LOAD7   CLC                     ;* SET FOR NO ERROR RETURN
        RTS                     ;* RETURN
;*
;* REPORT ALL LOAD ERRORS
;*
LOAD8   STAA    ERRTYP          ;* SAVE ERROR TYPE
        CMPA    #4              ;* NOT FOUND ERROR
        BNE     LOAD9           ;* NO: REPORT ERROR
        SEC                     ;* ERROR RETURN
        RTS                     ;* RETURN
LOAD9   BSR     RPTER1          ;* REPORT ERROR
        JMP     RENTR8          ;* AND EXIT TO DOS
LOAD10  LDAA    #0
        BSR     LOAD16          ;* GET FILE NAME
        BCS     LOAD12          ;* IF ERROR TAKE CARE OF IT
        BSR     LOAD11          ;* CLEAR OFFSET
        INC     DTEMPJ          ;* FLAG FOR INTERNAL LOAD
        BSR     LOAD1           ;* LOAD FILE
        BRA     LOAD10          ;* DO SOME MORE
LOAD11  CLR     OFFSET          ;* CLEAR OFFSET
        CLR     OFFSET+1        ;* AND DO LSB ALSO
        RTS                     ;* RETURN
LOAD12  LDAB    DTEMPJ          ;* INTERNAL CALL?
        BEQ     LOAD13          ;* NO: RETURN TO DOS
        JMP     WARMS           ;* YES: WARM START
LOAD13  JMP     RENTR5          ;* RE-ENTER DOS
LOAD14  LDAA    #2              ;* SET FOR 'CMD' EXTENSION
        BSR     LOAD17          ;* SET EXTENSION
        BSR     LOAD11          ;* CLEAR OFFSET
        JSR     LOAD1           ;* LOAD IT
        LDAB    XFERFL          ;* DO WE HAVE A TRANSFER ADDRESS?
        BEQ     LOAD15          ;* NO: NO TRANSFER ERROR
        LDX     XFERAD          ;* YES: GET TRANSFER ADDRESS
        JMP     0,X             ;* AND JUMP TO IT
;*
;* REPORT NO TRANSFER ADDRESS
;*
LOAD15  LDX     #NOXFER         ;* POINT TO NO TRANSFER MESSAGE
        LDAA    #$81            ;* ERROR TYPE
        JMP     RENTR6          ;* PRINT ERROR AND EXIT TO DOS
LOAD16  PSHA                    ;* SAVE A
        LDX     #FCB            ;* POINT TO FCB
        JSR     GETFI1          ;* GET FILE NAME
        PULA                    ;* RESTORE A
        BCS     LOAD19          ;* IF ERROR THEN TAKE CARE OF IT
LOAD17  LDX     #FCB            ;* POINT TO FCB
        JSR     SETXT1          ;* SET EXTENSION
        LDX     #FCB            ;* POINT TO FCB
        LDAA    #1              ;* SET FOR OPEN TO READ
        STAA    0,X             ;* SAVE IN COMMAND BYTE
        JSR     LOAD5           ;* GET BYTE FROM FILE
        BCC     LOAD18          ;* IF NO ERROR THEN BRANCH AROUND ERROR JUNK
        JMP     RPTERC          ;* REPORT ERROR AND RETURN TO DOS
LOAD18  LDAA    #$FF            ;* SET FOR BINARY READ
        STAA    59,X            ;* STORE IN FCB
        RTS                     ;* RETURN
LOAD19  LDAA    LSTTRM          ;* GET LAST TERMINATOR
        CMPA    #CRC            ;* CARRIAGE RETURN?
        BEQ     LOAD20          ;* YES: THEN JSR ENTRY
        CMPA    EOL             ;* MULTIPLE COMMAND ON LINE?
        BEQ     LOAD20          ;* YES: THEN JSR ENTRY
        JMP     RENTR5          ;* EXIT TO DOS
LOAD20  SEC                     ;* SET CARRY FOR EXIT OUT
        RTS                     ;* RETURN
;*
;* REPORT ERROR
;*
RPTER1  STX     DTEMP9          ;* SAVE FCB ADDRESS
        LDAA    1,X             ;* GET ERROR NUMBER
        STAA    ERRTYP          ;* SAVE IN ERROR TYPE
        BEQ     RPTER6          ;* NO ERROR THEN RETURN
        JSR     RSTIO1          ;* RESTORE I/O VECTORS
        LDX     ERRVEC          ;* GET ERROR NAME VECTOR
        BNE     RPTER2          ;* IF THERE IS ONE GET THAT FILE NAME
        CMPA    #$10            ;* DRIVES NOT READY ERROR?
        BEQ     RPTER7          ;* YES: PRINT ERROR MESSAGE
        LDX     #ERRORS         ;* POINT TO 'ERRORS.SYS' STRING
RPTER2  STX     DATPNT          ;* SAVE ADDRESS
        LDX     #FCB            ;* POINT TO FCB
        TST     2,X             ;* ACTIVE?
        BEQ     RPTER3          ;* NO: DON'T CLOSE FILE
        LDAA    #4              ;* CLOSE FILE CODE
        STAA    0,X             ;* STORE IN COMMAND BYTE
        JSR     FMS             ;* CLOSE FILE
        BNE     RPTER4          ;* ERROR:  PRINT STANDERD MESSAGE
RPTER3  LDX     #FCB-8          ;* COMPENSATE FOR FILE NAME
        STX     INDEX           ;* SAVE POINTER
        LDAB    #$B             ;* NUMBER OF CHARACTERS IN FILE NAME
        LDX     DATPNT          ;* GET POINTER
        JSR     SETXT2          ;* SET EXTENSION
        LDX     #FCB            ;* POINT TO FCB
        LDAA    #$FF            ;* SET FOR ALL DRIVES
        STAA    3,X             ;* STOE IN FCB
        LDAA    #1              ;* OPEN FILE FOR READ
        STAA    0,X             ;* STORE IN COMMAND BYTE
        JSR     FMS             ;* OPEN FILE
        BNE     RPTER4          ;* ERROR: PRINT DISK ERROR MESSAGE
        LDAA    ERRTYP          ;* GET ERROR TYPE
        DECA                    ;* ADJUST FOR RANDOM READ
        ASRA                    ;* DIVIDE BY 2
        ASRA                    ;* DIVIDE BY 2
        INCA                    ;* ADJUST FOR RANDOM READ
        CLR     32,X            ;* CLEAR MSB OF RECORD NUMBER
        STAA    33,X            ;* SET FOR PROPER RECORD NUMBER
        LDAA    #$15            ;* POSITION TO RECORD "N"
        STAA    0,X             ;* SAVE IN COMMAND BYTE
        JSR     FMS             ;* DO RANDOM READ
        BEQ     RPTER8          ;* NO ERRORS: CONTINUE
RPTER4  LDX     #DISKER         ;* POINT TO DISK ERROR MESSAGE
        JSR     PSTRG1          ;* PRINT PRINT IT
        LDX     DTEMP9          ;* GET FCB ADDRESS
        LDAA    ERRTYP          ;* GET ERROR TYPE
        STAA    1,X             ;* SAVE IN FCB
        CLR     0,X             ;* CLEAR COMMAND BYTE
        CLRB                    ;* CLEAR B
        JSR     ODEC1           ;* OUTPUT DECIMAL ERROR NUMBER
RPTER5  LDX     DTEMP9          ;* RESTORE FCB ADDRESS
RPTER6  RTS                     ;* RETURN
RPTER7  LDX     #DRNRDY         ;* POINT TO DISK NOT READY MESSAGE
        JSR     PSTRG1          ;* PRINT IT
        BRA     RPTER5          ;* RESTORE FCB ADDRESS AND RETURN
RPTER8  JSR     PCRLF1          ;* PRINT CR/LF
        LDX     #FCB            ;* POINT TO FCB
        LDAA    ERRTYP          ;* GET ERROR TYPE
        LDAB    #4              ;* START OF FIRST READABLE MESSAGE
        DECA                    ;* ADJUST A
        ANDA    #3              ;* MASK OUT FOR 0-3
        BEQ     RPTERA          ;* IF ZERO THEN JUST OUTPUT IT
RPTER9  ADDB    #$3F            ;* 63 CHARACTERS PER MESSAGE
        DECA                    ;* DECRIMENT A FOR PROPER INDEX
        BNE     RPTER9          ;* LOOP UNTIL DONE
RPTERA  STAB    34,X            ;* SAVE IN RANDOM INDEX
RPTERB  JSR     FMS             ;* AND READ RECORD
        BNE     RPTER4          ;* ERROR: GIVE UP
        JSR     PUTCH1          ;* OUTPUT CHARACTER FROM ERRORS FILE
        CMPA    #CRC            ;* CARRIAGE RETURN?
        BNE     RPTERB          ;* NO: GET MORE CHARACTERS
        LDAA    #4              ;* YES: CLOSE FILE CODE
        STAA    0,X             ;* SAVE IN FCB
        JSR     FMS             ;* CLOSE FILE
        BRA     RPTER5          ;* RESTORE X AND RETURN
RPTERC  LDX     #NOTFND         ;* POINT TO NOT FOUND MESSAGE
        JMP     RENTR7          ;* PRINT IT AND EXIT TO DOS
;*
;* CALL DOS
;*
DOCMD1  PULA                    ;* GET MSB RETURN ADDRESS
        PULB                    ;* GET LSB OF RETURN ADDRESS
        STAA    DTEMPC          ;* SAVE FOR
        STAB    DTEMPD          ;* LATER RETURN
DOCMD2  STS     DTEMPE          ;* SAVE THE STACK REGISTER
        CLR     ERRTYP          ;* CLEAR ANY OLD ERRORS
        INC     CMDFLG          ;* SET FOR 'DOCMND' CALL
        JMP     RENTR2          ;* RE-ENTER DOS AND EXECUTE
DOCMD3  CLR     CMDFLG          ;* ZERO COMMAND FLAG
        LDX     DTEMPC          ;* GET RETURN ADDRESS
        LDS     DTEMPE          ;* RESTORE STACK
        LDAB    ERRTYP          ;* PASS ANY ERRORS ON TO CALLING PROGRAM
        JMP     0,X             ;* AND RETURN TO CALLING PROGRAM
;*
;*  MON COMMAND.  GIVES ERROR IF PRINTING
;*
JMONTR  TST     BGTASK          ;* PRINTING?
        BNE     DOCMD4          ;* YES: ERROR
        JMP     MONITR          ;* EXIT TO MONITER LOCATION
DOCMD4  LDX     #FCB            ;* POINT TO FCB
        LDAA    #$1B            ;* SET FOR NOT ALLOWED WHILE PRINTING ERROR
        STAA    1,X             ;* SAVE IN ERROR BYTE
        JSR     RPTER1          ;* REPORT ERROR
        JMP     WARMS1          ;* AND EXIT TO DOS
;*
;*  FILENAME FOR SYSTEM ERROR NAME FILE
;*
ERRORS  FCC     'ERRORS'
        FCB     0,0
        FCC     'SYS'
;*
;*  SELF MODIFYING CODE.  COLD START ALWAYS DOES A 'JSR' HERE
;*  BUT ON THE FIRST TIME AFTER BOOT, THE MEMORY SIZE UP ROUTINE
;*  PUT AN 'RTS' HERE.  CLEVER HUH?
;*
        ORG     BASE+$13FD
JFMEME  JMP     FMEME           ;* WILL BE SET AN 'RTS' AFTER INITIAL COLD START
;*
;* FIND THE END OF MEMORY
;*
        ORG     BASE+$A00
FMEME   LDAA    #$39            ;* HEX CODE FOR 'RTS'
        STAA    JFMEME          ;* STORE IN 'COLDS' SUBROUTINE CALL
        LDX     #0              ;* START AT LOCATION ZERO
        LDAB    #$B9            ;* MEMORY TEST CODE
FMEME1  STAB    0,X             ;* SAVE IN MEMORY
        NOP                     ;* ADDED TIME FOR DYANMIC RAMS
        CMPB    0,X             ;* DID WE STORE?
        BNE     FMEME2          ;* NO: FOUND ENDOF MEMORY
        INX                     ;* BUMP POINTER
        CPX     #$8000          ;* START OF PORTS
        BNE     FMEME1          ;* NO: CONTINUE SEARCHING FOR END OF MEMORY
FMEME2  DEX                     ;* ADJUST X FOR PROPER LOCATION
        STX     MEMEND          ;* SAVE IN MEMORY END BYTES OF FLEX
;*
;* INITIALIZE FLEX 2.0
;*
        LDX     #WARMS          ;* PUT WARM START ADDRESS
        STX     ESCRET          ;* IN ESCAPE RETURN REGISTER
        LDX     INVEC           ;* ROM MONITER INPUT VECTOR
INZ1    STX     INCH+1          ;* SETUP FOR INCH ROUTINE
        STX     INCH2+1         ;* AND INCH2
        LDX     OUTVEC          ;* ROM MONITER OUTPUT VECTOR
        STX     OUTCH+1         ;* SET UP FOR OUTCH ROUTINE
        STX     OUTCH2+1        ;* AND OUTCH2
        LDX     MON             ;* GET MONITER ENTRY ADDRESS
        STX     JMONTR+6        ;* SET UP JUMP FOR MON
        LDX     ACIA            ;* ACIA BASE ADDRESS
        STX     PUTCH4+2        ;* STORE IN OUTPUT ROUTINE FOR ESCAPE CHECK
        INX                     ;* SET FOR ACIA DATA REGISTER
        STX     PUTCH4+8        ;* STORE IN OUTPUT ROUTINE FOR ESCAPE CHECK
        LDX     PCV             ;* GET ROM P.C. LOCATION
        STX     WARMS1+7        ;* SAVE IN WARM START FOR SWTBUG/MIKBUG 'G'
        LDX     IRQADD          ;* ROM IRQ VECTOR ADDRESS
        STX     WARMS1+22       ;* SAVE IN SPOOLER
        LDX     SWIADD          ;* ROM SWI VECTOR ADDRESS
        STX     WARMS1+16       ;* SAVE IN SPOOLER
        LDX     TIMER           ;* GET TIMER BASE ADDRESS
        STX     SPOOL1+1        ;* STORE IN SPOOLER
        STX     SCH4+3          ;* TWICE EVEN!
;*
;* GET DDATE
;*
DDATE1   LDX     #DPROMP         ;* GET DDATE (MM,DD,YY)
        JSR     PSTRG1          ;* PRINT IT
        JSR     INBUF1          ;* INPUT TO LINE BUFFER
        BSR     DDATE5           ;* PARSE MONTH
        BCS     DDATE1           ;* INPUT ERROR
        STAA    DDATE            ;* SAVE MONTH
        BSR     DDATE5           ;* PARSE DAY
        BCS     DDATE1           ;* INPUT ERROR
        STAA    DDATE+1          ;* SAVE DAY
        BSR     DDATE5           ;* PARSE YEAR
        BCS     DDATE1           ;* INPUT ERROR
        STAA    DDATE+2          ;* SAVE YEAR
        JSR     PCRLF1          ;* DO CRLF
        LDX     #FCB            ;* POINT TO FCB
        LDAA    #1              ;* OPEN FOR READ (NAME ALREADY THERE)
        STAA    0,X             ;* SAVE IN COMMAND BYTE
        JSR     FMS             ;* OPEN FILE
        BEQ     DDATE2           ;* NO ERRORS THEN CONTINUE
        LDAA    1,X             ;* GET ERROR NUMBER
        JSR     LOAD8           ;* IGNORE NOT FOUND ERROR OTHER WISE PRINT MESSAGE
        JMP     WARMS1          ;* AND EXIT TO DOS
DDATE2   LDX     #LBUFFR         ;* GET START OF BUFFER INTO X
DDATE3   STX     BUFPNT          ;* SAVE IT IN POINTER
        LDX     #FCB            ;* POINT TO FCB
        JSR     FMS             ;* READ BYTE FROM FILE
        BEQ     DDATE4           ;* NO ERROR: CONTINUE
        JMP     RPTER4          ;* ERRORS: ERPORT ERROR
DDATE4   LDX     BUFPNT          ;* GET BUFFER ADDRESS
        STAA    0,X             ;* SAVE CHARACTER IN BUFFER
        INX                     ;* BUMP POINTER
        CMPA    #$D             ;* CARRIAGE RETURN?
        BNE     DDATE3           ;* NO: CONTINUE
        LDX     #FCB            ;* YES: POINT TO FCB
        JSR     LOAD6           ;* CLOSE FILE
        LDX     #LBUFFR         ;* RESTORE TO START OF LINE
        STX     BUFPNT          ;* TELL FLEX ITS THERE
        LDX     #WARMS          ;* GET WARM START ADDRESS
        STX     DTEMPC          ;* SET IN 'DOCMND' ADDRESS REGISTER
DDATE8   JMP     DOCMD2          ;* AND FAKE OUT DO COMMAND
DDATE5   JSR     INDEC1          ;* INPUT DECIMAL FROM LINEBUFFER
        BCS     DDATE7           ;* ERROR: RETURN
        LDAA    OFFSET+1        ;* LSB OF NUMBER
        TSTB                    ;* NUMBER FOUND?
        BEQ     DDATE6           ;* NO: ERROR
        CLC                     ;* CLEAR ERROR FLAG (CARRY) AND RETURN
        RTS                     ;* RETURN
DDATE6   SEC                     ;* SET ERROR FLAG (CARRY)
DDATE7   RTS                     ;* RETURN
DPROMP  FCC     'DDATE (MM,DD,YY)? '
        FCB     4
;*
;* FILE CONTROL BLOCK
;*
        ORG     BASE+$840
FCB     FCB     $FF             ;* FMS FUNCTION CODE
        FCB     0               ;* ERROR STATUS BYTE
        FCB     0               ;* ACTIVITY STATUS
        FCB     0               ;* DRIVE NUMBER
        FCC     'STARTUP'       ;* FILE NAME FOR INITIAL COLD START
        FCB     0
        FCC     'TXT'           ;* EXTENSION
        FCB     0               ;* FILE ATTRIBUTES
;*
;* SCHEDULER
;*
        ORG     BASE+$700
SWI     JMP     SPOOL2          ;* SWI JUMP
JSELF   JMP     JSELF           ;* DUMMY LOOP
JSCH1   JMP     SCH1
JTSTSET JMP     TSTSET
JCLRFLG JMP     CLRFLG
IRQ     JMP     SPOOL1          ;* IRQ JUMP

FFCHAR  FCB     $C              ;* FORM FEED CHAR
        FDB     0,0
        FDB     BEGINQ
OUTQ    FDB     BEGINQ
QCNT    FCB     0
PSTMP3  FCB     0
PSTMP4  FCB     0
PSTMP5  FCB     0
BEGINQ  EQU     BASE+$810
ENDQ    EQU     FCB

;* PRINT SPOOLER

SPOOL1  LDAA    TIMERA+2        ;* CLEAR TIMER INTERRUPT

SPOOL2  LDX     CURTSK          ;* GET POINTER TO CURRENT TASK
        STS     2,X             ;* SAVE RE-ENTRY ADDRESS
        TST     MODE            ;* FOREGROUND OR BACKGROUND RUNNING?
        BNE     FORGND          ;* BG RUNNING, SWITCH TO FORGND

        LDX     #BGTASK         ;* X->BG TASK STATUS BLOCK
        INC     MODE            ;* NON-ZERO MEANS BG RUNNING
        TST     0,X             ;* DOES BG TASK NEED TO RUN?
        BEQ     FORGND          ;* NO, RUN FG TASK INSTEAD

TSKRTN  STX     CURTSK          ;* POINT TO TASK BLOCK THAT IS NOW RUNNING
        LDS     2,X             ;* RESTORE STACK PTR TO RE-ENTER
        RTI                     ;* ...THE NEW TASK

FORGND  LDX     #FGTASK         ;* X->FG TASK STATUS BLOCK
        CLR     MODE            ;* 0 MEANS FG TASK IS RUNNING
        BRA     TSKRTN          ;* SET CURRENT TASK AND EXIT

SCH1    NOP                     ;* NECESSARY FOR NEXT INSTRUCTION
        SEI                     ;* DISABLE INTERRUPTS
        TST     QCNT            ;* QUEUE EMPTY?
        BEQ     SCH3            ;* YES: RETURN
        LDX     OUTQ            ;* NO: GET ADDRESS OF OUTPUT QUEUE
        LDAA    0,X             ;* GET DRIVE NUMBER OF FILE BEING OUTPUTTED
        PSHA                    ;* SAVE IT
        LDAA    1,X             ;* GET TRACK ADDRESS FROM QUEUE
        LDAB    2,X             ;* GET SECTOR ADDRESS FROM QUEUE
        LDX     #DDATE8          ;* POINT TO QUEUE FCB
        STAA    64,X            ;* ADDRESS OF NEXT TRACK
        STAB    65,X            ;* ADDRESS OF NEXT SECTOR
        PULA                    ;* RECALL FIRST BYTE READ
        STAA    3,X             ;* SAVE IN DRIVE NUMBER
        CLR     0,X             ;* CLEAR COMMAND BYTE
        LDAA    #1              ;* OPEN FOR READ CODE
        STAA    2,X             ;* SAVE IN STATUS BYTE
        CLR     34,X            ;* CLEAR DATA INDEX
        CLR     59,X            ;* CLER SPACE COMPRESSION FLAG
SCH2    TST     PSTMP5
        BEQ     SCH8
        SWI
        BRA     SCH2
SCH3    NOP                     ;* NECESSARY FOR NEXT INSTRUCTION
        CLI                     ;* ENABLE INTERRUPTS
SCH4    LDAA    #$8F            ;* RESET AND NO OUTPUT FOR MP-T
        STAA    TIMERA+2        ;* STORE IN TIMER REGISTER
        CLR     BGTASK          ;* CLEAR PRINT FLAG
        SWI
        BRA     SCH4

;* TEST AND SET SEMAPHORE FOR FMS ACCESS

TSTSET  NOP
        SEI                     ;* DISABLE INTERRUPTS
        TST     FMSFLG          ;* FMS IN USE?
        BEQ     SETFLG          ;* NO, GO CLAIM IT
        SWI                     ;* ELSE, RELEASE AND WAIT
        BRA     TSTSET

SETFLG  INC     FMSFLG          ;* SET THE FLAG TO CLAIM FMS ACCESS
        RTS

CLRFLG  CLR     FMSFLG          ;* RELEASE FMS ACCESS
        NOP
        CLI                     ;* ENABLE INTERRUPTS
        RTS
        RTS                     ;* RETURN FOR SPECIAL CASE INTERRUPTS

SCH8    TST     PSTMP4          ;* END OF PAGE?
        BNE     SCH11           ;* YES: PRINT FORM FEED
        LDX     #DDATE8          ;* POINT TO QUEUE FCB
        JSR     FMS             ;* READ BYTE
        BNE     SCH11           ;* ERROR: FORMFEED AND AGAIN
        TST     PSTMP3
        BNE     SCH9
        CMPA    #CRC            ;* CARRIAGE RETURN?
        BNE     SCH10           ;* NO: OUTPUT IT
        STAA    PSTMP3          ;* YES: SAVE IT AS A FLAG
        BRA     SCH10           ;* OUTPUT IT
SCH9    CLR     PSTMP3          ;* CLEAR RETURN FLAG
        CMPA    #$A             ;* IS IT A LINE FEED
        BEQ     SCH10           ;* YES: OUTPUT IT
        PSHA                    ;* NO: SAVE IT
        LDAA    #$A             ;* LINE FEED
        BSR     OUTPUT          ;* OUTPUT IT
        PULA                    ;* RESTORE CHARACTER
SCH10   BSR     OUTPUT          ;* OUTPUT IT
        BRA     SCH8            ;* AND RETURN TO MAIN OUTPUT LOOP
SCH11   LDAA    #CRC            ;* GET CARRAIGE RETURN INTO A
        BSR     OUTPUT          ;* OUTPUT IT
        LDAA    #LFC            ;* GET LINE FEED CODE INTO A
        BSR     OUTPUT          ;* OUTPUT IT
        LDAA    FFCHAR          ;* FORM FEED (F.F.=0C)
        BSR     OUTPUT          ;* OUTPUT IT
        CLR     PSTMP4          ;* CLEAR END OF PAGE FLAG
        LDX     OUTQ            ;* POINT TO OUTPUT QUEUE
        TST     3,X             ;* ZERO REPEAT COUNT?
        BEQ     SCH12           ;* YES: GET NEXT ENTRY
        DEC     3,X             ;* DECRIMENT QUEUE COUNT
        JMP     SCH1            ;* AND START AGAIN
SCH12   INX                     ;* BUMP
        INX                     ;* QUEUE COUNTER
        INX                     ;* TO NEXT
        INX                     ;* ENTRY
        CPX     #FCB            ;* END OF QUEUE?
        BNE     SCH13           ;* NO: CONTINUE
        LDX     #BEGINQ         ;* YES: POINT TO START OF QUEUE
SCH13   STX     OUTQ            ;* SAVE IN QUEUE POINTER
        DEC     QCNT            ;* DECRIMENT NUMBER OF FILES IN QUEUE
        JMP     SCH1            ;* AND START AGAIN
OUTPUT  JSR     PRTRDY          ;* PRINTER READY?
        BMI     SCH15           ;* YES: OUTPUT CHARACTER
        SWI                     ;* NO: RETURN
        BRA     OUTPUT          ;* AND LOOP
SCH15   JMP     PRTOUT          ;* OUTPUT TO PRINTER
;*
;* FMS
;*
        ORG     BASE+$1400
FMSINZ  JMP     FMSI1
FMSCLS  JMP     FMSC1
FMS     JMP     FMS1
FCBBPT  RMB     2               ;* FILE CONTROL BLOCK BASE POINTER
CFCBAD  RMB     2               ;* CURRENT FILE CONTROL BLOCK ADDRESS
FTMP1   RMB     2
FTMP2   RMB     2
FTMP3   RMB     1               ;* ATTEMPT COUNTER
FTMP4   RMB     1               ;* RESTORE COUNTER
FTMP5   RMB     2
FTMP6   RMB     2
FTMP7   RMB     1
FTMP8   RMB     2
FTMP9   RMB     1
FTMP10  RMB     2
FTMP11  RMB     1
;*
;* FMS INITIALIZATION
;*
        ORG     BASE+$1435
VERFLG  FCB     $FF             ;* VERIFY ON
FMSI1   LDX     #BASE+$1E95     ;* CLEAR 8 BYTE STATUS BUFFER
        LDAB    #8
        BSR     FMSI3
        LDX     #FCBBPT         ;* CLEAR 10 BYTE BUFFER
        LDAB    #10
        BSR     FMSI3
        LDX     #5
        STX     FTMP5
        STX     FTMP6
        CLR     FTMP9
FMSI2   LDX     #FTMP10         ;* CLEAR 26 BYTE BUFFER
        LDAB    #26             
;*
;* CLEAR MEMORY STARTING AT
;* ADDR IN "X" FOR COUNT IN "B"
;*
FMSI3   CLR     0,X             ;* CLEAR BYTE
        INX                     ;* BUMP POINTER
        DECB                    ;* DECRIMENT COUNTER
        BNE     FMSI3           ;* NOT DONE: CLEAR MORE
        JMP     JCLRFLG         ;* ENABLE SPOOLER
;*
;* FMS CLOSE
;*
FMSC1   JSR     JTSTSET         ;* LOCK ACCESS TO FMS
FMSC2   LDX     FCBBPT          ;* GET FCB BASE ADDRESS
        BEQ     FMSI2           ;* NO ADDRESS: NO FILES OPENED: CLEAR BUFFER AND RETURN
        LDAB    #$1C            ;* BACK UP TO BEGINNING OF FCB (BASE POINTER POINTS TO FCB LIST POINTER)
FMSC3   DEX                     ;* BACKUP FCB POINTER
        DECB                    ;* DECRIMENT BACKUP COUNTER
        BNE     FMSC3           ;* NOT DONE: LOOP
        STX     CFCBAD          ;* SAVE IN CURRENT FCB ADDRESS
        JSR     CLSFIL          ;* CLOSE FILE
        BCC     FMSC2           ;* NO ERROR: CONTINUE
        LDX     CFCBAD          ;* GET FCB ADDRESS
        CLR     2,X             ;* CLEAR ACTIVITY STATUS
        JSR     JCLRFLG         ;* RELEASE FMS SEMAPHORE
        LDAB    #$FF            ;* NON-ZERO STATUS FOR ERROR IN CLOSE
        RTS                     ;* RETURN
;*
;*  START OF FILE MANAGEMENT SYSTEM
;*
FMS1    TST     BGTASK          ;* IS SPOOLER ACTIVE?
        BEQ     FMS2            ;* NO: CONTINUE
        JSR     JTSTSET         ;* YES: LOCK ACCESS TO FMS
FMS2    PSHB                    ;* SAVE B REGISTER
        STX     CFCBAD          ;* SAVE FCB ADDRESS
        CLR     1,X             ;* CLEAR ERROR STATUS
        LDAB    0,X             ;* GET FMS COMMAND
        BNE     FMS6            ;* NOT READ/WRITE SINGLE BYTE: GOTO DISPATCH
        LDAB    2,X             ;* GET STATUS
        BEQ     FMS5            ;* IF ZERO THEN SYSTEM FILE STATUS ERROR (NOT OPEN)
        CMPB    #2              ;* OPEN FOR WRITE?
        BEQ     FMS4            ;* YES: WRITE BYTE
        JSR     SPCOMP          ;* NO: DO READ W/SPACE COMPRESSION
FMS3    LDX     CFCBAD          ;* GET CURRENT FCB ADDRESS
        BCS     FMS9            ;* ERROR: ATTEND TO IT
        TST     BGTASK          ;* PRINTING?
        BNE     FMS10           ;* YES: RE-ENABLE PRINTER
        CLRB                    ;* SET ZERO FOR NO ERROR
        PULB                    ;* RESTORE OLD VALUE OF B
        RTS                     ;* RETURN

FMS4    JSR     WRBUF           ;* WRITE BUFFER
        BRA     FMS3            ;* AND RETURN
FMS5    LDAB    #18             ;* SYSTEM FILE STATUS ERROR
        BRA     FMS9            ;* SAVE IN FCB AND RETURN

FMS6    CMPB    #$16            ;* VALID F.C.?
        BLS     FMS7            ;* YES
        LDAB    #1              ;* NO, ILLEGAL FMS F.C.
        BRA     FMS9

FMS7    DECB                    ;* ADJUST CMD TO LOOKUP IN
        ASLB                    ;* FMS COMMAND TABLE
FMS8    LDX     #FTBL1          ;* GET BEGIN ADDR OF CMD
        JSR     FMS26           ;* TABLE AND ADD CMD OFFSET
        LDX     0,X             ;* GET CMD ADDR AND DO IT
        JSR     0,X
        LDX     CFCBAD          ;* ERROR?
        BCC     FMS10           ;* YES
FMS9    STAB    1,X             ;* PUT ERROR IN ERROR STATUS BYTE OF FCB
FMS10   JSR     JCLRFLG         ;* RELEASE FMS SEMAPHORE
        TST     1,X             ;* SET CC FOR ERROR FLAG IN 'Z' BIT
        PULB                    ;* RESTORE VALUE OF B-REG
        RTS                     ;* RETURN TO CALLING PROGRAM
;*
;* FMS COMMAND TABLE
;*
FTBL1   FDB     OPENRD          ;* OPEN FOR READ
        FDB     OPENWR          ;* OPEN FOR WRITE
        FDB     OPENUP          ;* OPEN FOR UPDATE
        FDB     CLSFIL          ;* CLOSE FILE
        FDB     REWFIL          ;* REWIND FILE
        FDB     OPENDI          ;* OPEN DIRECTORY
        FDB     GETINF          ;* GET INFORMATION RECORD
        FDB     PUTINF          ;* PUT INFORMATION RECORD
        FDB     RDSSEC          ;* READ SINGLE SECTOR
        FDB     WRSSEC          ;* WRITE SINGLE SECTOR
        FDB     RESER1          ;* EXTEND DIRECTORY
        FDB     DELFIL          ;* DELETE FILE
        FDB     RENAME          ;* RENAME FILE
        FDB     RESER2          ;* OPEN FOR APPEND
        FDB     NXTSEQ          ;* NEXT SEQUENTIAL SECTOR
        FDB     OPNINF          ;* OPEN SYS INFORMATION REC
        FDB     GRANBY          ;* GET RANDOM BYTE FM SECTOR
        FDB     PRANBY          ;* PUT RANDOM BYTE IN SECTOR
        FDB     RESER3          ;* RESERVED/FUTURE USE
        FDB     FNXTDR          ;* FIND NEXT DRIVE
        FDB     POSREC          ;* POSITION TO RECORD N
        FDB     BKUP1R          ;* BACKUP ONE RECORD
;*
FMS11   BSR     FMS15           ;* MOVE FCB POINTER TO POINT TO ADDRESS OF NEXT FCB IN CHAIN
        BNE     FMS12           ;* ALL HUNKY DORY?
        LDAB    #2              ;* NO: FILE IN USE ERROR
        SEC                     ;* SET ERROR FLAG IN CC
        RTS                     ;* RETURN
;*
;*  ROUTINE TO PUT THE CONTENTS OF THEA REGISTER
;*  INTO THE MOST SIGNIFICANT BYTE OF THE X REGISTER
;*  AND THEN B REGISTER INTO THE LEAST SIGNIFICANT
;*  BYTE OF THE INDEX REGISTER.
;*
FMS12   STAA    0,X             ;* SAVE MSB
        STAB    1,X             ;* SAVE LSB
        LDX     0,X             ;* LOAD INDEX REGISTER
        CLR     0,X             ;* CLEAR OUT
        CLR     1,X             ;* TEMPORARY BYTES
        CLC                     ;* SET FOR NO ERROR
        RTS                     ;* RETURN
FMS13   BSR     FMS15           ;* BUMP POINTER BY 28 DECIMAL (TO FCB CHAIN ADDRESS)
        BEQ     FMS14           ;* IF COOL THEN TRANSFER NEXT FCB BYTES TO CURRENT FCB POINTER
        LDAB    #$D             ;* ILLEGAL FCB CODE
        SEC                     ;* SET FOR ERROR
        RTS                     ;* RETURN
FMS14   STX     FTMP1           ;* SAVE X IN TEMP
        LDX     0,X             ;* GET POINTED TO ADDRESS (ADDRESS OF NEXT FCB)
        LDAA    0,X             ;* GET BYTE
        LDAB    1,X             ;* GET NEXT BYTE
        LDX     FTMP1           ;* RESTORE POINTER
        STAA    0,X             ;* SAVE BYTE
        STAB    1,X             ;* SAVE NEXT BYTE
        CLC                     ;* SET FOR NO ERROR
        RTS                     ;* RETURN
FMS15   LDAA    CFCBAD          ;* MSB OF CURRENT FCB ADDRESS
        LDAB    CFCBAD+1        ;* LSB OF CURRENT FCB ADDRESS
        ADDB    #$1C            ;* ADD 28 TO POINT TO ADDRESS OF NEXT FCB IN CHAIN
        ADCA    #0              ;* ADD CARRY TO MSB
        LDX     #FCBBPT         ;* GET ADDRESS OF FCB BASE POINTER
FMS16   TST     0,X             ;* DO WE HAVE A CHAIN?
        BNE     FMS17           ;* YES: CONTINUE
        TST     1,X             ;* DO WE HAVE A CHAIN (LSB)
        BNE     FMS17           ;* YES: CONTINUE
        CPX     #$FFFF          ;* SET APPROPRIATE CC BITS FOR PROPER ERROR
        RTS                     ;* RETURN
FMS17   CMPA    0,X
        BNE     FMS18
        CMPB    1,X
        BNE     FMS18
        RTS
FMS18   LDX     0,X
        BRA     FMS16
;*
;* CLEAR STARTING ADDR TO END OF FCB BUFFER
;*
FMS19   LDX     CFCBAD          ;* GET ADDRESS OF CURRENT FCB
        CLRA                    ;* CLEAR A
        LDAB    #0              ;* CLEAR A
        BSR     FMS20           ;* CLEAR 'B' BYTES
        LDAB    #$2F            ;* CLEAR $2F (47) BYTES
FMS20   STAA    17,X            ;* SAVE A AT X+17  (STARTING TRACK ADDRESS IF X=FCB)
        INX                     ;* BUMP POINTER
        DECB                    ;* DECRIMENT LOOP COUNTER
        BNE     FMS20           ;* NOT DONE: LOOP
        RTS                     ;* RETURN
;*
;* TRANSFER FILENAME & EXT TO NAME WORK BUFFER
;*
FMS21   LDX     CFCBAD          ;* GET CURRECT FCB ADDRESS
        LDAB    #11             ;* #OF BYTES TO MOVE
FMS22   LDAA    4,X             ;* GET FILE NAME AND EXTENSION
        STAA    36,X            ;* AND SAVE IN NAME WORK BUFFER
        INX                     ;* INCREMENT POINTER
        DECB                    ;* DECRIMENT COUNTER
        BNE     FMS22           ;* LOOP UNTIL DONE
        RTS                     ;* RETURN
;*
;* COMPARE FILENAME & EXT TO NAME IN WORK BUFFER
;*
FMS23   LDX     CFCBAD          ;* GET CURRENT FCB ADDRESS
        LDAB    #11             ;* # OF BYTES TO COMPARE
FMS24   LDAA    4,X             ;* GET BYTE
        CMPA    36,X            ;* COMPARE TO NAME WORK BUFFER
        BNE     FMS25           ;* IF NOT EQUAL: RETURN WITH 'Z'=0
        INX                     ;* BUMP POINTER
        DECB                    ;* DECRIMENT COUNTER
        BNE     FMS24           ;* LOOP TILL DONE
FMS25   RTS                     ;* RETURN
;*
;* ADD B-REG TO X-REG
;*
FMS26   STX     FTMP1           ;* SAVE INDEX REGISTER
        ADDB    FTMP1+1         ;* ADD LSB OF INDEX REGISTER TO 'B'
        STAB    FTMP1+1         ;* SAVE NEW VALUE IN LSB OF X TEMPORARY
        BCC     FMS27           ;* NO CARRY JUST RETURN
        INC     FTMP1           ;* CARRY: INCREMENT MSB OF INDEX TEMPORARY
FMS27   LDX     FTMP1           ;* GET NEW VALUE INTO INDEX REGISTER
        RTS                     ;* RETURN
;*
;* GET RANDOM BYTE FROM SECTOR
;*
GRANBY  LDX     CFCBAD          ;* GET FCB ADDRESS
        LDAB    2,X             ;* GET STATUS
        LSRB                    ;* SHIFT BIT 1 INTO CARRY
        BCS     GRANB1          ;* YES: OPEN FOR READ
        LDAB    #$12            ;* NO, SYS FILE STAUS ERROR
        BRA     GRANB3          ;* REPORT ERROR
GRANB1  LDAB    35,X            ;* GET RANDOM INDEX
        JMP     DINDX1          ;* GET BYTE AND RETURN
;*
;* STORE BYTE IN FCB AND INC DATA INDEX TO
;* NEXT ADDRESS DISPLACEMENT
;*
GRANB2  LDX     CFCBAD          ;* GET ADDRESS OF CURRENT FCB
        LDAB    34,X            ;* GET DATA INDEX
        PSHB                    ;* SAVE IT
        INC     34,X            ;* BUMP INDEX
        BSR     FMS26           ;* ADDB TO X FOR READ
        STAA    64,X            ;* STORE IN RANDOMLY IN FCB SECTOR BUFFER
        PULB                    ;* RESTORE DATA INDEX INTO B
        INCB                    ;* INCREMENT DATA INDEX
        BNE     PRANB2          ;* NO ERROR THEN RETURN
GRANB3  SEC                     ;* SET CARRY FOR ERROR
        RTS                     ;* RETURN
;*
;* PUT RANDOM BYTE IN SECTOR
;*
PRANBY  LDX     CFCBAD          ;* GET ADDRESS OF FCB
        LDAB    2,X             ;* GET STATUS
        ANDB    #3              ;* MASK OUT UNNECESSARY GARBAGE
        CMPB    #3              ;* OPEN FOR UPDATE?
        BEQ     PRANB1          ;* YES: THEN PUT BYTE
        LDAB    #18             ;* NO, SYS FILE STATUS ERROR
        SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
PRANB1  ORAB    #$80            ;* SET RANDOM ACCESS ACTIVITY STATUS
        STAB    2,X             ;* STORE STATUS IN FCB
        LDAB    15,X            ;* GET FILE ATTRIBUTES
        BITB    #$80            ;* IS FILE WRITE PROTECTED?
        BNE     PRANB3          ;* YES: REPORT IT SO
        LDAB    35,X            ;* GET RANDOM BYTE ADDRESS
        BSR     FMS26           ;* ADD IT TO X FOR OFFSET
        STAA    64,X            ;* STORE BYTE IN SECTOR BUFFER
PRANB2  CLC                     ;* CLEAR CARRY FOR NO ERROR CONDITION
        RTS                     ;* RETURN
;*
;* REPORT FILE OR DISK WRITE PROTECTED
;*
PRANB3  LDAB    #11             ;* DISK ERROR #11 (FILE OR DISK IS WRITE PROTECTED)
        SEC                     ;* SET ERROR FLAG IN 'CC'
        RTS                     ;* RETURN
;*
;* SPACE COMPRESSION
;*
SPCOMP  LDAA    59,X            ;* CK SPACE COMPRESSION FLAG
        BMI     DINDEX          ;* NO SPACE COMPRESSION
        BEQ     SPCOM1          ;* IF ZERO THEN DONE
        DECA                    ;* DO SPACE COMPRESSION
        STAA    59,X            ;* SAVE NEW SPACE COUNT
        LDAA    #32             ;* DECIMAL CODE FOR SPACE
        BRA     SPCOM3          ;* RETURN WITH SPACE IN A
SPCOM1  BSR     DINDEX          ;* GET BYTE
        BCS     SPCOM4          ;* ERROR RETURN
        CMPA    #24             ;* IS IT A CONTROL/X?
        BHI     SPCOM3          ;* IF GREATER THEN NO ERROR
        BEQ     SPCOM1          ;* YES: IGNORE IT
        CMPA    #9              ;* IS IT A TAB CHARACTER?
        BNE     SPCOM2          ;* NO: CONTINUE CHECK
        BSR     DINDEX          ;* YES: IGNORE
        BCS     SPCOM4          ;* ERROR: RETURN
        LDX     CFCBAD          ;* GET CURRENT FCB ADDRESS
        STAA    59,X            ;* SAVE COUNT
        BRA     SPCOMP          ;* AND GET ANOTHER BYTE
SPCOM2  TSTA                    ;* NULL?
        BEQ     SPCOM1          ;* YES: IGNORE
SPCOM3  CLC                     ;* NO: NO ERROR RETURN
SPCOM4  RTS                     ;* RETURN
;*
;* REWIND FILE
;*
REWFIL  JSR     NXTSQ6          ;* WRITE OUT CURRENT SECTOR
        BCS     REWFI1          ;* IF ERROR THEN REPORT IT
        TAB                     ;* PUT FILE STATUS INTO B
        LSRB                    ;* OPEN FOR READ?
        BCC     REWFI1          ;* NO: ERROR
        STAA    0,X             ;* YES: STORE IN COMMAND BYTE
        JMP     OPENR2          ;* RE-OPEN FILE
REWFI1  LDAB    #$12            ;* SYSTEM FILE STATUS ERROR
        SEC                     ;* SEC CARRY FOR ERROR FLAG
        RTS                     ;* RETURN
;*
;* GET DATA INDEX ( BYTE 34 OF FCB )
;*
DINDEX  LDX     CFCBAD          ;* GET FCB ADDRESS
        LDAB    34,X            ;* GET DATA INDEX
        BEQ     DINDX2          ;* IF ZERO READ NEXT SECTOR
        INC     34,X            ;* INCREMENT DATA INDEX
DINDX1  JSR     FMS26           ;* ADD B-REG TO X-REG
        LDAA    64,X            ;* GET BYTE FROM SEC BUFFER
        CLC                     ;* SET 'CC' FOR NO ERROR
        RTS                     ;* RETURN
DINDX2  BSR     RNXTS           ;* READ NEXT SECTOR
        BCC     DINDEX          ;* NO ERROR: GET BYTE
        RTS                     ;* RETURN WITH ERROR
RNXTS   LDX     CFCBAD          ;* GET FCB ADDRESS
        LDAA    64,X            ;* GET TRACK ADDRESS OF NEXT SECTOR
        LDAB    65,X            ;* GET SECTOR ADDRESS NEXT SECTOR
        INC     33,X            ;* INC CURRENT RECORD #
        BNE     RNXTS1          ;* IF NOT ZERO THEN CONTINUE
        INC     32,X            ;* INCREMENT MSB OF RECORD NUMBER
RNXTS1  TSTA                    ;* END OF FILE?
        BNE     RNXTS2          ;* NO:READ MORE
        TSTB                    ;* END OF FILE?
        BEQ     RNXTS4          ;* YES: RETURN
RNXTS2  STAA    30,X            ;* SET TRACK ADDRESS OF NEXT SECTOR TO BE READ
        STAB    31,X            ;* SET SECTOR ADDRESS OF NEXT SECTOR TO BE READ
        PSHA                    ;* SAVE TRACK
        LDAA    #4              ;* SET DATA INDEX TO 1ST
        STAA    34,X            ;* DATA BYTE OF NEW SECTOR
        PULA                    ;* RESTORE TRACK
        BSR     RDSSEC          ;* READ NEW SECTOR OF FILE
        BCC     RNXTS6          ;* NO ERRORS: RETURN
        BITB    #$80            ;* ERRORS: IS IT A NOT READY ERROR?
        BEQ     RNXTS3          ;* NO: READ ERROR
        LDAB    #16             ;* DRIVES NOT READY
        BRA     RNXTS5          ;* ERROR RETURN
RNXTS3  LDAB    #9              ;* DISK FILE READ ERROR
        BRA     RNXTS5          ;* ERROR RETURN
RNXTS4  LDAB    #8              ;* READ PAST END OF FILE
RNXTS5  SEC                     ;* SET ERROR FLAG
RNXTS6  RTS                     ;* RETURN
;*
;* READ SINGLE SECTOR
;*
RDSSEC  BSR     RDSEC5          ;* CLEAR BYTES
        LDX     CFCBAD          ;* POINT TO FCB
        JSR     DRVSEL          ;* SELECT DRIVE
        BCS     RDSEC3          ;* ERROR? YES,RTS
RDSEC1  BSR     RDSEC4          ;* SET CFCBAD TO SEC BUFFER
        JSR     READ            ;* READ SECTOR
        BNE     RDSEC2          ;* ERRORS: HANDLE THEM
        CLC                     ;* CLEAR ERROR FLAG
        RTS                     ;* RETURN
RDSEC2  PSHB                    ;* SAVE STATUS
        BSR     RDSEC6          ;* ERROR HANDLER
        PULB                    ;* RESTORE STATUS
        BCC     RDSEC1          ;* IF OKAY THEN TRY AGAIN
RDSEC3  RTS                     ;* RETURN
;*
;* SET CFCBAD TO BEGINING ADDRESS
;* OF SECTOR BUFFER OF FCB
;*
RDSEC4  LDX     CFCBAD          ;* GET ADDRESS OF FCB
        LDAA    30,X            ;* GET CURRENT TRACK ADDRESS
        LDAB    31,X            ;* GET CURRENT SECTOR ADDRESS
        PSHB                    ;* SAVE SECTOR
        LDAB    #64             ;* POINTER TO START OF SECTOR BUFFER FOR READ
        JSR     FMS26           ;* ADD 64 TO X
        PULB                    ;* RESTORE SECTOR NUMBER
        RTS                     ;* RETURN
RDSEC5  CLRA                    ;* CLEAR A FOR CLEARING NEXT 2 BYTES
        STAA    FTMP3           ;* CLEAR ATTEMPT COUNTER
        STAA    FTMP4           ;* CLEAR RESTORE COUNTER
        RTS                     ;* RETURN
;*
;*  INTERPRETS 1771 ERROR CODES FOR READ SINGLE SECTOR
;*
RDSEC6  BITB    #$10            ;* RECORD NOT FOUND ERROR?
        BNE     RDSEC7          ;* YES: TAKE CARE OF ATTEMPT COUNTER
        BITB    #$80            ;* NOT READY?
        BNE     RDSEC8          ;* YES: SET ERROR AND RETURN
        LDAB    FTMP3           ;* GET ATTEMPT COUNTER
        INCB                    ;* INCREMENT IT
        CMPB    #7              ;* SEVEN TRIES?
        BEQ     RDSEC7          ;* YES: ERROR
        STAB    FTMP3           ;* SAVE NEW ATTEMPT COUNTER VALUE
        BRA     RESER2          ;* TRY AGAIN
RDSEC7  CLR     FTMP3           ;* CLEAR ATTEMPT COUNTER
        LDAB    FTMP4           ;* RESTORE COUNTER
        INCB                    ;* INCREMENT IT
        CMPB    #4              ;* HAVE WE RESTORED 4 TIMES?
        BEQ     RDSEC8          ;* YES: ERROR EXIT
        STAB    FTMP4           ;* SAVE NEW COUNTER VALUE
        LDX     CFCBAD          ;* POINT TO FCB
        JSR     RESTOR          ;* SEEK TRACK 00
RESER2  CLC                     ;* SET NO ERROR FLAG
        RTS                     ;* RETURN
RDSEC8  SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
;*
;* WRITE SINGLE SECTOR
;*
WRSSEC  BSR     RDSEC5          ;* CLEAR ATTEMPT AND RESTORE COUNTERS
        LDX     CFCBAD          ;* POINT TO FCB
        JSR     DRVSEL          ;* SELECT DRIVE
        BCS     WRSEC4          ;* ERROR: ATTEND TO IT
WRSEC1  LDX     CFCBAD          ;* POINT TO FCB
        BSR     RDSEC4          ;* SET CFCBAD TO SEC BUFFER
        JSR     WRITE           ;* WRITE SECTOR
        BNE     WRSEC3          ;* ERROR: HANDLE IT
        LDAA    VERFLG          ;* NO: VERIFY FLAG?
        BEQ     WRSEC2          ;* NOT SET: RETURN
        JSR     VERIFY          ;* YES: VERIFY SEC WRITTEN
        BNE     WRSEC3          ;* ERROR: HANDLE
WRSEC2  CLC                     ;* SET FLAG FOR NO ERROR
        RTS                     ;* RETURN
WRSEC3  BITB    #$40            ;* WRITE PROTECTED?
        BNE     WRSEC6          ;* YES: SAY SO
        PSHB                    ;* SAVE ERROR CODE
        BSR     RDSEC6          ;* ERROR HANDLING ROUTINE
        PULB                    ;* RESTORE STATUS
        BCC     WRSEC1          ;* TRY AGAIN IF OKAY
WRSEC4  RTS                     ;* RETURN
WRSEC5  LDAB    #$20            ;* SET FOR WRITE FAULT
WRSEC6  SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
WRBUF   LDX     CFCBAD          ;* POINT TO  FCB
        LDAB    59,X            ;* SPACE COMPRESSION?
        BMI     WRBUF8          ;* NO: WRITE
        CMPA    #$20            ;* YES: IS IT A SPACE?
        BNE     WRBUF2          ;* NO: FINISH UP SPACE COMPRESSION
        INCB                    ;* INCREMENT SPACE COUNTER
        STAB    59,X            ;* SAVE IN FCB
        CMPB    #127            ;* =127?
        BNE     WRBUF3          ;* NO: OKAY RETURN
        BRA     WRBUF4          ;* YES: WRITE OUT CODE
WRBUF1  BSR     WRBUF4          ;* WRITE OUT SPACE COMPRESSION
        BCC     WRBUF           ;* NO ERRORS CONTINUE
        RTS                     ;* RETURN
WRBUF2  TSTB                    ;* SPACE COMPRESSION FLAG=0?
        BEQ     WRBUF8          ;* YES: WRITE OUT SECTOR
        BRA     WRBUF1          ;* NO: MORE SPACE COMPRESSION
WRBUF3  CLC                     ;* CLEAR ERROR FLAG
        RTS                     ;* RETURN
WRBUF4  PSHA                    ;* SAVE CHARACTER
        CMPB    #1              ;* FIRST SPACE?
        BNE     WRBUF5          ;* NO: WRITE
        LDAA    #$20            ;* YES: SPACE CODE
        BRA     WRBUF6          ;* WRITE BUFFER
WRBUF5  LDAA    #9
        BSR     WRBUF8
        PULA
        BCS     WRBUF7          ;* ERROR: HANDLE IT
        PSHA                    ;* SAVE A
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    59,X            ;* GET SPACE COMPRESSION VALUE
WRBUF6  CLR     59,X            ;* SET TO ZERO
        BSR     WRBUF8          ;* WRITE IT
        PULA                    ;* RESTORE A
WRBUF7  RTS                     ;* RETURN
WRBUF8  LDX     CFCBAD          ;* POINT TO FCB
        LDAB    2,X             ;* GET STATUS FROM FCB
        LSRB                    ;* OPEN FOR READ?
        BCS     SFSERR          ;* YES: SYSTEM FILE STATUS ERROR
        LSRB                    ;* NO: OPEN FOR WRITE?
        BCC     SFSERR          ;* NO: SYSTEM FILE STATUS ERROR
        LDAB    34,X            ;* YES: GET DATA INDEX
        CMPB    #4              ;* BEGINING OF SECTOR BUFFER?
        BNE     WRBUF9          ;* NO: PUT BYTE IN BUFFER
        PSHA                    ;* YES: SAVE A
        BSR     BASE+$1760      ;* ($B760)
        PULA                    ;* RESTORE A
        BCS     WRBUFR          ;* ERROR: RETURN
WRBUF9  JSR     GRANB2          ;* PUT BYTE IN  BUFFER
        BCC     WRBUFR          ;* NO ERROR: CONTINUE
        LDAB    #4              ;* STARING DATA INDEX VALUE
        LDX     CFCBAD          ;* POINT TO FCB
        STAB    34,X            ;* AND SET DATA INDEX FOR START OF DATA
        CLC                     ;* SET FOR NO ERROR
WRBUFR  RTS                     ;* RETURN
SFSERR  LDAB    #$12            ;* SYSTEM FILE STATUS ERROR
        SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
CRECNM  LDX     CFCBAD          ;* POINT TO FCB
        CLRA                    ;* CLEAR A SO TO CLEAR OTHER BYTES
        STAA    32,X            ;* CLEAR MSB OF CURRENT RECORD NUMBER
        STAA    33,X            ;* CLEAR LSB OF CURRENT RECORD NUMBER
        STAA    66,X            ;* CLEAR MSB OF LOGICAL RECORD NUMBER IN SECTOR BUFFER
        STAA    67,X            ;* CLEAR LSB OF LOGICAL RECORD NUMBER IN SECTOR BUFFER
        BRA     BASE+$1784      ;* ($B784)
        LDAB    18,X            ;* GET STARTING SEC
        BNE     BASE+$1784      ;* NOT ZERO:
        LDAB    23,X            ;* RANDOM FILE?
        BEQ     BASE+$17B3      ;* NO
        CLR     23,X            ;* YES: SET FOR SEQUENTIAL
        BSR     BASE+$17B3
        BCS     BASE+$179B
        BSR     CRECNM          ;* CLEAR RECORD NUMBER
        BCS     BASE+$179B
        BSR     CRECNM          ;* CLEAR RECORD NUMBER
        BCS     BASE+$179B
        LDX     CFCBAD          ;* POINT TO FCB
        LDAB    #2              ;* CODE FOR RANDOM FILE
        STAB    23,X            ;* STORE IN FCB
        LDAA    17,X            ;* GET STARTING TRACK ADDRESS
        LDAB    18,X            ;* GET STARTING SECTOR ADDRESS
        JMP     BASE+$1CAA      ;* SAVE IN SCRATCH BYTES AND RETURN
        BSR     BASE+$1795
        LDX     CFCBAD          ;* POINT TO FCB
        STAA    64,X            ;* SET TRACK LINKAGE BYTE
        STAB    65,X            ;* SET SECTOR LINKAGE BYTE
        JSR     WRSSEC          ;* WRITE OUT SECTOR
        BCC     BASE+$17B3      ;* NO ERROR: GO ON
        JMP     WNXTS2          ;* ERROR HANDLER
        BSR     DRVX6           ;* ADD 6*DRIVE NUMBER TO STATUS BUFFER START
        LDAA    0,X             ;* GET TRACK ADDRESS FOR THIS DRIVE FROM REGISTER
        LDAB    1,X             ;* GET SECTOR FOR THIS DRIVE FROM REGISTER
        RTS                     ;* RETURN
DRVX6   LDX     CFCBAD          ;* POINT TO FCB
        LDAB    3,X             ;* GET DRIVE NUMBER FROM FCB
        TBA                     ;* PUTB IN A ALSO
        ASLA                    ;* A=A*2
        ASLA                    ;* A=A*2
        ASLB                    ;* B=B*2
        ABA                     ;* A=6*A TOTAL
        TBA                     ;* INTO B
        LDX     #FTMP11         ;* START OF DISK TEMPORARY SPACE
        JSR     FMS26           ;* ADD B-REG TO X-REG
        STX     FTMP10          ;* SAVE IN TEMPORARY
        TST     0,X             ;* TEST FIRST BYTE OF STATUS
        RTS                     ;* RETURN
        BSR     BASE+$1795      ;* ADD 6*DRIVE TO STATUS BUFFER AND GET FIRST TWO BYTES
        BNE     BASE+$17BB      ;* IF SECTORS LEFT THEN CONTINUE
        LDAB    #7              ;* ALL DISK SPACE USED UP
        SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
        LDX     CFCBAD          ;* POINT TO FCB
        STAA    19,X            ;* SAVE ENDING TRACK ADDRESS
        STAB    20,X            ;* SAVE ENDING SECTOR ADDRESS
        TST     18,X            ;* STARTING SECTOR 0?
        BNE     BASE+$17CA      ;* NO: CONTINUE
        STAA    17,X            ;* YES: ONE SECTOR FILE, SAVE TRACK ADDRESS
        STAB    18,X            ;* SAVE SECTOR ADDRESS
        INC     22,X            ;* BUMP FILE SIZE LSB
        BNE     BASE+$17D0      ;* NO OVERFLOW: GO AROUND
        INC     21,X            ;* INCREMENT CARRY INTO MSB
        TST     23,X            ;* RANDOM FILE?
        BEQ     BASE+$17E0      ;* NO: GO ON
        JSR     BASE+$1C69      ;* YES: UPDATE TRACK AND SECTOR LINKAGES
        BCS     BASE+$17B9      ;* ERROR: SET FLAG AND RETURN
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    19,X            ;* GET ENDING TRACK ADDRESS
        LDAB    20,X            ;* GET ENDING SECTOR ADDRESS
        JSR     RNXTS2          ;* POSITION TO NEXT SEQUENTIAL SECTOR
        BCS     BASE+$17B9      ;* ERROR: RETURN
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    64,X            ;* GET NEXT TRACK ADDRESS
        LDAB    65,X            ;* GET NEXT SECTOR ADDRESS
        PSHA                    ;* SAVE TRACK
        PSHB                    ;* SAVE SECTOR
        BSR     DRVX6           ;* MULTIPLY DRIVE # BY 6 AND ADD TO STATUS BUFFER START
        PULB                    ;* RESTORE SECTOR
        PULA                    ;* RESTORE TRACK ADDRESS
        STAA    0,X             ;* SAVE TRACK IN STATUS BUFFER
        STAB    1,X             ;* SAVE SECTOR IN STATUS BUFFER
        BNE     BASE+$1802      ;* IF NOT SECTOR ZERO: GO ON
        CLR     2,X             ;* CLEAR
        CLR     3,X             ;* THE
        CLR     4,X             ;* REST OF
        CLR     5,X             ;* THE STATUS BYTES
        BRA     BASE+$180C      ;* CONTINUE
        LDAA    5,X             ;* GET SECTOR COUNT
        SUBA    #1              ;* DECRIMENT IT BY ONE
        STAA    5,X             ;* SAVE IT BACK
        BCC     BASE+$180C      ;* IF NO BORROW THEN GO AROUND
        DEC     4,X             ;* BORROW FROM MOST SIGNIFICANT BYTE OF LENGTH
        CLRA                    ;* CLEAR A
        LDX     CFCBAD          ;* POINT TO FCB
        INC     33,X            ;* INCREMENT RECORD NUMBER LSB
        BNE     BASE+$1816      ;* NO OVERFLOW: CONTINUE
        INC     32,X            ;* INCREMENT MSB OF RECORD NUMBER
        LDAB    #0              ;* CLEAR B
        STAA    64,X            ;* SAVE IN SECTOR BUFFER
        INX                     ;* INCREMENT POINTER
        DECB                    ;* DECRIMENT POINTER
        BNE     BASE+$1818      ;* NOT DONE: LOOP
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    32,X            ;* GET MSB OF RECORD NUMBER
        LDAB    33,X            ;* GET LSB OF RECORD NUMBER
        STAA    66,X            ;* SAVE IN SECTOR BUFFER RECORD BYTE
        STAB    67,X            ;* SAVE IN SECTOR BUFFER RECORD BYTE
        CLC                     ;* SET FOR NOERROR EXIT
        RTS                     ;* RETURN
;*
;* OPEN SYSTEM INFORMATION RECORD
;*
OPNINF  CLRB                    ;* SET FOR TRACK ZERO
        PSHB                    ;* SAVE IT
        LDAB    #3              ;* SECTOR NUMBER OF SYSTEM INFORMATION RECORD
        BRA     OPNDI1          ;* AND READ DIRECTORY
        LDX     FTMP6
        STX     FTMP5
;*
;* OPEN DIRECTORY
;*
OPENDI  LDAB    FTMP5           ;* GET TRACK
        PSHB                    ;* SAVE IT
        LDAB    FTMP5+1         ;* GET SECTOR
OPNDI1  LDX     CFCBAD          ;* POINT TO FCB
        STAB    65,X            ;* SAVE SECTOR
        PULB                    ;* GET TRACK
        STAB    64,X            ;* SAVE IT IN FCB
        CLR     FTMP8
        LDAB    #0              ;* ZERO OUT DATA INDEX IN FCB
        STAB    34,X            ;* AND CLEAR IT
        RTS                     ;* RETURN
;*
;* GET INFORMATION RECORD
;*
GETINF  LDX     CFCBAD          ;* POINT TO FCB
        LDAB    34,X            ;* GET CURRENT DATA INDEX
        BNE     GINF2           ;* IF NO FIRST TIME THRU  THEN CONTINUE
        JSR     RNXTS           ;* READ NEXT SECTOR (ADDRESS IN LINKAGE BYTES)
        BCS     GINF4           ;* ERROR
        LDX     CFCBAD          ;* POINT TO FCB
        TST     FTMP8
        BNE     GINF1
        LDAA    $44
        STAA    FTMP8
        LDAA    $45
        STAA    FTMP8+1
GINF1   LDAA    #$10            ;* NUMBER OF BYTES TO SKIP IN DIRECTORY
        STAA    34,X            ;* SAVE IN DATA INDEX FOR FIRST TIME THROUGH
        LDAA    30,X            ;* GET CURRENT TRACK
        LDAB    31,X            ;* GET CURRENT SECTOR
        STAA    47,X            ;* STORE AT CURRENT DIRECTORY TRACK ADDRESS
        STAB    48,X            ;* STORE AT CURRENT DIRECTORY SECTOR ADDRESS
GINF2   LDAA    34,X            ;* GET DATA INDEX
        STAA    49,X            ;* STORE AT CURRENT DIRECTORY DATA INDEX
        LDAB    #$18            ;* NUMBER OF BYTES IN DIRECTORY ENTRY
GINF3   STX     FTMP2           ;* SAVE INDEX REGISTER
        PSHB                    ;* SAVE COUNT
        JSR     DINDEX          ;* READ BYTE
        PULB                    ;* RESTORE COUNT
        LDX     FTMP2           ;* RESTORE X
        STAA    4,X             ;* SAVE IN DIRECTORY PORTION OF FCB
        INX                     ;* BUMP POINTER
        DECB                    ;* DECRIMENT COUNTER
        BNE     GINF3           ;* NOT DONE
        CLC                     ;* SET NO ERROR FLAG
GINF4   RTS                     ;* AND RETURN
;*
;* PUT INFORMATION RECORD
;*
PUTINF  LDX     CFCBAD          ;* POINT TO FCB
        LDAA    49,X            ;* GET STARTING DATA INDEX
        STAA    34,X            ;* STORE IN DATA INDEX
        LDAB    #$18            ;* NUMBER OF BYTES TO TRANSFER TO SECTOR BUFFER
PINF1   STX     FTMP2           ;* SAVE X
        LDAA    4,X             ;* GET BYTE TO  TRANSFER
        PSHB                    ;* SAVE COUNT
        JSR     WRBUF8          ;* WRITE BYTE INTO BUFFER
        PULB                    ;* RESTORE COUNT
        LDX     FTMP2           ;* RESTORE X
        INX                     ;* BUMP POINTER
        DECB                    ;* DECRIMENT COUNTER
        BNE     PINF1           ;* NOT DONE: LOOP
        JMP     WRSSEC          ;* WRITE OUT ENTIRE SECTOR
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    3,X             ;* GET DRIVE NUMBER
        STAA    35,X            ;* STORE IN RANDOM INDEX
        LDAA    FTMP7
        TST     FTMP9
        BNE     BASE+$18ED
        STAA    3,X             ;* STORE IN DRIVE NUMBER
        LDX     FTMP6
        STX     FTMP5           ;* SAVE ADDRESS IN DRIVE STATUS BUFFER
        CPX     #5              ;* TRACK ZERO, SECTOR 5?
        BEQ     BASE+$18D6
        BSR     BASE+$18ED
        BLS     BASE+$1903
        LDX     FTMP8
        STX     FTMP5           ;* SAVE ADDRESS IN DRIVE STATUS BUFFER
        BRA     BASE+$18C5
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    35,X            ;* GET RANDOM INDEX (DRIVE NUMBER)
        STAA    3,X             ;* AND RESTORE DRIVE NUMBER
        BPL     BASE+$18ED      ;* NOT ALL DRIVES
        JSR     FNXTDR          ;* IF ALL DRIVES: FIND NEXT DRIVE
        BCS     BASE+$1918      ;* NO READY DRIVE THEN ERROR
        BSR     BASE+$18ED
        BLS     BASE+$1903
        JSR     BKUP19          ;* TRANSFER NAME WORK BUFFER TO REGULAR FILE NAME
        BRA     BASE+$18DF
        LDX     CFCBAD          ;* POINT TO FCB
        CLR     FTMP9
        JSR     FMS21           ;* SET UP FOR RENAME
        JSR     OPENDI          ;* OPEN DIRECTORY
        JSR     GETINF          ;* GET DATA FROM DIRECTORY
        BCC     BASE+$1904      ;* NO ERROR: GO ON
        CMPB    #8              ;* ERROR 8? (END OF FILE ERROR)
        BEQ     BASE+$1918      ;* YES: ERROR OUT
        SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    4,X             ;* GET FIRST BYTE OF NAME
        BEQ     BASE+$1916      ;* IF ZERO THEN FIND A DELETED ENTRY
        BPL     BASE+$190F      ;* IF DELETED: CONTINUE
        BSR     CURDEL          ;* FIND NEXT DELETED ENTRY
        JSR     FMS23           ;* COMPARE FILE NAME AND EXTENSION TO THE ONE IN THE NAME WORK BUFFER
        BNE     BASE+$18F9      ;* NOT EQAUL: TRY AGAIN
        CLC                     ;* NO ERROR
        RTS                     ;* RETURN
        BSR     CURDEL          ;* FIND NEXT DELETED ENTRY
        CPX     #$FFFF          ;* COMPARE FOR RETURN
        CLC                     ;* SET FOR NO ERROR
        RTS                     ;* RETURN
;*
;* MOVE CURRENT DIRECTORY ADDRESS TO
;* FIRST DELETED DIRECTORY POINTER
;*
CURDEL  LDAA    51,X            ;* GET SECTOR ADDRESS OF DELETED DIRECTORY SECTOR IN BUFFER
        BNE     CURDE1          ;* IF NOT ZERO THEN CONTINUE
        LDAA    47,X            ;* GAT CURRENT DIRECTORY TRACK
        LDAB    48,X            ;* GET CURRENT DIRECTORY SECTOR
        STAA    50,X            ;* SAVE IN FIRST DELETED DIRECTORY TRACK
        STAB    51,X            ;* SAVE IN FIRST DELETED DIRECTORY SECTOR
        LDAA    49,X            ;* GET STATING DATA INDEX
        STAA    52,X            ;* SAVE IN FIRST DELETED DIRECTORY DATA INDEX
CURDE1  RTS                     ;* RETURN
        JSR     DRVX6           ;* MULTIPLY DRIVE # BY SIX
        BNE     BASE+$1954      ;* IF FIRST BYTE OFF OF INDEX REGISTER IS NO ZERO THEN RETURN
        BSR     BASE+$1956
        BCS     BASE+$1955
        LDAB    #6              ;* COUNT OF NUMBER OF BYTES TO MOVE
        LDX     CFCBAD          ;* POINT TO FCB
        STX     FTMP2           ;* SAVE X
        LDX     FTMP2           ;* RESTORE X
        LDAA    93,X            ;* GET BYTE
        INX                     ;* BUMP POINTER
        STX     FTMP2           ;* SAVE POINTER
        LDX     FTMP10          ;* GET ADDRESS OF DESTINATION
        STAA    0,X             ;* SAVE BYTE
        INX                     ;* BUMP POINTER
        STX     FTMP10          ;* SAVE POINTER
        DECB                    ;* DECRIMENT COUNTER
        BNE     BASE+$193F      ;* NOT DONE: LOOP
        CLC                     ;* CLEAR ERROR FLAG
        RTS                     ;* RETURN
        JSR     OPNINF          ;* OPEN INFORMATIN RECORD
        JSR     RNXTS           ;* READ SECTOR
        BCS     BASE+$1965      ;* IF ERROR: TAKE CARE OF IT
        LDX     CFCBAD          ;* POINT TO FCB
        LDAB    #$10            ;* OFFSET TO UNUSD BYTES
        STAB    34,X            ;* SAVE IN DATA INDEX
        RTS                     ;* RETURN
        JSR     DRVX6           ;* GET STATUS BUFFER ADDRESS (DRIVE NUMBER TIMES 6)
        BSR     BASE+$1956
        BCS     BASE+$1965      ;* ERROR: ATTEND TO IT
        LDAB    #6              ;* COUNTER FOR NUMBER OF BYTES TO MOVE
        LDX     CFCBAD          ;* POINT TO FCB
        STX     FTMP2           ;* SAVE POINTER
        LDX     FTMP10          ;* GET SURCE POINTER
        LDAA    0,X             ;* GET BYTE
        INX                     ;* BUMP POINTER
        STX     FTMP10          ;* SAVE POINTER
        LDX     FTMP2           ;* GET DESTINATION ADDRESS
        STAA    93,X            ;* SAVE BYTE
        INX                     ;* BUMP POINTER
        STX     FTMP2           ;* SAVE IT
        DECB                    ;* DECRIMENT COUNTER
        BNE     BASE+$1975      ;* LOOP UNTILL DONE
        JSR     WRSSEC          ;* WRITE OUT SECTOR
        BCC     BASE+$1965      ;* NO ERROR: RETURN
        JMP     WNXTS2          ;* ERROR HANDLER
;*
;*  CHANGE DIRECTORY INFORAMTION
;*
RESER1  LDX     CFCBAD          ;* POINT TO FCB
        LDAA    #2              ;* OPEN FOR WRITE STATUS
        STAA    2,X             ;* MAKE FILE SUCH
        LDAA    47,X            ;* GET TRACK ADDRESS OF CURRENT FILE IN DIRECTORY
        LDAB    48,X            ;* GET SECTOR ADDRESS OF CURRENT FILE IN DIRECTORY
        STAA    30,X            ;* SAVE TRACK IN CURRENT TRACK BYTE
        STAB    31,X            ;* SAVE SECTOR IN CURRENT SECTOR
        JSR     RDSSEC          ;* READ SECTOR TO GET DIRECTORY IN BUFFER
        BCS     BASE+$19AE      ;* ERROR: WRITE ERROR
        JSR     PUTINF          ;* PUT INFORMATION IN DIRECTORY
        BCC     BASE+$19B0      ;* NO ERROR: RETURN
        JMP     WNXTS2          ;* ERROR HANDLER
        LDAB    #10             ;* WRITE ERROR
        RTS                     ;* RETURN
;*
;* OPEN FOR READ
;*
OPENRD  JSR     FMS11
        BCS     OPENR5          ;* ERROR: RETURN
        JSR     BASE+$18AE
OPENR1  BCS     OPENR5          ;* ERROR: RETURN
        BNE     OPENR7
        LDX     CFCBAD          ;* POINT TO FCB
        TST     FTMP9
        BEQ     OPENR2
        LDAA    15,X            ;* GET FILE ATTRIBUTES
        BITA    #$20            ;* READ PROTECT?
        BNE     OPENR6          ;* YES: ERROR
OPENR2  JSR     BASE+$1CF6      ;* NO: FIND FILE IN DIRECTORY
        BCS     OPENR8          ;* NOT FOUND: ERROR
        LDAA    17,X            ;* GET STARTING TRACK ADDRESS
        LDAB    18,X            ;* GET STARTING SECTOR ADDRESS
        STAA    64,X            ;* STORE IN FOWARD
        STAB    65,X            ;* LINKAGE BYTES
        JSR     OPENW7          ;* SET UP PROPER VALUES FOR OPEN FILE IN FCB
        LDAB    23,X            ;* GET FILE SECTOR MAP INDICATOR
        BEQ     OPENR4          ;* SEQUENTIAL FILE: RETURN
OPENR3  PSHB                    ;* SAVE B
        JSR     RNXTS           ;* READ NEXT SECTOR
        PULB                    ;* RESTORE B
        BCS     OPENR5          ;* ERROR: RETURN
        DECB                    ;* DECRIMENT FILE SECTOR MAP INDICATOR
        BNE     OPENR3          ;* LOOP TILL DONE
        LDX     CFCBAD          ;* POINT TO FCB
        LDAB    #0              ;* CLEAR B
        STAB    34,X            ;* CLEAR DATA INDEX
OPENR4  CLC                     ;* SET FOR NO ERROR
OPENR5  RTS                     ;* RETURN
OPENR6  LDAB    #$11            ;* FILE OR DISK IS WRITE PROTECTED
        BRA     OPENR8          ;* ERROR RETURN
OPENR7  LDAB    #4              ;* FILE ALREADY EXISTS
OPENR8  PSHB                    ;* SAVE B
        JSR     FMS13           ;* SET RESET FCB BASE POINTER AND ERROR CODE
        PULB                    ;* RESTORE ERROR CODE
        SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
;*
;* OPEN FOR WRITE
;*
OPENWR  LDX     CFCBAD          ;* POINT TO CURRENT FCB
        TST     3,X             ;* WHAT DRIVE?
        BPL     OPENW1          ;* DRIVES NOT ALL: OPEN ASSIGNED DRIVE
        JSR     FNXTDR          ;* FIND FIRST AVAILABLE DRIVE
        BCC     OPENW1          ;* NO ERROR: CONTINUE OPEN
        LDAB    #$10            ;* DRIVES NOT READY CODE
        RTS                     ;* RETURN
OPENW1  JSR     FMS11           ;* SET UP FMS AND CHECK FOR IN USE
        BCS     OPENR8          ;* IN USE: ERROR
        JSR     FMS19           ;* INITIALIZE FCB
        JSR     BASE+$192E
        BCS     OPENR8          ;* ERROR: RETURN
        JSR     BASE+$18AE
        BCS     OPENR8          ;* ERROR: RETURN
        BNE     OPENW2
        LDAB    #3              ;* FILE ALREADY EXITS CODE
        BRA     OPENR8          ;* ERROR OUT
OPENW2  JSR     BASE+$1CF6
        BCS     OPENR8          ;* ERROR RETURN
        LDX     CFCBAD          ;* POINT TO FCB
        LDAB    #10             ;* DIVES NOT READY
OPENW3  CLR     15,X            ;* CLEAR FCB INFO
        INX                     ;* BUMP POINTER
        DECB                    ;* DECRIMENT COUNTER
        BNE     OPENW3          ;* AND LOOP
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    50,X            ;* GET TRACK OF FIRST DELETED DIRECTORY POINTER
        LDAB    51,X            ;* AND SECTOR OF ABOVE
        BEQ     OPENW4          ;* NONE: THEN ADD TO END OF DIRECTORY
        STAA    47,X            ;* SAVE IN CURRENT DIRECTORY ADDRESS
        STAB    48,X            ;* AND SAVE SECTOR
        LDAA    52,X            ;* GET STARTING DATA INDEX
        STAA    49,X            ;* SAVE SAVE IT
        LDAA    DDATE            ;* GET MONTH OF DDATE
        LDAB    DDATE+1          ;* GET DAY OF DDATE
        STAA    25,X            ;* SAVE IN CURRENT MONTH
        STAB    26,X            ;* SAVE IN CURRENT DAT
        LDAA    DDATE+2          ;* GET YEAR
        STAA    27,X            ;* SAVE IN CURRENT YEAR
        JSR     BKUP19          ;* MOVE FILENAME FROM NAME WORK BUFFER NAME AREA
        JSR     RESER1          ;* WRITE OUT NEW DDATE
        BCS     OPENR8          ;* ERROR: RETURN
        BSR     OPENW7          ;* INITIALIZE FLAGS
        LDAA    #4              ;* NUMBER OF BYTES PAST SART OF BUFFER
        STAA    34,X            ;* PUT IN DATA INDEX TO SKIP LINKAGE BYTES
        CLC                     ;* SET FOR NO ERROR
        RTS                     ;* RETURN
OPENW4  LDX     CFCBAD          ;* POINT TO FCB
        CLR     23,X            ;* CLEAR RANDOM FILE INDICATOR (FILE SECTOR MAP)
        INC     18,X            ;* BUMP START OF FILE POINTER
        LDAA    47,X            ;* GET CURRENT DIRECTORY TRACK ADDRESS
        LDAB    48,X            ;* GET CURRENT DIRECTORY SECTOR ADDRESS
        JSR     RNXTS2          ;* READ THAT SECTOR
        BCS     OPENW5          ;* ERROR: OUTPUT ERROR AND RETURN
        JSR     BASE+$1784      ;* SET UP FOR WRITE
        BCS     OPENW5          ;* ERROR: PRINT IT
        JSR     WRSSEC          ;* WRITE OUT SECTOR
        BCC     OPENW6          ;* NO ERROR: CONTINUE
        JSR     WNXTS2          ;* ERROR: INTERPRET IT
OPENW5  JMP     OPENR8          ;* AND PRINT ERROR
OPENW6  LDX     CFCBAD          ;* POINT TO FCB
        LDAA    30,X            ;* GET CURRENT TRACK
        LDAB    31,X            ;* GET CURRENT SECTOR
        STAA    50,X            ;* SAVE IN FIRST DELETED
        STAB    51,X            ;* DIRECTORY POINT
        LDAA    #$10            ;* SDI FOR FIRST DELETED DIRECTORY POINTER
        STAA    52,X            ;* SAVE IN SDI
        JSR     BASE+$1966
        BCS     OPENW5          ;* ERROR: ATTEND TO IT
        BRA     OPENW2          ;* AND DO IT AGAIN
OPENW7  LDX     CFCBAD          ;* POINT TO FCB
        LDAA    0,X             ;* GET CURRENT COMMAND CODE
        STAA    2,X             ;* SAVE IN STATUS
        CLR     0,X             ;* CLEAR COMMAND BYTE
        CLR     59,X            ;* CLEAR SPACE COMPRESSION FLAG (BINARY)
        LDAA    #0              ;* CLEAR A
        STAA    34,X            ;* CLEAR CLEAR DATA INDEX
        RTS                     ;* RETURN
;*
;* NEXT SEQUENTIAL SECTOR
;*
NXTSEQ  BSR     NXTSQ6          ;* CHECK FOR LEGAL STATUS
        BCS     NXTSQ2          ;* ERROR: RETURN WITH IT
        CLR     0,X             ;* CLEAR COMMAND BYTE
        LSRA                    ;* CHECK FOR READ
        BCC     NXTSQ1          ;* WRITE: CONTINUE
        JMP     RNXTS           ;* OTHERWISE READ
NXTSQ1  LDAB    #4              ;* SET FOR AFTER LINKAGE BYTES
        STAB    34,X            ;* SAVE IN DATA INDEX
        CLC                     ;* CLEAR CARRY FOR NO ERROR OUT
NXTSQ2  RTS                     ;* RETURN
NXTSQ3  LDX     CFCBAD          ;* POINT TO FCB
        LDAA    2,X             ;* GET STATUS
        CMPA    #$83            ;* OPEN FOR RANDOM READ & WRITE?
        BNE     NXTSQ5          ;* NO: RETURN
        LDAA    #3              ;* CODE FOR READ/WRITE
        STAA    2,X             ;* STORE IN STATUS BYTE OF FCB
NXTSQ4  JSR     WRSSEC          ;* WRITE OUT SECTOR
        BCC     NXTSQ5          ;* NO ERROR RETURN
        JMP     WNXTS2          ;* ERROR INTERPRETER
NXTSQ5  CLC                     ;* SET FOR NO ERROR
        RTS                     ;* RETURN
NXTSQ6  BSR     NXTSQ3          ;* CHECK STATUS
        BCS     NXTSQ8          ;* ERROR RETURN
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    2,X             ;* GET STATUS
        CMPA    #3              ;* OPEN FOR READ/WRITE?
        BHI     NXTSQ7          ;* NO SET SYSTEM FILE STATUS ERROR
        CLC                     ;* SET FOR NO ERROR
        RTS                     ;* RETURN
NXTSQ7  LDAB    #$12            ;* CODE FOR STATUS ERROR (18)
        SEC                     ;* SET ERROR FLAG
NXTSQ8  RTS                     ;* AND RETURN
;*
;* CLOSE FILE
;*
CLSFIL  BSR     NXTSQ6          ;* CHECK FOR PROPER STATUS & WRITE IF WRITING
        BCS     CLSFI6          ;* ERROR TRAP
        CMPA    #2              ;* OPEN FOR WRITE?
        BEQ     CLSFI2          ;* YES: MORE TO DO
CLSFI1  LDX     CFCBAD          ;* NO: POINT TO FCB
        CLR     2,X             ;* CLR ACTIVITY FLAG IN FDB
        JMP     FMS13           ;* REMOVE FROM CHAIN AND RETURN
CLSFI2  LDAA    18,X            ;* GET SECTOR ADDRESS
        BNE     CLSFI3          ;* SOME WRITING DONE THEN CLOSE
        JSR     RENAMD          ;* DELETE FILE OTHERWISE
        BRA     CLSFI5          ;* AND FINISH UP
CLSFI3  BSR     NXTSQ4          ;* WRITE OUT CURRENT SECTOR
        BCS     CLSFI6          ;* ERROR TRAP
        LDX     CFCBAD          ;* POINT TO FCB
        TST     23,X            ;* RANDOM FILE?
        BEQ     CLSFI4          ;* NO CONTINUE
        JSR     BASE+$1CC0
        BCS     CLSFI6          ;* ERROR TRAP
CLSFI4  JSR     RESER1          ;* FIX UP DIRECTORY
        BCS     CLSFI6          ;* ERROR TRAP
        JSR     BASE+$1966
CLSFI5  BCC     CLSFI1          ;* NO ERROR: FINISH UP CLOSE
CLSFI6  RTS                     ;* RETURN
;*
;* OPEN FOR UPDATE
;*
OPENUP  JSR     OPENRD          ;* OPEN FILE FOR READ
        BCS     OPNUP2          ;* ERROR TRAP
        JSR     RNXTS           ;* READ NEXT SECTOR
        BCS     OPNUP2          ;* ERROR TRAP
        LDAA    #3              ;* OPEN FOR RANDOM READ/WRITE CODE
        BRA     OPNUP1          ;* AND OPEN FILE
;*
;*  OPEN FOR UPDATE FMS CODE $13
;*
RESER3  JSR     OPENRD          ;* OPEN FOR READ
        BCS     OPNUP2          ;* ERROR TRAP
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    15,X            ;* GET FILE ATTRIBUTES
        BITA    #$80            ;* WRITE PROTECTED?
        BNE     OPNUP3          ;* YES: ERROR
        LDAA    19,X            ;* GET TRACK ADDRESS OF LAST SECTOR OF FILE
        LDAB    20,X            ;* GET SECTOR ADDRESS OF LAST SECTOR OF FILE
        JSR     RNXTS2          ;* POSITION TO THAT SECTOR
        BCS     OPNUP2          ;* ERROR TRAP
        LDAA    #2              ;* OPEN FOR WRITE
OPNUP1  LDX     CFCBAD          ;* POINT TO FCB
        STAA    2,X             ;* STORE IN STATUS BYTE
        CLC                     ;* SET FOR NO ERROR
OPNUP2  RTS                     ;* AND RETURN
OPNUP3  LDAB    #$B             ;* FILE IS WRITE PROTECTED CODE
        SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
;*
;* RENAME FILE
;*
RENAME  BSR     RENAM5          ;* SWAP OLD AND NEW FILE NAMES
        JSR     BASE+$18AE
        BCS     RENAM3          ;* ERROR TRAP
        BEQ     RENAM2          ;* FILE EXISTS ERROR
        LDX     CFCBAD          ;* POINT TO FCB
        LDAB    #$B             ;* NUMBER OF CHARACTERS IN FILE NAME
RENAM1  LDAA    36,X            ;* GET CHARACTER OF OLD FILE NAME
        STAA    4,X             ;* AND STORE IN CURRENT NAME BYTES
        INX                     ;* BUMP POINTER
        DECB                    ;* DECRIMENT COUNTER
        BNE     RENAM1          ;* LOOP TILL DONE
        BSR     RENAM9          ;* SWAP NAMES AGAIN
        BCS     RENAM3          ;* ERROR TRAP
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    15,X            ;* GET ATTRIBUTES
        BITA    #$80            ;* WRITE PROTECTED?
        BNE     OPNUP3          ;* YES: WRITE PROTECT ERROR
        BITA    #$60            ;* DELETE OR READ PROTECT?
        BNE     RENAM4          ;* YES: FILE IS PROTECTED
        BSR     RENAM5          ;* SWAP NAMES AGAIN
        JMP     RENAMF          ;* CONTINUE
RENAM2  LDAB    #3              ;* FILE EXISTS CODE
        SEC                     ;* SET ERROR FLAG
RENAM3  RTS                     ;* RETURN
RENAM4  LDAB    #$C             ;* FILE IS PROTECTED CODE
        SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
;*
;* CHANGE NAME
;*
RENAM5  LDX     CFCBAD          ;* POINT TO FCB
        LDAA    #$B             ;* NUMBER OF CHARACTERS IN FILE NAME
        STAA    FTMP3           ;* SAVE IN TEMPORARY
RENAM6  LDAA    4,X             ;* GET NAME BYTE
        LDAB    53,X            ;* GET NEW NAME BYTE
        STAA    53,X            ;* SWAP BOTH
        STAB    4,X             ;* BYTES
        INX                     ;* BUMP POINTER
        DEC     FTMP3           ;* DECRIMENT COUNTER
        BNE     RENAM6          ;* LOOP TILL DONE
;*
;* CHANGE EXT
;*
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    12,X            ;* GET BYTE OF EXTENSION
        BNE     RENAM8          ;* IF NULL GO ON
        LDAB    #3              ;* NUMBER OF BYTES IN EXTENSION
RENAM7  LDAA    61,X            ;* GET NEW EXTENSION
        STAA    12,X            ;* STORE IN EXTENSION
        INX                     ;* BUMP POINTER
        DECB                    ;* DECRIMENT COUNTER
        BNE     RENAM7          ;* LOOP TILL DONE
RENAM8  LDX     CFCBAD          ;* POINT TO FCB
        RTS                     ;* RETURN
RENAM9  BSR     RENAM5          ;* SWAP NAMES
RENAMA  JSR     BASE+$18AE
        BCS     RENAMB          ;* ERROR TRAP
        BNE     RENAMC          ;* NO SUCH FILE ERROR
        LDX     CFCBAD          ;* POINT TO FCB
        CLC                     ;* SET FOR NO ERROR
RENAMB  RTS                     ;* RETURN
RENAMC  LDAB    #4              ;* FILE NOT FOUND ERROR CODE
        SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
RENAMD  LDX     CFCBAD          ;* POINT TO FCB
        LDAA    #$FF            ;* CODE FOR DELETED FILE
        STAA    4,X             ;* SAVE IN FIRST CHARACTER OF FILE NAME
RENAMF  JSR     RESER1          ;* CHANGE DIRECTORY INFORMATION
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    #0              ;* SET ACTIVITY CODE TO ZERO
        STAA    2,X             ;* CLR ACTIVITY FLAG IN FCB
        RTS                     ;* RETURN
WNXTS1  STAA    64,X            ;* STORE TRACK ADDRESS IN BUFFER
        STAB    65,X            ;* STORE ADDRESS OF NEXT SECTOR IN BUFFER
        JSR     WRSSEC          ;* WRITE OUT SECTOR
        BCC     WNXTSR          ;* NO ERROR RETURN
WNXTS2  BITB    #$40            ;* WRITE PROTECTED FROM 1771?
        BNE     WNXTS3          ;* YES: ERROR
        BITB    #$80            ;* DRIVES NOT READY FROM 1771?
        BEQ     WNXTS4          ;* NO JUST RETURN
        LDAB    #16             ;* DRIVES NOT READY
        BRA     WNXTS4          ;* RETURN
WNXTS3  LDAB    #11             ;* FILE/DISK IS WR PROTECTED
        BRA     WNXTS4          ;* RETURN
        LDAB    #10             ;* DISK FILE WRITE ERROR
WNXTS4  SEC                     ;* SET ERROR FLAG
WNXTSR  RTS                     ;* RETURN
;*
;* DELETE FILE
;*
DELFIL  JSR     BASE+$192E
        BCS     DELFI4          ;* ERROR TRAP
        JSR     RENAMA
        BCS     DELFI4          ;* ERROR TRAP
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    15,X            ;* GET FILE ATTRIBUTES
        BITA    #$80            ;* WRITE PROTECTED?
        BNE     DELFI5          ;* YES, RETURN ERROR # 11
        BITA    #$60            ;* WRITE & DELETE PROTECTED?
        BNE     DELFI6          ;* YES, RETURN ERROR # 12
        JSR     DRVX6
        LDX     FTMP10
        LDAA    2,X
        LDAB    3,X
        BNE     DELFI1
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    17,X            ;* STARTING TRACK ADDRESS OF FILE
        LDAB    18,X            ;* STARTING SECTOR ADDRESS OF FILE
        BEQ     DELFI3          ;* IF ZERO THEN DON'T WORRY
        LDX     FTMP10
        STAA    0,X
        STAB    1,X
        BRA     DELFI2
DELFI1  LDX     CFCBAD          ;* POINT TO FCB
        JSR     RNXTS2          ;* POSITION TO SECTOR
        BCS     DELFI4          ;* ERROR TRAP
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    17,X            ;* GET STARTING TRACK ADDRESS
        LDAB    18,X            ;* GET STARTING SECTOR ADDRESS
        BEQ     DELFI3
        BSR     WNXTS1          ;* WRITE OUT SECTOR
        BCS     DELFI4          ;* ERROR TRAP
DELFI2  LDX     CFCBAD          ;* POINT TO FCB
        LDAA    19,X            ;* GET ENDING TRACK ADDRESS
        LDAB    20,X            ;* GET ENDING SECTOR ADDRESS
        LDX     FTMP10
        STAA    2,X
        STAB    3,X
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    21,X            ;* GET MSB OF FILE SIZE
        LDAB    22,X            ;* GET LSB OF FILE SIZE
        LDX     FTMP10
        ADDB    5,X
        ADCA    4,X
        STAA    4,X
        STAB    5,X
DELFI3  JSR     RENAMD
        BCS     DELFI4
        JSR     BASE+$1966
DELFI4  RTS                     ;* RETURN
;*
;* RETURN ERROR NUMBER 11
;*
DELFI5  LDAB    #$B             ;* ERROR 11 CODE
        BRA     DELFI7          ;* ERROR RETURN
;*
;* RETURN ERROR NUMBER 12
;*
DELFI6  LDAB    #$C             ;* FILE PROTECTED
DELFI7  SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
        LDAA    30,X            ;* GET CURRENT TRACK
        LDAB    31,X            ;* GET CURRENT SECTOR
        INCB                    ;* BUMP SECTOR BY ONE
        CMPB    60,X
        BLS     BASE+$1C75
        LDAB    #1              ;* SET FOR 1ST SECTOR OF
        INCA                    ;* NEXT TRACK
        CMPA    19,X
        BNE     BASE+$1C88
        CMPB    20,X
        BNE     BASE+$1C88
        LDAA    55,X
        CMPA    #$FF
        BEQ     BASE+$1C88
        INCA
        STAA    55,X
        CLC                     ;* CLEAR ERROR FLAG
        RTS                     ;* RETURN
        JSR     BASE+$1CC0
        BCS     BASE+$1CBF
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    58,X
        ADDA    #3
        BNE     BASE+$1CB0
        LDAA    30,X            ;* GET CURRENT TRACK
        LDAB    31,X            ;* GET CURRENT SECTOR
        CMPA    17,X            ;* DISK STARTING ADDRESS?
        BNE     BASE+$1CA2
        CMPB    18,X            ;* COMPARE SECTOR
        BEQ     BASE+$1CA6
        LDAB    #$17            ;* FILE IS PROTECTED ACCESS DENIED ERROR
        SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
        LDAA    64,X            ;* GET NEXT TRACK
        LDAB    65,X            ;* GET NEXT SECTOR
        STAA    56,X            ;* SAVE NEXT TRACK
        STAB    57,X            ;* SAVE NEXT SECTOR
        LDAA    #4
        STAA    58,X
        LDAA    19,X            ;* GET ENDING TRACK ADDRESS
        LDAB    20,X            ;* GET ENDING SECTOR ADDRESS
        STAA    53,X            ;* AND SAVE TRACK
        STAB    54,X            ;* SAVE SECTOR
        LDAA    #1
        STAA    55,X
        CLC                     ;* CLEAR ERROR FLAG
        RTS                     ;* RETURN

        LDAA    56,X            ;* GET TRACK/SEC FROM RENAME
        LDAB    57,X            ;* SCRATCH AREA OF FCB
        JSR     RNXTS2          ;* POSITION TO THAT SECTOR
        BCS     BASE+$1CBF      ;* ERROR TRAP
        LDX     CFCBAD          ;* POINT TO FCB
        LDAB    58,X
        STX     FTMP2
        JSR     FMS26           ;* ADDB TO X
        STX     FTMP1
        LDAB    #3
        LDX     FTMP2
        LDAA    53,X
        INX
        STX     FTMP2
        LDX     FTMP1
        STAA    64,X
        INX
        STX     FTMP1
        DECB
        BNE     BASE+$1CD9      ;* LOOP TILL DONE
        JSR     WRSSEC          ;* WRITE SECTOR OUT
        BCC     BASE+$1CBF      ;* NO ERROR RETURN
        JMP     WNXTS2          ;* INTERPRET ERROR
;*
        JSR     OPNINF          ;* OPEN INFORMATION RECORD
        JSR     RNXTS           ;* POSITION TO END OF FILE
        BCS     BKUP3           ;* ERROR TRAP
        LDX     CFCBAD          ;* POINT TO FCB
        CLR     32,X            ;* CLEAR CURRENT RECORD #
        CLR     33,X
        LDAA    103,X           ;* GET NUMBER OF SECTORS PER TRACK
        STAA    60,X            ;* SAVE IN SCRATCH AREA
        LDAB    #0              ;* CLEAR FCB BUFFER AREA
        CLR     64,X            ;* CLEAR BYTE
        INX                     ;* BUMP POINTER
        DECB                    ;* DECRIMENT COUNTER
        BNE     BASE+$1D0B      ;* LOOP TILL DONE
        LDX     CFCBAD          ;* POINT TO FCB
        CLC                     ;* CLEAR CARRY
        RTS                     ;* RETURN
;*
;* BACKUP ONE RECORD
;*
BKUP1R  LDX     CFCBAD          ;* POINT TO FCB
        LDAA    23,X            ;* GET FILE SECTOR MAP INDICATOR
        BEQ     BKUP2           ;* NOT SET THEN ERROR
        LDAA    32,X            ;* GET MSB OF RECORD #
        LDAB    33,X            ;* GET LSG OF ABOVE
        SUBB    #1              ;* SEBTRACT ONE FROM LSB
        SBCA    #0              ;* AND SUBTRACT BORROW FROM MSB
        BPL     BKUP1           ;* STILL KOSHER CONTINUE
        JMP     BKUP14          ;* ERROR TRAP (18)
BKUP1   STAA    32,X            ;* SAVE MSB OF RECORD #
        STAB    33,X            ;* SAVE LSB OF RECORD NUMBER
;*
;* POSITION TO RECORD N
;*
POSREC  JSR     NXTSQ6          ;* CHECK FILE STATUS
        BCS     BKUP3           ;* ERROR TRAP
        RORA                    ;* OPEN FOR READ?
        BCC     BKUP2           ;* NO: ERROR TRAP
        CLR     0,X             ;* CLEAR COMMAND BYTE
        LDAA    23,X            ;* GET FILE SECTOR MAP INDICATOR
        BNE     BKUP4           ;* IF SET DON'T ERROR
;*
;* BACKUP ONE RECORD CONTINUED
;*
BKUP2   LDAB    #$12            ;* SYSTEM FILE STATUS ERROR
        SEC                     ;* SET ERROR FLAG
BKUP3   RTS                     ;* RETURN
BKUP4   CLR     FTMP3
        LDAA    17,X            ;* GET STARTING TRACK ADDRESS OF FILE
        LDAB    18,X            ;* GET STARTING SECTOR ADDRESSOF FILE
        TST     32,X            ;* CURRENT RECORD #>255?
        BNE     BKUP5           ;* YES: ATTEND TO MSB
        TST     33,X            ;* RECORD NUMBER ZERO?
        BNE     BKUP5           ;* NO: ATTEND TO IT
        JMP     BKUP12          ;* ERROR TRAP
BKUP5   JSR     BKUP16          ;* MOVE TO PROPER SECTOR AND SET UP X REGISTER
        BCS     BKUP3           ;* ERROR TRAP
        CLRA                    ;* CLEAR A
        CLRB                    ;* CLEAR B
BKUP6   TST     2,X             ;* ZERO RECORDS IN FILE?
        BEQ     BKUP14          ;* YES: ERROR
        ADDB    2,X             ;* GET ADD NUMBER OF RECORDS TO B
        ADCA    #0              ;* AND CARRY TO A
        STX     FTMP2           ;* SAVE X IN SCRATCH
        LDX     CFCBAD          ;* POINT TO FCB
        CMPA    32,X            ;* SAME AS CURRENT RECORD NUMBER MSB?
        BHI     BKUP9           ;* GREATER THEN TRY AGAIN
        BCS     BKUP7           ;* LOWER: TRY AGAIN
        CMPB    33,X            ;* SAME AS CURRENT RECORD NUMBER LSB?
        BCC     BKUP9           ;* HIGHER OR SAME CONTINUE
BKUP7   LDX     FTMP2           ;* POINT TO SECTOR MAP
        INX                     ;* ADVANCE
        INX                     ;* POINTER TO
        INX                     ;* NEXT BLOCK
        PSHA                    ;* SAVE A
        LDAA    FTMP3           ;* GET NUMBER OF BLOCKS IN MAP
        INCA                    ;* INCREMENT IT
        STAA    FTMP3           ;* SAVE IT BACK
        CMPA    #$54            ;* TOTAL NUMBER OF BLOCKS IN THIS SECTOR OF MAP
        BEQ     BKUP8           ;* GET NEXT SECTOR OF MAP
        CMPA    #$A8            ;* END OF ENTIRE MAP?
        PULA                    ;* RESTORE A
        BEQ     BKUP14          ;* YES: NON-EXISTANT RECORD NUMBER
        BRA     BKUP6           ;* BACK TO MAIN LOOP
BKUP8   PSHB                    ;* SAVE B
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    64,X            ;* GET NEXT TRACK ADDRESS
        LDAB    65,X            ;* GET NEXT SECTOR ADDRESS
        JSR     BKUP16          ;* POSITION TO SECTOR AND POINT TO BUFFER+4
        BCS     BKUP14          ;* ERROR TRAP
        PULB                    ;* RESTORE B
        PULA                    ;* RESTORE A
        BRA     BKUP6           ;* BACK TO MAIN LOOP
BKUP9   SUBB    33,X
        SBCA    32,X
        LDX     FTMP2
        LDAA    2,X
        SBA
        DECA
        TAB
        LDAA    0,X
        ADDB    1,X
        LDX     CFCBAD          ;* POINT TO FCB
        BCS     BKUP11
BKUP10  CMPB    60,X
        BLS     BKUP12
BKUP11  SUBB    60,X
        INCA
        BRA     BKUP10
BKUP12  JSR     RNXTS2          ;* POSITION TO NEXT SECTOR
        BCS     BKUP15          ;* ERROR TRAP
        LDX     CFCBAD          ;* POINT TO FCB
        LDAA    66,X            ;* GET MSB OF RECORD NUMBER
        LDAB    67,X            ;* GET LSB OF RECOR NUMBER
        CMPA    32,X            ;* MSB SAME AS CURRENT RECORD NUMBER?
        BNE     BKUP13          ;* NO: CONTINUE
        CMPB    33,X            ;* SAME AS LSB OF RECORD NUMBER
        BEQ     BKUP17          ;* YES: DONE
BKUP13  LDAB    #$19            ;* RECORD NUMBER MATCH ERROR CODE
        SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
BKUP14  LDAB    #$18            ;* NON-EXISTANT RECORD NUMBER ERROR CODE
        SEC                     ;* SET ERROR FLAG
BKUP15  RTS                     ;* RETURN
BKUP16  JSR     RNXTS2          ;* POSITION TO NEXT SECTOR
        BCS     BKUP18          ;* ERROR TRAP
        LDX     CFCBAD          ;* POINT TO FCB
        LDAB    #$44            ;* POINT TO RECORD NUMBER
        JSR     FMS26           ;* ADDB TO X
BKUP17  CLC                     ;* SET FOR NO ERROR
BKUP18  RTS                     ;* RETURN
BKUP19  LDX     CFCBAD          ;* POINT TO FCB
        LDAB    #$B             ;* NUMBER OF CHARACTERS IN FILE NAME
BKUP20  LDAA    36,X            ;* GET CHARACTER FROM NAME WORK BUFFER
        STAA    4,X             ;* SAVE IN FILE NAME
        INX                     ;* BUMP POINTER
        DECB                    ;* DECRIMENT COUNTER
        BNE     BKUP20          ;* LOOP TILL DONE
        RTS                     ;* RETURN
;*
;* FIND NEXT DRIVE
;*
FNXTDR  LDX     CFCBAD          ;* POINT TO FCB
        LDAA    3,X             ;* GET DRIVE NUMBER
        INCA                    ;* INCREMENT IT
        CMPA    #4              ;* LAST DRIVE ON SYSTEM?
        BCC     FNXTD3          ;* YES: DRIVES NOT READY
        STAA    3,X             ;* SAVE BACK IN FCB
        BNE     FNXTD1          ;* NO: CHECK FOR READY
        JSR     CDRRDY          ;* CHECK READY
        BRA     FNXTD2          ;* CHECK IF IT WAS READY
FNXTD1  JSR     QDRRDY          ;* CHECK FOR READY
FNXTD2  BCS     FNXTDR          ;* NO: LOOP
        RTS                     ;* RETURN
FNXTD3  LDAB    #$10            ;* DRIVES NOT READY
        SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
;*
;* DISK DRIVER JUMP TABLE
;*
        ORG     BASE+$1E80
READ    JMP     READ1           ;* READ SINGLE SECTOR
WRITE   JMP     WRIT1           ;* WRITE SINGLE SECTOR
VERIFY  JMP     VER1            ;* VERIFY SECTOR
RESTOR  JMP     REST1           ;* RESTORE TO TRACK ZERO
DRVSEL  JMP     DRVS1           ;* SELECT DRIVE
CDRRDY  JMP     CDRR1           ;* CHECK DRIVE READY
QDRRDY  JMP     CDRR1           ;* QUICK CHECK READY
TCRDR   FCB     0               ;* CURRENT DRIVE REGISTER
        FCB     0
        FCB     0
        FCB     0
TTRKRG  FCB     0               ;* CURRENT TRACK REGISTER
        FCB     0
        FCB     0

;* READ DISK DRIVER

        ORG     BASE+$1EB3
READ1   BSR     READ8           ;* CHECK IF SEEK NEEDED
        LDAA    #$8C            ;* RD 1 REC IBM, HLD, 10MSEC
        TST     MODE            ;* PRINT SPOOLING?
        BEQ     READ2           ;* NO: CONTINUE
        SWI                     ;* YES: TURN OF SPOOLER
READ2   NOP                     ;* NECESSARY FOR NEXT INSTRUCTION
        SEI                     ;* TURN OF INTERRUPTS
        STAA    COMREG          ;* GIVE COMMAND TO DISK
        JSR     DRVS6           ;* DELAY
        LDAB    #0              ;* SET FOR 256 BYTES TO READ
READ3   LDAA    COMREG          ;* READ STATUS
        BITA    #2              ;* DRQ?
        BNE     READ4           ;* YES: READ BYTE
        BITA    #1              ;* NO, BUSY?
        BNE     READ3           ;* YES: READ MORE
        TAB                     ;* SAVE STATUS IN "B"
        BRA     READ5           ;* FINISH UP AND RETURN
READ4   LDAA    DATREG          ;* READ BYTE
        STAA    0,X             ;* STORE IT IN BUFFER
        INX                     ;* POINT TO NEXT BUFFER ADDR
        DECB                    ;* DECREMENT BYTE COUNT
        BNE     READ3           ;* END OF SECTOR? NO, RD NXT
        BSR     READ6           ;* YES: WAIT FOR DISK TO STOP
READ5   BITB    #$1C            ;* ERROR CODE CHECK FOR CALLING ROUTINE
        NOP                     ;* NECESSARY FOR NEXT INSTRUCTION
        CLI                     ;* CLEAR INTERRUPT MASK
        RTS                     ;* RETURN
READ6   TST     MODE            ;* PRINT SPOOLING?
        BEQ     READ7           ;* NO: NO NEED TO STOP
        SWI                     ;* TURN OFF SPOOLER
READ7   LDAB    COMREG          ;* READ STATUS
        BITB    #1              ;* DISK BUSY?
        BNE     READ6           ;* YES: LOOP TILL DONE
        RTS                     ;* NO: RETURN
READ8   CMPA    TRKREG          ;* COMPARE TRACK
        BEQ     READ9           ;* IF SAME DON'T SEEK
        STAA    DATREG          ;* SET UP TRACK TO SEEK TO
        JSR     DRVS6           ;* DELAY
        LDAA    #$18            ;* DO SEEK (CHANGED FROM 1B TO 18)
        STAA    COMREG          ;* GIVE COMMAND TO DISK
        JSR     DRVS6           ;* DELAY
        PSHB                    ;* SAVE B
        BSR     READ6           ;* WAIT FOR DONE
        PULB                    ;* RESTORE B
READ9   STAB    SECREG          ;* SET SECTOR REG
        JMP     DRVS6           ;* DELAY
;*
;* WRITE DISK DRIVER
;*
WRIT1   BSR     READ8           ;* CHECK IF SEEK NEEDED
        LDAA    #$AC            ;* WR 1 REC IBM,HLD, HLT,
;*                      10 MSEC
        TST     MODE            ;* PRINT SPOOLING?
        BEQ     WRIT2           ;* NO: DON'T TURN OFF
        SWI                     ;* YES: TURN OFF SPOOLER
WRIT2   NOP                     ;* NECESSARY FOR NEXT INSTRUCTION
        SEI                     ;* SET INTERRUPT MASK
        STAA    COMREG          ;* GIVE COMMAND TO DISK
        JSR     DRVS6           ;* DELAY
        LDAB    #0              ;* SET FOR 256 BYTES TO WRITE
WRIT3   LDAA    COMREG          ;* READ STATUS
        BITA    #2              ;* DRQ?
        BNE     WRIT4           ;* YES: WRITE A BYTE
        BITA    #1              ;* NO, BUSY?
        BNE     WRIT3           ;* YES: WAIT FOR NEXT DRQ
        TAB                     ;* NO: SAVE STATUS IN B
        BRA     WRIT5           ;* RETURN WILL PROPER CODES FOR FLEX
WRIT4   LDAA    0,X             ;* GET BYTE OF DATA FROM BUF
        STAA    DATREG          ;* WRITE DATA TO DISK
        INX                     ;* POINT TO NEXT BUFFER ADDR
        DECB                    ;* DECREMENT BYTE COUNT
        BNE     WRIT3           ;* END OF SEC? NO, WRITE NXT
        BSR     READ6           ;* YES: WAIT FOR DISK TO FINISH
WRIT5   BITB    #$5C            ;* SET PROPER CODES FOR FMS
        NOP                     ;* NECESSARY FOR NEXT INSTRUCTION
        CLI                     ;* ENABLE INTERRUPTS
        RTS                     ;* RETURN
;*
;* VERIFY DISK DRIVER
;*
VER1    LDAA    #$8C            ;* RD MULTI REC IBM,HL
        TST     MODE            ;* PRINT SPOOLING?
        BEQ     VER2            ;* NO: DON'T TURN IT OFF
        SWI                     ;* YES: TURN IF OFF
VER2    NOP                     ;* NECESSARY FOR NEXT INSTRUCTION
        SEI                     ;* SET INTERRUPT MASK
        STAA    COMREG          ;* SET READ CMD
        JSR     DRVS6           ;* DELAY
        BSR     READ6           ;* WAIT UNTIL ALL DONE READING
        NOP                     ;* NECESSARY FOR NEXT INSTRUCTION
        CLI                     ;* ENABLE INTERRUPTS
        BITB    #$18            ;* SET PROPER CODES FOR FMS
        RTS                     ;* RETURN
;*
;* RESTORE DISK DRIVER
;*
REST1   STX     BASE+$1E97      ;* SAVE FCB ADDRESS IN TEMPS
        BSR     DRVS1           ;* SELECT DRIVE
        LDAA    #8              ;* RESTORE, LHD,CHANGED FROM $B TO 8
        STAA    COMREG          ;* GIVE COMMAND TO DISK
        BSR     DRVS6           ;* DELAY
        JSR     READ6           ;* WAIT UNTIL DONE
        LDX     BASE+$1E97      ;* RESTORE INDEX REGISTER
        BITB    #$40            ;* WRITE PROTECTED?
        BNE     REST2           ;* YES: GIVE ERROR
        CLC                     ;* SET FOR NO ERROR
        RTS                     ;* RETURN
REST2   LDAB    #$B             ;* WRITE PROTECTED ERROR CODE
REST3   CLC                     ;* SET FOR NO ERROR
        RTS                     ;* RETURN
;*
;* DRIVE SLECT DISK DRIVER
;*
DRVS1   LDAA    3,X             ;* GET DRIVE # FROM FCB
        CMPA    #3              ;* GREATER THEN 3?
        BLS     DRVS2           ;* IF LESS THEN 4 OKAY
        CLRA                    ;* SET FOR ZERO
DRVS2   BSR     DRVS3           ;* SET INDEX REGISTER TO PROPER BUFFER FOR DRIVE
        LDAB    TRKREG          ;* GET TRACK
        STAB    0,X             ;* SAVE IN TEMPORARIES
        STAA    DRVREG          ;* SELECT DRIVE
        STAA    TCRDR           ;* SAVE NEW DIRVE IN CURRENT DRIVE NUMBER BYTE
        BSR     DRVS3           ;* SET INDEX REGISTER TO PROPER BUFFER FOR DRIVE
        LDAA    0,X             ;* GET LAST TRACK AT
        STAA    TRKREG          ;* RESET TRACK REG. FOR 1771
        CLC                     ;* CLEAR ERROR FLAG
        BRA     DRVS6           ;* DELAY AND RETURN
DRVS3   LDX     #TTRKRG         ;* ADDRESS OF LAST DISK ADDRESS FOR DRIVE
        LDAB    TCRDR           ;* GET LAST USED DRIVE NUMBER
        BEQ     DRVS5           ;* IF DRIVE ZERO RETURN
DRVS4   INX                     ;* BUMP POINTER
        DECB                    ;* DECRIMENT COUNTER
        BNE     DRVS4           ;* LOOP UNTIL DONE
DRVS5   RTS                     ;* RETURN
DRVS6   JSR     DRVS7           ;* DELAY
DRVS7   JSR     DRVS8           ;* DELAY
DRVS8   RTS                     ;* RETURN
;*
;* CHECK DRIVE READY DISK DRI;* VER
;*
CDRR1   LDAA    3,X             ;* GET DRIVE NUMBER
        CMPA    #1              ;* GREATER THEN ONE (1)?
        BLS     REST3           ;* NO: RETURN
        LDAB    #$80            ;* OTHERWISE RETURN DRIVES NOT READY ERROR
        SEC                     ;* SET ERROR FLAG
        RTS                     ;* RETURN
;*
;* AUTOBLOCK
;*
        ORG     BASE+$1EA3
INVEC   FDB     INCH1           ;* INPUT CHAR ROUNTINE
OUTVEC  FDB     OUTCH1          ;* OUTPUT CHAR ROUNTINE
ACIA    FDB     CTLPOR          ;* BASE OF ACIA
TIMER   FDB     TIMERA+2        ;* TIMER BOARD BASE
IRQADD  FDB     IRQVEC          ;* IRQ VECTOR LOCATION
SWIADD  FDB     SWIVEC          ;* SWI VECTOR LOCATION
MON     FDB     MONITR          ;* MONITOR ENTRY ADDRESS
PCV     FDB     PCVEC           ;* MONITOR PC LOCATION
        END     XFR
