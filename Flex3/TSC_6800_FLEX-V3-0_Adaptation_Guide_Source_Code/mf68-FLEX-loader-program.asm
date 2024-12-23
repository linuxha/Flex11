* LOADER - FLEX LOADER ROUTINE
*
* COPYRIGHT (C) 1980 BY
* TECHNICAL SYSTEMS CONSULTANTS, INC.
* PO BOX 2570, W.LAFAYETTE, IN 47906
*
* LOADS FLEX FROM DISK.  ASSUMES DRIVE IS ALREADY
* SELECTED AND A RESTORE HAS BEEN PERFORMED BY THE
* ROM BOOT AND THAT STARTING TRACK AND SECTOR OF
* FLEX ARE AT $A105 AND $A106.  BEGIN EXECUTION
* BY JUMPING TO LOCATION $A100.  JUMPS TO FLEX
* STARTUP WHEN COMPLETE.

* EQUATES

STACK   EQU $A07F
SCTBUF  EQU $A300 DATA SECTOR BUFFER

* START OF UTILITY

        ORG $A100

LOAD    LDS #STACK SETUP STACK
        BRA LOAD0

TRK FCB 0 FILE START TRACK
SCT FCB 0 FILE START SECTOR
DNS FCB 0 DENSITY FLAG
TADR FDB $A100 TRANSFER ADDRESS
LADR FDB 0 LOAD ADDRESS
SBFPTR FDB 0 SECTOR BUFFER POINTER

LOAD0 LDAA TRK SETUP STARTING TRK & SCT
 STAA SCTBUF
 LDAA SCT
 STAA SCTBUF+1
 LDX #SCTBUF+256
 STX SBFPTR

* PERFORM ACTUAL FILE LOAD

LOAD1 BSR GETCH GET A CHARACTER
 CMPA #$02 DATA RECORD HEADER?
 BEQ LOAD2 SKIP IF SO
 CMPA #$16 XFR ADDRESS HEADER?
 BNE LOAD1 LOOP IF NEITHER
 BSR GETCH GET TRANSFER ADDRESS
 STAA TADR
 BSR GETCH
 STAA TADR+1
 BRA LOAD1 CONTINUE LOAD
LOAD2 BSR GETCH GET LOAD ADDRESS
 STAA LADR
 BSR GETCH
 STAA LADR+1
 BSR GETCH GET BYTE COUNT
 TAB PUT IN B
 BEQ LOAD1 LOOP IF COUNT=0
LOAD3 PSHB
 BSR GETCH GET A DATA CHARACTER
 PULB
 LDX LADR GET LOAD ADDRESS
 STAA 0,X PUT CHARACTER
 INX
 STX LADR
 DECB END OF DATA IN RECORD?
 BNE LOAD3 LOOP IF NOT
 BRA LOAD1 GET ANOTHER RECORD

* GET CHARACTER ROUTINE - READS A SECTOR IF NECESSARY

GETCH LDX SBFPTR CHECK SECTOR BUFFER POINTER
 CPX #SCTBUF+256 OUT OF DATA?
 BEQ GETCH2 GO READ SECTOR IF SO
GETCH1 LDAA 0,X ELSE, GET A CHARACTER
 INX
 STX SBFPTR UPDATE POINTER
 RTS
GETCH2 LDX #SCTBUF POINT TO BUFFER
 LDAA 0,X GET FORWARD LINK (TRACK)
 BEQ GO IF ZERO, FILE IS LOADED
 LDAB 1,X ELSE, GET SECTOR
 BSR READ READ NEXT SECTOR
 BNE LOAD START OVER IF ERROR
 LDX #SCTBUF+4 POINT PAST LINK
 BRA GETCH1 GO GET A CHARACTER

* FILE IS LOADED, JUMP TO IT

GO LDX TADR GET TRANSFER ADDRESS
 JMP  0,X JUMP THERE

* READ SINGLE SECTOR

* THIS ROUTINE MUST READ THE SECTOR WHOSE TRACK
* AND SECTOR ADDRESS ARE IN A ANB B ON ENTRY.
* THE DATA FROM THE SECTOR IS TO BE PLACED AT
* THE ADDRESS CONTAINED IN X ON ENTRY.
* IF ERRORS, A NOT-EQUAL CONDITION SHOULD BE
* RETURNED.  THIS ROUTINE WILL HAVE TO DO SEEKS.

* WESTERN DIGITAL EQUATES

DRQ EQU 2 DRQ BIT MASK
BUSY EQU 1 BUSY MASK
RDMSK EQU $1C READ ERROR MASK
COMREG EQU $8018 COMMAND REGISTER
TRKREG EQU $8019 TRACK REGISTER
SECREG EQU $801A SECTOR REGISTER
DATREG EQU $801B DATA REGISTER
RDCMND EQU $8C READ COMMAND
SKCMND EQU $1B SEEK COMMAND

* READ ONE SECTOR

READ BSR SEEK SEEK TO TRACK
 LDAA #RDCMND SETUP READ SECTOR COMMAND
 STAA COMREG ISSUE READ COMMAND
 BSR DEL28 DELAY
 CLRB GET SECTOR LENGTH (=256)
 LDX #SCTBUF POINT TO SECTOR BUFFER
READ3 LDAA COMREG GET WD STATUS
 BITA #DRQ CHECK FOR DATA
 BNE READ5 BRANCH IF DATA PRESENT
 BITA #BUSY CHECK IF BUSY
 BNE READ3 LOOP IF SO
 TAB  SAVE ERROR CONDITION
 BRA  READ6
READ5 LDAA DATREG GET DATA BYTE
 STAA 0,X PUT IN MEMORY
 INX BUMP THE POINTER
 DECB DEC THE COUNTER
 BNE READ3 LOOP TIL DONE
 BSR WAIT WAIT TIL WD IS FINISHED
READ6 BITB #RDMSK MASK ERRORS
 RTS RETURN

* WAIT FOR 1771 TO FINISH COMMAND

WAIT LDAB COMREG GET WD STATUS
 BITB #BUSY CHECK IF BUSY
 BNE WAIT LOOP TIL NOT BUSY
 RTS RETURN

* SEEK THE SPECIFIED TRACK

SEEK STAB SECREG SET SECTOR
 CMPA TRKREG DIF THAN LAST?
 BEQ DEL28 EXIT IF NOT
 STAA DATREG SET NEW WD TRACK
 BSR DEL28 GO DELAY
 LDAA #SKCMND SETUP SEEK COMMAND
 STAA COMREG ISSUE SEEK COMMAND
 BSR DEL28 GO DELAY
 BSR WAIT WAIT TIL DONE

* DELAY

DEL28 JSR DEL14
DEL14 JSR DEL
DEL RTS
 END
