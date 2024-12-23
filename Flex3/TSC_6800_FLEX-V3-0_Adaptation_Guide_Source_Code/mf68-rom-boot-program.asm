* ROM BOOT FOR SWTPC 6800 MF-68
*
* COPYRIGHT (C) 1980 BY
* TECHNICAL SYSTEMS CONSULTANTS, INC.
* PO BOX 2570, W. LAFAYETTE, IN 47906
*

* EQUATES

DRVREG EQU $8014
COMREG EQU $8018
SECREG EQU $801A
DATREG EQU $801B
LOADER EQU $A100

 ORG $7000

START LDAA COMREG TURN MOTOR ON
 CLR DRVREG SELECT DRIVE #0
 LDX #0000
OVR INX DELAY FOR MOTOR SPEEDUP
 DEX
 DEX
 BNE OVR
 LDAB #$0F DO RESTORE COMMAND
 STAB COMREG
 BSR DELAY
LOOP1 LDAB COMREG CHECK WD STATUS
 BITB #1 WAIT TIL NOT BUSY
 BNE LOOP1
 LDAA #1 SETUP FOR SECTOR #1
 STAA SECREG
 BSR DELAY
 LDAB #$8C SETUP READ COMMAND
 STAB COMREG
 BSR DELAY
 LDX #LOADER ADDRESS OF LOADER
LOOP2 BITB #2 DATA PRESENT?
 BEQ LOOP3 SKIP IF NOT
 LDAA DATREG GET A BYTE
 STAA 0,X PUT IN MEMORY
 INX BUMP POINTER
LOOP3 LDAB COMREG CHECK WD STATUS
 BITB #1 IS WD BUSY?
 BNE LOOP2 LOOP IF SO
 JMP LOADER JUMP TO FLEX LOADER
DELAY BSR RTN
RTN RTS
 END START
