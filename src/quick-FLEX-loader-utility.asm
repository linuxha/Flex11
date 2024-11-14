;*[ Start ]*********************************************************************
;* QLOAD - QUICK LOADER
;*
;* COPYRIGHT (C) 1980 BY
;* TECHNICAL SYSTEMS CONSULTANTS, INC.
;* PO BOX 2570, W.LAFAYETTE, IN 47906
;*
;* LOADS FLEX FROM DISK ASSUMING THAT THE DISK I/O
;* ROUTINES ARE ALREADY IN MEMORY. ASSUMES FLEX
;* BEGINS ON TRACK #1 SECTOR #1. RETURNS TO
;* MONITOR ON COMPLETION. BEGIN EXECUTION BY
;* JUMPING TO LOCATION $A100.
;*


;* EQUATES


STACK	EQU  $A07F	;* 
MONITR	EQU  $B3F3	;* 
READ	EQU  $BE80	;* 
RESTORE	EQU  $BE89	;* 
DRIVE	EQU  $BE8C	;* 
SCTBUF	EQU  $A300	;* DATA SECTOR BUFFER


;* START OF UTILITY


	ORG  $A100	;* 


QLOAD	LDS  #STACK	;* SETUP STACK XXXXXXXX
	BRA  LOAD0	;* 


TRK	FCB  1  	;* FILE START TRACK
SCT	FCB  1  	;* FILE START SECTOR
DNS	FCB  0  	;* DENSITY FLAG
LADR	FDB  0  	;* LOAD ADDRESS
SBFPTR	FDB  0  	;* SECTOR BUFFER POINTER


LOAD0	LDX  #SCTBUF	;* POINT TO FCB XXXXXXXX
        CLR 3,X		;* SET FOR DRIVE 0
	JSR  DRIVE	;* SELECT DRIVE 0
	LDX  #SCTBUF	;* 
	JSR  RESTORE	;* NOW RESTORE TO TRACK 0
	LDAA TRK        ;* SETUP STARTING TRK & SCT (l == 2)
	STAA SCTBUF     ;* (l == 2)
	LDAA SCT        ;* (l == 2)
	STAA SCTBUF+1   ;* (l == 2)
	LDX  #SCTBUF+256	;* 
	STX  SBFPTR	;* 


;* PERFORM ACTUAL FILE LOAD


LOAD1	BSR  GETCH	;* GET A CHARACTER XXXXXXXX
;* Func1
	CMPA #$02       ;* DATA RECORD HEADER?
	BEQ  LOAD2	;* SKIP IF SO
;* Func1
	CMPA #$16       ;* XFR ADDRESS HEADER?
	BNE  LOAD1	;* LOOP IF NEITHER
	BSR  GETCH	;* GET TRANSFER ADDRESS
	BSR  GETCH	;* DISCARD IT
	BRA  LOAD1	;* CONTINUE LOAD
LOAD2	BSR  GETCH	;* GET LOAD ADDRESS XXXXXXXX
	STAA LADR       ;* (l == 2)
	BSR  GETCH	;* 
	STAA LADR+1     ;* (l == 2)
	BSR  GETCH	;* GET BYTE COUNT
	TAB		;* PUT IN B (l == 2)
	BEQ  LOAD1	;* LOOP IF COUNT=0
LOAD3	PSHB		;* (LABEL/NM only?)
	BSR  GETCH	;* GET A DATA CHARACTER
	PULB		;* 
	LDX  LADR	;* GET LOAD ADDRESS
	STAA 0,X        ;* PUT CHARACTER (l == 2)
	INX		;* 
	STX  LADR	;* 
	DECB		;* END OF DATA IN RECORD? (l == 2)
	BNE  LOAD3	;* LOOP IF NOT
	BRA  LOAD1	;* GET ANOTHER RECORD


;* GET CHARACTER ROUTINE - READS A SECTOR IF NECESSARY


GETCH2	LDX  #SCTBUF	;* POINT TO BUFFER XXXXXXXX
	LDAA 0,X        ;* GET FORWARD LINK (TRACK) (l == 2)
	BEQ  GO 	;* IF ZERO, FILE IS LOADED
	LDAB 1,X        ;* ELSE, GET SECTOR (l == 2)
	JSR  READ	;* READ NEXT SECTOR
	BNE  QLOAD	;* START OVER IF ERROR
	LDX  #SCTBUF+4	;* POINT PAST LINK
	BRA  GETCH1	;* GO GET A CHARACTER
GETCH	LDX  SBFPTR	;* CHECK SECTOR BUFFER POINTER XXXXXXXX
	CPX  #SCTBUF+256	;* OUT OF DATA?
	BEQ  GETCH2	;* GO READ SECTOR IF SO
GETCH1	LDAA 0,X	;* ELSE GET A CHARACTER XXXXXXXX
	INX		;* 
	STX  SBFPTR	;* UPDATE POINTER
	RTS		;* 


;* FILE IS LOADED, RETURN TO MONITOR


GO	LDX  MONITR	;* GET MONITOR ENTRY ADDRESS XXXXXXXX
	JMP  0,X 	;* JUMP THERE


	END		;* 
;*[ Fini ]**********************************************************************
;/* Local Variables: */
;/* mode:asm         */
;/* End:             */
