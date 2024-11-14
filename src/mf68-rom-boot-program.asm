;*[ Start ]*********************************************************************
;* ROM BOOT FOR SWTPC 6800 MF-68
;*
;* COPYRIGHT (C) 1980 BY
;* TECHNICAL SYSTEMS CONSULTANTS, INC.
;* PO BOX 2570, W. LAFAYETTE, IN 47906
;*


;* EQUATES


DRVREG	EQU  $8014	;* 
COMREG	EQU  $8018	;* 
SECREG	EQU  $801A	;* 
DATREG	EQU  $801B	;* 
LOADER	EQU  $A100	;* 


	ORG  $7000	;* 


START	LDAA COMREG	;* TURN MOTOR ON XXXXXXXX
        CLR  DRVREG     ;* SELECT DRIVE #0
	LDX  #0000	;* 
OVR	INX             ;* DELAY FOR MOTOR SPEEDUP XXXXXXXX
	DEX		;* 
	DEX		;* 
	BNE  OVR 	;* 
	LDAB #$0F       ;* DO RESTORE COMMAND (l == 2)
	STAB COMREG     ;* (l == 2)
	BSR  DELAY	;* 
LOOP1	LDAB COMREG	;* CHECK WD STATUS XXXXXXXX
	BITB #1		;* WAIT TIL NOT BUSY (l == 2)
	BNE  LOOP1	;* 
	LDAA #1		;* SETUP FOR SECTOR #1 (l == 2)
	STAA SECREG     ;* (l == 2)
	BSR  DELAY	;* 
	LDAB #$8C       ;* SETUP READ COMMAND (l == 2)
	STAB COMREG     ;* (l == 2)
	BSR  DELAY	;* 
	LDX  #LOADER	;* ADDRESS OF LOADER
LOOP2	BITB #2		;* DATA PRESENT? XXXXXXXX
	BEQ  LOOP3	;* SKIP IF NOT
	LDAA DATREG     ;* GET A BYTE (l == 2)
	STAA 0,X        ;* PUT IN MEMORY (l == 2)
	INX		;* BUMP POINTER (l == 2)
LOOP3	LDAB COMREG	;* CHECK WD STATUS XXXXXXXX
	BITB #1		;* IS WD BUSY? (l == 2)
	BNE  LOOP2	;* LOOP IF SO
	JMP  LOADER	;* JUMP TO FLEX LOADER
DELAY	BSR  RTN  	;*
RTN	RTS		;* (LABEL/NM only?)
	END		;* START (l == 2)
;*[ Fini ]**********************************************************************
;/* Local Variables: */
;/* mode:asm         */
;/* End:             */
