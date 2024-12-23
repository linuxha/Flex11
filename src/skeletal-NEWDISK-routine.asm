;*[ Start ]*********************************************************************
;* NEWDISK
;*
;* COPYRIGHT (C) 1980 BY
;* TECHNICAL SYSTEMS CONSULTANTS, INC.
;* PO BOX 2570, W. LAFAYETTE, IN 47906
;*
;* DISK FORMATTING PROGRAM FOR 6800 FLEX.
;* GENERAL VERSION DESIGNED FOR WD 1771/1791.
;* THE NEWDISK PROGRAM INITIALIZES A NEW DISKETTE AND
;* THEN PROCEEDS TO VERIFY ALL SECTORS AND INITIALIZE
;* TABLES.  THIS VERSION IS SETUP FOR AN 8 INCH DISK
;* SYSTEM WITH HINTS AT CERTAIN POINTS FOR ALTERING
;* FOR A SINGLE-DENSITY 5 INCH DISK SYSTEM.  THIS
;* VERSION IS NOT INTENDED FOR 5 INCH DOUBLE-DENSITY.
;*


;**************************************************
;* DISK SIZE PARAMETERS
;* **** **** **********
;* THE FOLLOWING CONSTANTS SETUP THE SIZE OF THE
;* DISK TO BE FORMATTED.  THE VALUES SHOWN ARE FOR
;* 8 INCH DISKS.  FOR 5 INCH DISKS, USE APPROPRIATE
;* VALUES. (IE. 35 TRACKS AND 10 SECTORS PER SIDE)
;**************************************************


MAXTRK	EQU  77  	;* NUMBER OF TRACKS
;* SINGLE DENSITY:
SMAXS0	EQU  15  	;* SD MAX SIDE 0 SECTORS
SMAXS1	EQU  30  	;* SD MAX SIDE 1 SECTORS
;* DOUBLE DENSITY:
DMAXS0	EQU  26  	;* DD MAX SIDE 0 SECTORS
DMAXS1	EQU  52  	;* DD MAX SIDE 1 SECTORS


;**************************************************
;* MORE DISK SIZE DEPENDENT PARAMETERS
;* **** **** **** ********* **********
;* THE FOLLOWING VALUES ARE ALSO DEPENDENT ON THE
;* SIZE OF DISK BEING FORMATTED.  EACH VALUE SHOWN
;* IS FOR 8 INCH WITH PROPER 5 INCH VALUES IN
;* PARENTHESES.
;**************************************************


;* SIZE OF SINGLE DENSITY WORK BUFFER FOR ONE TRACK
TKSZ	EQU  5100	;* (USE 3050 FOR 5 INCH)


;* TRACK START VALUE
TST	EQU  40  	;* (USE 0 FOR 5 INCH)


;* SECTOR START VALUE
SST	EQU  73  	;* (USE 7 FOR 5 INCH)


;* SECTOR GAP VALUE
GAP	EQU  27  	;* (USE 14 FOR 5 INCH)


;**************************************************






;* WORK SPACE WHERE ONE TRACK OF DATA IS SETUP


WORK	EQU  $0800	;* WORK SPACE
SWKEND	EQU  TKSZ+WORK	;* SINGLE DENSITY
DWKEND	EQU  TKSZ*2+WORK	;* DOUBLE DENSITY






;* GENERAL EQUATES


FIRST	EQU  $0101	;* FIRST USER SECTOR
FCS	EQU  30  	;* FCB CURRENT SECTOR
FSB	EQU  64  	;* FCB SECTOR BUFFER
IRS	EQU  16  	;* INFO RECORD START
AVLP	EQU  FSB+IRS+13	;* 
DIRSEC	EQU  5  	;* FIRST DIR. SECTOR
RDSS	EQU  9  	;* READ SS FMS CODE
WTSS	EQU  10  	;* WRITE SS FMS CODE
DDATE	EQU  $AC0E	;* DOS DDATE


;* FLEX ROUTINES EQUATES


PSTRNG	EQU  $AD1E	;* 
PUTCHR	EQU  $AD18	;* 
OUTDEC	EQU  $AD39	;* 
GETHEX	EQU  $AD42	;* 
GETCHR	EQU  $AD15	;* 
PCRLF	EQU  $AD24	;* 
INBUF	EQU  $AD1B	;* 
GETFIL	EQU  $AD2D	;* 
INDEC	EQU  $AD48	;* 
ADDBX	EQU  $AD36	;* 
FMS	EQU  $B406	;* 
FMSCLS	EQU  $B403	;* 
OUT2HS	EQU  $AD3C	;* 
WARMS	EQU  $AD03	;* 


;* DISK DRIVER ROUTINES


DWRITE	EQU  $BE83	;* WRITE A SINGLE SECTOR
REST	EQU  $BE89	;* RESTORE HEAD
DSEEK	EQU  $BE9B	;* SEEK TO TRACK






;* TEMPORARY STORAGE
	ORG  $0020	;* 


TRACK	RMB  1  	;* 
SECTOR	RMB  1  	;* 
BADCNT	RMB  1  	;* BAD SECTOR COUNT
DRN	RMB  1  	;* 
SIDE	RMB  1  	;* 
DBSDF	RMB  1  	;* 
DENSE	RMB  1  	;* 
DNSITY	RMB  1  	;* 
TEMP1	RMB  2  	;* 
TEMP2	RMB  2  	;* 
SECCNT	RMB  2  	;* SECTOR COUNTER
FSTAVL	RMB  2  	;* FIRST AVAILABLE
LSTAVL	RMB  2  	;* LAST AVAILABLE
MAXS0	RMB  1  	;* MAX SIDE 0 SECTOR
MAXS1	RMB  1  	;* MAX SIDE 1 SECTOR
MAX	RMB  1  	;* MAX SECTOR
FKFCB	RMB  4  	;* 
VOLNAM	RMB  11  	;* 
VOLNUM	RMB  2  	;* 


	ORG  $0100	;* 


;********************************************
;* MAIN PROGRAM STARTS HERE
;********************************************


NEWDISK	BRA  FORM1	;*


VN	FCB  2  	;* VERSION NUMBER


OUTIN	JSR  PSTRNG	;* OUTPUT STRING XXXXXXXX
OUTIN2	JSR  GETCHR	;* GET RESPONSE XXXXXXXX
	ANDA #$5F       ;* MAKE IT UPPER CASE (l == 2)
;* Func1
	CMPA #'Y'       ;* SEE IF "YES"
	RTS		;* 


LEXIT	JMP  EXIT	;*


FORM1	LDAA #SMAXS0	;* INITIALIZE SECTOR MAX XXXXXXXX
	STAA MAXS0      ;* (l == 2)
	STAA MAX        ;* (l == 2)
	LDAA #SMAXS1    ;* (l == 2)
	STAA MAXS1      ;* (l == 2)
	JSR  GETHEX	;* GET DRIVE NUMBER
	BCS  LEXIT	;* 
	STX  TEMP1	;* 
	LDAA TEMP1+1    ;* (l == 2)
;* Func1
	CMPA #3         ;* ENSURE 0 TO 3
	BHI  LEXIT	;* 
	LDX  #WORK	;* 
	STAA 3,X        ;* (l == 2)
	STAA DRN        ;* (l == 2)
	LDX  #SURES	;* ASK IF HE'S SURE
	BSR  OUTIN	;* PRINT & GET RESPONSE
	BNE  LEXIT	;* EXIT IF "NO"
	LDX  #SCRDS	;* CHECK SCRATCH DRIVE NO.
	JSR  PSTRNG	;* OUTPUT IT
	LDX  #WORK+2	;* 
        CLR  0,X	;* blah
	CLRB		;* 
	JSR  OUTDEC	;* 
	LDAA #'?'       ;* PRINT QUESTION MARK (l == 2)
	JSR  PUTCHR	;* 
	LDAA #$20       ;* (l == 2)
	JSR  PUTCHR	;* 
	BSR  OUTIN2	;* GET RESPONSE
	BNE  LEXIT	;* EXIT IF "NO"
        CLR  DBSDF      ;* CLEAR FLAG
;*** PLACE A "BRA FORM25" HERE IF CONTROLLER
;*** IS ONLY SINGLE SIDED.
	LDX  #DBST	;* ASK IF DOUBLE SIDED
	BSR  OUTIN	;* PRINT & GET RESPONSE
	BNE  FORM25	;* SKIP IF "NO"
        INC  DBSDF      ;* SET FLAG
	LDAA #SMAXS1    ;* SET MAX SECTOR (l == 2)
	STAA MAX        ;* (l == 2)
FORM25	CLR  DENSE	;* INITIALIZE SINGLE DENSITY XXXXXXXX
        CLR  DNSITY     ;*
;*** PLACE A "BRA FORM26" HERE IF CONTROLLER
;*** IS ONLY SINGLE DENSITY.
	LDX  #DDSTR	;* ASK IF DOUBLE DENSITY
	BSR  OUTIN	;* PRINT & GET RESPONSE
	BNE  FORM26	;* SKIP IF "NO"
        INC  DENSE      ;* SET FLAG IF SO
FORM26	LDX  #NMSTR	;* ASK FOR VOLUME NAME XXXXXXXX
	JSR  PSTRNG	;* PRINT IT
	JSR  INBUF	;* GET LINE
	LDX  #FKFCB	;* POINT TO FAKE
	JSR  GETFIL	;* 
FORM27	LDX  #NUMSTR	;* OUTPUT STRING XXXXXXXX
	JSR  PSTRNG	;* 
	JSR  INBUF	;* GET LINE
	JSR  INDEC	;* GET NUMBER
	BCS  FORM27	;* ERROR?
	STX  VOLNUM	;* SAVE NUMBER
	JSR  PCRLF	;* PRINT CR & LF
	LDX  #WORK	;* 
	JSR  REST	;* RESTORE HEAD
	BEQ  FORMAT	;* SKIP IF NO ERROR
	LDX  #WPST	;* 
	BITB #$40       ;* WRITE PROTECT ERROR? (l == 2)
	BNE  EXIT2	;* SKIP IF SO


;* EXIT ROUTINES


EXIT	LDX  #ABORTS	;* REPORT ABORTING XXXXXXXX
EXIT2	JSR  PSTRNG	;* OUTPUT STRING XXXXXXXX
EXIT3	JSR  FMSCLS	;*
	CLI		;* 
	JMP  WARMS	;* RETURN TO FLEX


;**************************************************************
;*
;* ACTUAL FORMAT ROUTINE
;*
;* THIS CODE PERFORMS THE ACTUAL DISK FORMATTING BY PUTTING
;* ON ALL GAPS, HEADER INFORMATION, DATA AREAS, SECTOR LINKING,
;* ETC.  THIS SECTION DOES NOT WORRY ABOUT SETTING UP THE
;* SYSTEM INFORMATION RECORD, BOOT SECTOR, OR DIRECTORY.
;* IT ALSO DOES NOT NEED BE CONCERNED WITH TESTING THE DISK FOR
;* ERRORS AND THE REMOVAL OF DEFECTIVE SECTORS ASSOCIATED WITH
;* SUCH TESTING.  THESE OPERATIONS ARE CARRIED OUT BY THE
;* REMAINDER OF THE CODE IN "NEWDISK".
;* IF USING A WD1771 OR WD1791 CONTROLLER CHIP, THIS CODE SHOULD
;* NOT NEED CHANGING (SO LONG AS THE WRITE TRACK ROUTINE AS
;* FOUND LATER IS PROVIDED).  IF USING A DIFFERENT TYPE OF
;* CONTROLLER, THIS CODE MUST BE REPLACED AND THE WRITE TRACK
;* ROUTINE (FOUND LATER) MAY BE REMOVED AS IT WILL HAVE TO BE
;* A PART OF THE CODE THAT REPLACES THIS FORMATTING CODE.
;* WHEN THIS ROUTINE IS COMPLETED, IT SHOULD JUMP TO 'SETUP'.
;*
;**************************************************************




;* MAIN FORMATTING LOOP




FORMAT	SEI		;* (LABEL/NM only?)
        CLR  TRACK      ;*
FORM3	CLR  SIDE	;* SET SIDE 0 XXXXXXXX
        CLR  SECTOR     ;*
	BSR  TRKHD	;* SETUP TRACK HEADER
FORM32	LDX  #WORK+SST	;* POINT TO SECTOR START XXXXXXXX
	LDAB DNSITY     ;* DOUBLE DENSITY? (l == 2)
	BEQ  FORM4	;* SKIP IF NOT
	LDX  #SST*2+WORK	;* DD SECTOR START
FORM4	JSR  DOSEC	;* PROCESS RAM WITH INFO XXXXXXXX
        INC  SECTOR     ;* ADVANCE TO NEXT
	LDAA SECTOR     ;* CHECK VALUE (l == 2)
	LDAB SIDE       ;* CHECK SIDE (l == 2)
	BNE  FORM45	;* 
;* Func1
	CMPA MAXS0	;*
	BRA  FORM46	;* 
FORM45	CMPA MAXS1	;*
FORM46	BNE  FORM4	;* REPEAT? XXXXXXXX
FORM47	LDAA TRACK	;* GET TRACK NUMBER XXXXXXXX
	LDAB SIDE       ;* FAKE SECTOR FOR PROPER SIDE (l == 2)
	JSR  DSEEK	;* SEEK TRACK AND SIDE
	JSR  WRTTRK	;* WRITE TRACK
FORM5	LDAB DBSDF	;* ONE SIDE? XXXXXXXX
	BEQ  FORM6	;* 
	LDAB SIDE       ;* (l == 2)
	BNE  FORM6	;* 
        COM  SIDE       ;* SET SIDE 1
	BRA  FORM32	;* 
FORM6	INC  TRACK	;* BUMP TRACK XXXXXXXX
	JSR  SWITCH	;* SWITCH TO DD IF NCSSRY
FORM7	LDAA TRACK	;* CHECK VALUE XXXXXXXX
;* Func1
	CMPA #MAXTRK    ;* DONE LAST TRACK?
	BNE  FORM3	;* LOOP IF NOT
	JMP  SETUP	;* DONE...GO FINISH UP




;* SETUP TRACK HEADER INFORMATION


TRKHD	LDX  #WORK	;* POINT TO BUFFER XXXXXXXX
	LDAB DNSITY     ;* DOUBLE DENSITY? (l == 2)
	BNE  TRHDD	;* SKIP IF SO
	LDAB #$FF       ;* (l == 2)
TRHDS1	STAB 0,X	;* INITIALIZE TO $FF XXXXXXXX
	INX		;* 
	CPX  #SWKEND	;* 
	BNE  TRHDS1	;* 
	LDX  #WORK+TST	;* 
	CLRA		;* SET IN ZEROS (l == 2)
	LDAB #6		;* (l == 2)
	BRA  TRHDD2	;* 
TRHDD	LDAB #$4E	;*
TRHDD1	STAB 0,X	;* INITIALIZE TO $4E XXXXXXXX
	INX		;* 
	CPX  #DWKEND	;* 
	BNE  TRHDD1	;* 
	LDX  #TST*2+WORK	;* 
	CLRA		;* SET IN ZEROS (l == 2)
	LDAB #12        ;* (l == 2)
	BSR  SET 	;* 
	LDAA #$F6       ;* SET IN $F6'S (l == 2)
	LDAB #3		;* (l == 2)
TRHDD2	BSR  SET  	;*
	LDAA #$FC       ;* SET INDEX MARK (l == 2)
	STAA 0,X        ;* (l == 2)
	RTS		;* 


;* SET (B) BYTES OF MEMORY TO (A) STARTING AT (X)


SET	STAA 0,X  	;*
	INX		;* 
	DECB		;* 
	BNE  SET 	;* 
	RTS		;* 


;* PROCESS SECTOR IN RAM


DOSEC	CLRA		;* (LABEL/NM only?)
	LDAB #6		;* CLEAR BYTES (l == 2)
        TST  DNSITY     ;* DOUBLE DENSITY?
	BEQ  DOSEC2	;* SKIP IF NOT
DOSEC1	LDAB #12	;* CLEAR 12 BYTES XXXXXXXX
	BSR  SET 	;* 
	LDAA #$F5       ;* SET IN 3 $F5'S (l == 2)
	LDAB #3		;* (l == 2)
DOSEC2	BSR  SET  	;*
	LDAA #$FE       ;* ID ADDRESS MARK (l == 2)
	STAA 0,X        ;* (l == 2)
	INX		;* 
	LDAA TRACK      ;* GET TRACK NO. (l == 2)
	STAA 0,X        ;* (l == 2)
	INX		;* 
	LDAB DNSITY     ;* DOUBLE DENSITY? (l == 2)
	BEQ  DOSEC3	;* SKIP IF NOT
	LDAB SIDE       ;* GET SIDE INDICATOR (l == 2)
	ANDB #$01       ;* MAKE IT 0 OR 1 (l == 2)
DOSEC3	STAB 0,X  	;*
	INX		;* 
	STX  TEMP1	;* SAVE X REGISTER
	LDX  #SSCMAP	;* POINT TO CORRECT MAP
	LDAB DNSITY     ;* (l == 2)
	BEQ  DOSEC4	;* 
	LDX  #DSCMAP	;* 
DOSEC4	LDAB SECTOR	;* GET SECTOR NO. XXXXXXXX
	BEQ  DOSC55	;* 
DOSEC5	INX             ;* GET ACTUAL SECTOR NUMBER XXXXXXXX
	DECB		;* 
	BNE  DOSEC5	;* 
DOSC55	LDAB 0,X  	;*
	LDX  TEMP1	;* RESTORE X REGISTER
	STAB 0,X        ;* (l == 2)
	INX		;* 
	CMPB MAX        ;* END OF TRACK? (l == 2)
DOSEC6	BNE  DOSEC7	;* SKIP IF NOT XXXXXXXX
	INCA		;* BUMP TRACK NO. (l == 2)
	CLRB		;* RESET SECTOR NO. (l == 2)
;* Func1
	CMPA #MAXTRK    ;* END OF DISK?
	BNE  DOSEC7	;* SKIP IF NOT
	CLRA		;* SET ZERO FORWARK LINK (l == 2)
	LDAB #-1        ;* (l == 2)
DOSEC7	INCB            ;* BUMP SECTOR NO. XXXXXXXX
	PSHA		;* SAVE FORWARD LINK (l == 2)
	PSHB		;* 
	LDAA #1		;* SECTOR LENGTH = 256 (l == 2)
	STAA 0,X        ;* (l == 2)
	INX		;* 
	LDAA #$F7       ;* SET CRC CODE (l == 2)
	STAA 0,X        ;* (l == 2)
	INX		;* 
	LDAB DNSITY     ;* DOUBLE DENSITY? (l == 2)
	BNE  DOSEC8	;* SKIP IF SO
	LDAB #11        ;* LEAVE $FF'S (l == 2)
	JSR  ADDBX	;* 
	CLRA		;* PUT IN 6 ZEROS (l == 2)
	LDAB #6		;* (l == 2)
	BRA  DOSEC9	;* 
DOSEC8	LDAB #22	;* LEAVE $4E'S XXXXXXXX
	JSR  ADDBX	;* 
	CLRA		;* PUT IN 12 ZEROS (l == 2)
	LDAB #12        ;* (l == 2)
	BSR  SET 	;* 
	LDAA #$F5       ;* PUT IN 3 $F5'S (l == 2)
	LDAB #3		;* (l == 2)
DOSEC9	JSR  SET  	;*
	LDAA #$FB       ;* DATA ADDRESS MARK (l == 2)
	STAA 0,X        ;* (l == 2)
	INX		;* 
	PULB		;* RESTORE FORWARD LINK (l == 2)
	PULA		;* 
	STAA 0,X        ;* PUT IN SECTOR BUFFER (l == 2)
	STAB 1,X        ;* (l == 2)
	INX		;* 
	INX		;* 
	CLRA		;* CLEAR SECTOR BUFFER (l == 2)
	LDAB #254       ;* (l == 2)
	JSR  SET 	;* 
	LDAA #$F7       ;* SET CRC CODE (l == 2)
	STAA 0,X        ;* (l == 2)
	INX		;* 
	LDAB #GAP       ;* LEAVE GAP (l == 2)
	JSR  ADDBX	;* 
	LDAB DNSITY     ;* DOUBLE DENSITY? (l == 2)
	BEQ  DOSECA	;* SKIP IF NOT
	LDAB #GAP       ;* DD NEEDS MORE GAP (l == 2)
	JSR  ADDBX	;* 
DOSECA	RTS		;* (LABEL/NM only?)


;**************************************************************
;*
;* DISK TESTING AND TABLE SETUP
;*
;* THE FOLLOWING CODE TESTS EVERY SECTOR AND REMOVES ANY
;* DEFECTIVE SECTORS FROM THE FREE CHAIN.  NEXT THE SYSTEM
;* INFORMATION RECORD IS SETUP, THE DIRECTORY IS INITIALIZED,
;* AND THE BOOT IS SAVED ON TRACK ZERO.  ALL THIS CODE SHOULD
;* WORK AS IS FOR ANY FLOPPY DISK SYSTEM.  ONE CHANGE THAT
;* MIGHT BE REQUIRED WOULD BE IN THE SAVING OF THE BOOTSTRAP
;* LOADER.  SPECIAL BOOT LOADERS MIGHT REQUIRE CHANGES IN THE
;* WAY THE BOOT SAVE IS PERFORMED.  FOR EXAMPLE, IT MAY BE
;* NECESSARY TO SAVE TWO SECTORS IF THE BOOT LOADER DOES NOT
;* FIT IN ONE.  ALSO IT MAY BE NECESSARY, BY SOME MEANS, TO
;* INFORM THE BOOT LOADER WHETHER THE DISK IS SINGLE OR
;* DOUBLE DENSITY SO THAT IT MAY SELECT THE PROPER DENSITY
;* FOR LOADING FLEX.
;*
;**************************************************************




;* READ ALL SECTORS FOR ERRORS


SETUP	LDAA MAX	;* GET MAX SECTORS XXXXXXXX
	LDAB #MAXTRK-1  ;* GET NUMBER OF USER TRACKS (l == 2)
	STAB LSTAVL     ;* SET LAST AVAIL. (l == 2)
	STAA LSTAVL+1   ;* (l == 2)
	LDX  #0 	;* 
SETUP0	LDAB #MAXTRK-1	;* FIND TOTAL SECTORS XXXXXXXX
	JSR  ADDBX	;* 
	DECA		;* 
	BNE  SETUP0	;* 
	STX  SECCNT	;* SAVE TOTAL SECTOR COUNT
	LDX  #FIRST	;* SET FIRST AVAIL
	STX  FSTAVL	;* 
	LDAA DRN        ;* (l == 2)
	STAA WORK+3     ;* (l == 2)
	CLRA		;* CLEAR COUNTER (l == 2)
	STAA BADCNT     ;* (l == 2)
	STAA TRACK      ;* SET TRACK (l == 2)
	STAA DNSITY     ;* SNGL DNST FOR TRK 0 (l == 2)
	INCA		;* 
	STAA SECTOR     ;* SET SECTOR (l == 2)
	LDAA #SMAXS0    ;* RESET MAXIMUM (l == 2)
	STAA MAXS0      ;* SECTOR COUNTS (l == 2)
	LDAA #SMAXS1    ;* (l == 2)
	STAA MAXS1      ;* (l == 2)
	LDAB DBSDF      ;* DOUBLE SIDED? (l == 2)
	BNE  SETUP1	;* SKIP IF SO
	LDAA #SMAXS0    ;* (l == 2)
SETUP1	STAA MAX	;* SET MAXIMUM SECTORS XXXXXXXX
SETUP2	BSR  CHKSEC	;* GO CHECK SECTOR XXXXXXXX
	BNE  REMSEC	;* ERROR?
        CLR  BADCNT     ;* CLEAR COUNTER
SETUP4	LDAA TRACK	;* GET TRACK & SECTOR XXXXXXXX
	LDAB SECTOR     ;* (l == 2)
	BSR  FIXSEC	;* GET TO NEXT ADR
	BEQ  SETUP5	;* SKIP IF FINISHED
	STAA TRACK      ;* SET TRACK & SECTOR (l == 2)
	STAB SECTOR     ;* (l == 2)
	BRA  SETUP2	;* REPEAT
SETUP5	JMP  DOTRK	;*


;* CHECK IF SECTOR GOOD


CHKSEC	LDX  #WORK	;* POINT TO FCB XXXXXXXX
	LDAA TRACK      ;* GET TRACK & SECTOR (l == 2)
	LDAB SECTOR     ;* (l == 2)
	STAA FCS,X      ;* SET CURRENT TRK & SCT (l == 2)
	STAB FCS+1,X    ;* (l == 2)
	JMP  READSS	;* GO DO READ


;* SWITCH TO DOUBLE DENSITY IF NECESSARY


SWITCH	LDAB DENSE	;* DOUBLE DENSITY DISK? XXXXXXXX
	BEQ  SWTCH2	;* SKIP IF NOT
	STAB DNSITY     ;* SET FLAG (l == 2)
	LDAB #DMAXS0    ;* RESET SECTOR COUNTS (l == 2)
	STAB MAXS0      ;* (l == 2)
	LDAB #DMAXS1    ;* (l == 2)
	STAB MAXS1      ;* (l == 2)
        TST  DBSDF      ;* DOUBLE SIDED?
	BNE  SWTCH1	;* SKIP IF SO
	LDAB #DMAXS0    ;* (l == 2)
SWTCH1	STAB MAX	;* SET MAX SECTOR XXXXXXXX
SWTCH2	RTS		;* (LABEL/NM only?)


;* SET TRK & SEC TO NEXT


FIXSEC	CMPB MAX	;* END OF TRACK? XXXXXXXX
	BNE  FIXSE4	;* SKIP IF NOT
	INCA		;* BUMP TRACK (l == 2)
	BSR  SWITCH	;* SWITCH TO DD IF NCSSRY
	CLRB		;* RESET SECTOR NO. (l == 2)
FIXSE4	INCB            ;* BUMP SECTOR NO. XXXXXXXX
;* Func1
	CMPA #MAXTRK    ;* END OF DISK?
	RTS		;* 


;* REMOVE BAD SECTOR FROM FREE SECTOR CHAIN


REMSEC	INC  BADCNT	;* UPDDATE COUNTER XXXXXXXX
	BEQ  REMSE1	;* COUNT OVERFLOW?
	LDAA TRACK      ;* GET TRACK (l == 2)
	BNE  REMSE2	;* TRACK 0?
	LDAB SECTOR     ;* GET SECTOR (l == 2)
	CMPB #DIRSEC    ;* PAST DIRECTORY? (l == 2)
	BHI  REMSE2	;* 
REMSE1	LDX  #FATERS	;* REPORT FATAL ERROR XXXXXXXX
	JMP  EXIT2	;* REPORT IT
REMSE2	LDX  #WORK	;* POINT TO FCB XXXXXXXX
	LDAA FSTAVL     ;* GET 1ST TRACK & SECTOR (l == 2)
	LDAB FSTAVL+1   ;* (l == 2)
;* Func1
	CMPA TRACK      ;* CHECK TRACK
	BNE  REMSE3	;* 
	CMPB SECTOR     ;* CHECK SECTOR (l == 2)
	BNE  REMSE3	;* 
	BSR  FIXSEC	;* SET TO NEXT
	STAA FSTAVL     ;* SET NEW ADR (l == 2)
	STAB FSTAVL+1   ;* (l == 2)
	BRA  REMSE8	;* GO DO NEXT
REMSE3	LDAA TRACK	;* GET TRACK & SECTOR XXXXXXXX
	LDAB SECTOR     ;* (l == 2)
	SUBB BADCNT     ;* (l == 2)
	BEQ  REMS35	;* UNDERFLOW?
	BPL  REMSE4	;* 
REMS35	DECA            ;* DEC TRACK XXXXXXXX
	LDAB MAX        ;* RESET SECTOR (l == 2)
REMSE4	STAA FCS,X	;* SET CURRENT ADR XXXXXXXX
	STAB FCS+1,X    ;* (l == 2)
	BSR  READSS	;* GO DO READ
	BNE  REMSE1	;* ERROR?
	LDAA FSB,X      ;* GET LINK ADR (l == 2)
	LDAB FSB+1,X    ;* (l == 2)
	BSR  FIXSEC	;* POINT TO NEXT
	BNE  REMSE6	;* OVERFLOW?
	LDAA FCS,X      ;* GET CURRENT ADR (l == 2)
	LDAB FCS+1,X    ;* (l == 2)
	STAA LSTAVL     ;* SET NEW LAST AVAIL (l == 2)
	STAB LSTAVL+1   ;* (l == 2)
	CLRA		;* SET END LINK (l == 2)
	CLRB		;* 
REMSE6	STAA FSB,X	;* SET NEW LINK XXXXXXXX
	STAB FSB+1,X    ;* (l == 2)
	BSR  WRITSS	;* GO DO WRITE
	BNE  REMSE1	;* ERROR?
REMSE8	LDX  SECCNT	;* GET SEC COUNT XXXXXXXX
	DEX		;* DEC IT ONCE (l == 2)
	STX  SECCNT	;* SAVE NEW COUNT
	LDX  #BADSS	;* REPORT BAD SECTOR
	JSR  PSTRNG	;* OUTPUT IT
	LDX  #TRACK	;* POINT TO ADDRESS
	JSR  OUT2HS	;* OUTPUT IT
	LDAA #$20       ;* (l == 2)
	JSR  PUTCHR	;* 
	INX		;* BUMP TO NEXT (l == 2)
	JSR  OUT2HS	;* 
	JMP  SETUP4	;* CONTINUE


;* READ A SECTOR


READSS	LDX  #WORK	;* POINT TO FCB XXXXXXXX
	LDAA #RDSS      ;* SET UP COMMAND (l == 2)
	STAA 0,X        ;* (l == 2)
	JMP  FMS 	;* GO DO IT


;* WRITE A SECTOR


WRITSS	LDX  #WORK	;* POINT TO FCB XXXXXXXX
	LDAA #WTSS      ;* SETUP COMMAND (l == 2)
	STAA 0,X        ;* (l == 2)
	JSR  FMS 	;* GO DO IT
	BEQ  READSS	;* ERRORS?
	RTS		;* ERROR RETURN (l == 2)


;* SETUP SYSTEM INFORMATION RECORD


DOTRK	CLR  DNSITY	;* BACK TO SINGLE DENSITY XXXXXXXX
	LDX  #WORK	;* POINT TO SPACE
        CLR  FCS,X      ;* SET TO DIS
	LDAA #3		;* SECTOR 3 (l == 2)
	STAA FCS+1,X    ;* (l == 2)
	BSR  READSS	;* READ IN SIR SECTOR
	BNE  DOTRK4	;* ERROR?
	LDX  #WORK	;* FIX POINTER
        CLR  FSB,X      ;* CLEAR FORWARD LINK
        CLR  FSB+1,X    ;*
	LDAA FSTAVL     ;* ADDR. OF 1ST FREE SCTR. (l == 2)
	LDAB FSTAVL+1   ;* (l == 2)
	STAA AVLP,X     ;* SET IN SIR (l == 2)
	STAB AVLP+1,X   ;* (l == 2)
	LDAA LSTAVL     ;* ADDR. OF LAST FREE SCTR. (l == 2)
	LDAB LSTAVL+1   ;* (l == 2)
	STAA AVLP+2,X   ;* PUT IN SIR (l == 2)
	STAB AVLP+3,X   ;* (l == 2)
	LDAA SECCNT     ;* GET TOTAL SECTOR COUNT (l == 2)
	LDAB SECCNT+1   ;* (l == 2)
	STAA AVLP+4,X   ;* PUT IN SIR (l == 2)
	STAB AVLP+5,X   ;* (l == 2)
	LDAA #MAXTRK-1  ;* SET MAX TRACK NO. (l == 2)
	STAA AVLP+9,X   ;* PUT IN SIR (l == 2)
	LDAA MAXS0      ;* SET MAX SECTORS/TRACK (l == 2)
	LDAB DBSDF      ;* DOUBLE SIDED? (l == 2)
	BEQ  DOTRK2	;* 
	LDAA MAXS1      ;* CHANGE FOR DOUBLE SIDED (l == 2)
DOTRK2	STAA AVLP+10,X	;* SAVE IN SIR XXXXXXXX
	LDAA DDATE      ;* SET DDATE INTO SIR (l == 2)
	STAA AVLP+6,X   ;* (l == 2)
	LDAA DDATE+1    ;* (l == 2)
	STAA AVLP+7,X   ;* (l == 2)
	LDAA DDATE+2    ;* (l == 2)
	STAA AVLP+8,X   ;* (l == 2)
	LDAB #13        ;* (l == 2)
	LDX  #VOLNAM	;* POINT TO VOLUME NAME
	STX  TEMP1	;* 
	LDX  #WORK	;* 
	STX  TEMP2	;* 
DOTR33	LDX  TEMP1	;* COPY NAME TO SIR XXXXXXXX
	LDAA 0,X        ;* (l == 2)
	INX		;* 
	STX  TEMP1	;* 
	LDX  TEMP2	;* 
	STAA FSB+IRS,X  ;* (l == 2)
	INX		;* 
	STX  TEMP2	;* 
	DECB		;* DEC THE COUNT (l == 2)
	BNE  DOTR33	;* 
	BSR  WRITSS	;* WRITE SIR BACK OUT
	BEQ  DIRINT	;* SKIP IF NO ERROR
DOTRK4	JMP  REMSE1	;* GO REPORT ERROR XXXXXXXX


;* INITIALIZE DIRECTORY


DIRINT	LDX  #WORK	;* SET POINTER XXXXXXXX
	LDAA #SMAXS0    ;* GET MAX FOR TRK 0 (l == 2)
        TST  DBSDF      ;* SINGLE SIDE?
	BEQ  DIRIN1	;* SKIP IF SO
	LDAA #SMAXS1    ;* SET MAX FOR DS (l == 2)
DIRIN1	STAA FCS+1,X	;* SET UP XXXXXXXX
	JSR  READSS	;* READ IN SECTOR
	BNE  DOTRK4	;* ERROR?
	LDX  #WORK	;* RESTORE POINTER
        CLR  FSB,X      ;* CLEAR LINK
        CLR  FSB+1,X    ;*
	JSR  WRITSS	;* WRITE BACK OUT
	BNE  DOTRK4	;* ERRORS?


;* SAVE BOOT ON TRACK 0 SECTOR 1
;* (MAY REQUIRE CHANGES - SEE TEXT ABOVE)


DOBOOT	LDX  #BOOT	;* POINT TO LOADER CODE XXXXXXXX
	CLRA		;* TRACK #0 (l == 2)
	LDAB #1		;* SECTOR #1 (l == 2)
	JSR  DWRITE	;* WRITE THE SECTOR
	BNE  DOTRK4	;* 


;* REPORT TOTAL SECTORS AND EXIT


	LDX  #WORK	;* SETUP AN FCB
	LDAA #16        ;* OPEN SIR FUNCTION (l == 2)
	STAA 0,X        ;* (l == 2)
	JSR  FMS 	;* OPEN THE SIR
	BNE  DOTRK4	;* 
	LDAA #7		;* GET INFO RECORD FUNCTION (l == 2)
	STAA 0,X        ;* (l == 2)
	JSR  FMS 	;* GET 1ST INFO RECORD
	BNE  DOTRK4	;* 
	LDX  #CMPLTE	;* REPORT FORMATTING COMPLETE
	JSR  PSTRNG	;* 
	LDX  #SECST	;* PRINT TOTAL SECTORS STRING
	JSR  PSTRNG	;* 
	LDX  #WORK+21	;* TOTAL IS IN INFO RECORD
	CLRB		;* 
	JSR  OUTDEC	;* PRINT NUMBER
	JMP  EXIT3	;* ALL FINISHED!




;**************************************************
;* SECTOR MAPS
;* ****** ****
;* THE MAPS SHOWN BELOW CONTAIN THE CORRECT
;* INTERLEAVING FOR AN 8 INCH DISK.  IF USING 5
;* INCH DISKS (SINGLE DENSITY) YOU SHOULD USE
;* SOMETHING LIKE '1,3,5,7,9,2,4,6,8,10' FOR
;* SSCMAP FOR A SINGLE SIDED DISK.
;**************************************************


SSCMAP	FCB  1,6,11,3,8,13,5,10	;* 
	FCB 15,2,7,12,4,9,14	;*
	FCB 16,21,26,18,23,28,20,25	;*
	FCB 30,17,22,27,19,24,29	;*


DSCMAP	FCB  1,14,3,16,5,18,7	;* 
	FCB 20,9,22,11,24,13	;*
	FCB 26,2,15,4,17,6,19	;*
	FCB 8,21,10,23,12,25	;*
	FCB 27,40,29,42,31,44,33	;*
	FCB 46,35,48,37,50,39	;*
	FCB 52,28,41,30,43,32,45	;*
	FCB 34,47,36,49,38,51	;*


;* STRINGS


SURES	FCC  'ARE'	;* YOU SURE? '
	FCB 4	;*
WPST	FCC  'DISK'	;* IS PROTECTED!'
	FCB 4	;*
SCRDS	FCC  'SCRATCH'	;* DISK IN DRIVE '
	FCB 4	;*
FATERS	FCC  'FATAL'	;* ERROR --- '
ABORTS	FCC  'FORMATTING'	;* ABORTED'
	FCB 4	;*
BADSS	FCC  'BAD'	;* SECTOR AT '
	FCB 4	;*
CMPLTE	FCC  'FORMATTING'	;* COMPLETE'
	FCB 4	;*
SECST	FCC  'TOTAL'	;* SECTORS = '
	FCB 4	;*
DBST	FCC  'DOUBLE'	;* SIDED DISK? '
	FCB 4	;*
DDSTR	FCC  'DOUBLE'	;* DENSITY DISK? '
	FCB 4	;*
NMSTR	FCC  'VOLUME'	;* NAME? '
	FCB 4	;*
NUMSTR	FCC  'VOLUME'	;* NUMBER? '
	FCB 4	;*


;***************************************************************
;* WRITE TRACK ROUTINE                                         *
;***************************************************************
;* THIS SUBROUTINE MUST BE USER SUPPLIED.                      *
;* IT SIMPLY WRITES THE DATA FOUND AT "WORK" ($0800) TO THE    *
;* CURRENT TRACK ON THE DISK.  NOTE THAT THE SEEK TO TRACK     *
;* OPERATION HAS ALREADY BEEN PERFORMED.  IF SINGLE DENSITY,   *
;* "TKSZ" BYTES SHOULD BE WRITTEN.  IF DOUBLE, "TKSZ*2"        *
;* BYTES SHOULD BE WRITTEN.  THIS ROUTINE SHOULD PERFORM       *
;* ANY NECESSARY DENSITY SELECTION BEFORE WRITING.  DOUBLE     *
;* DENSITY IS INDICATED BY THE BYTE "DNSITY" BEING NON-ZERO.   *
;* THERE ARE NO ENTRY PARAMETERS AND ALL REGISTERS MAY BE      *
;* DESTROYED ON EXIT.  THE CODE FOR THIS ROUTINE MUST NOT      *
;* EXTEND PAST $0800 SINCE THE TRACK DATA IS STORED THERE.     *
;***************************************************************


;*********************************************
;* WESTERN DIGITAL PARAMTERS
;* ******* ******* *********
;* REGISTERS:
COMREG	EQU  $0000	;* COMMAND REGISTER
TRKREG	EQU  $0000	;* TRACK REGISTER
SECREG	EQU  $0000	;* SECTOR REGISTER
DATREG	EQU  $0000	;* DATA REGISTER
;* COMMANDS:
WTCMD	EQU  $F4  	;* WRITE TRACK COMMAND
;*********************************************


;*********************************************
;* CONTROLLER DEPENDENT PARAMETERS
;* ********** ********* **********
DRVREG	EQU  $0000	;* DRIVE SELECT REGISTER
;*********************************************




WRTTRK	NOP             ;* ROUTINE GOES HERE XXXXXXXX
	RTS		;* 


;**********************************************************
;*
;* BOOTSTRAP FLEX LOADER
;*
;* THE CODE FOR THE BOOTSTRAP FLEX LOADER MUST BE IN MEMORY
;* AT $A100 WHEN NEWDISK IS RUN.  THERE ARE TWO WAYS IT CAN
;* BE PLACED THERE.  ONE IS TO ASSEMBLE THE LOADER AS A
;* SEPARATE FILE AND APPEND IT ONTO THE END OF THE NEWDISK
;* FILE.  THE SECOND IS TO SIMPLY PUT THE SOURCE FOR THE
;* LOADER IN-LINE HERE WITH AN ORG TO $A100.  THE FIRST FEW
;* LINES OF CODE FOR THE LATTER METHOD ARE GIVEN HERE TO
;* GIVE THE USER AN IDEA OF HOW TO SETUP THE LOADER SOURCE.
;*
;* IT IS NOT NECESSARY TO HAVE THE LOADER AT $A100 IN ORDER
;* FOR THE NEWDISK TO RUN.  IT SIMPLY MEANS THAT WHATEVER
;* HAPPENS TO BE IN MEMORY AT $A100 WHEN NEWDISK IS RUN
;* WOULD BE WRITTEN OUT AS A BOOT.  AS LONG AS THE CREATED
;* DISK WAS FOR USE AS A DATA DISK ONLY AND WOULD NOT BE
;* BOOTED FROM, THERE WOULD BE NO PROBLEM.
;*
;**********************************************************


;* 6800 BOOTSTRAP FLEX LOADER


	ORG  $A100	;* 


BOOT	BRA  BOOT1	;*


	FCB 0,0,0	;*
TRK	FCB  0  	;* STARTING TRACK (AT $A105)
SCTR	FCB  0  	;* STARTING SECTOR (AT $A106)
TEMP	FDB  0  	;* 


FCB	EQU  $A300	;* 


BOOT1	JMP  BOOT1	;* ROUTINE GOES HERE XXXXXXXX




;**********************************************************








	END		;* NEWDISK (l == 2)


;*[ Fini ]**********************************************************************
;/* Local Variables: */
;/* mode:asm         */
;/* End:             */
