;*[ Start ]*********************************************************************
;* CONSOLE I/O DRIVER PACKAGE
;*
;* COPYRIGHT (C) 1980 BY
;* TECHNICAL SYSTEMS CONSULTANTS, INC.
;* PO BOX 2570, W. LAFAYETTE, IN 47906
;*
;* CONTAINS ALL TERMINAL I/O DRIVERS AND INTERRUPT HANDLING
;* INFORMATION. THIS VERSION IS FOR A SWTPC SYSTEM USING
;* A SWTBUG MONITOR AND THE MF-68 MINIFLOPPY SYSTEM. THE
;* INTERRUPT TIMER ROUTINES ARE FOR A SWTPC MP-T TIMER
;* CARD ADDRESSED AT $8012.
;*

;*    SYSTEM EQUATES

CHPR	EQU  $A700	;* CHANGE PROCESS ROUTINE
TMPIA	EQU  $8012	;* TIMER PIA ADDRESS
ACIA	EQU  $8004	;* ACIA ADDRESS
;***************************************************************
;*                                                             *
;* I/O ROUTINE VECTOR TABLE                                    *
;*                                                             *
	ORG  $B3E5	;* TABLE STARTS AT $B3E5    *
;*                                                             *
INCHNE	FDB  INNECH	;* INPUT CHAR - NO ECHO     *
IHNDLR	FDB  IHND	;* IRQ INTERRUPT HANDLER    *
SWIVEC	FDB  $A012	;* SWI VECTOR LOCATION      *
IRQVEC	FDB  $A000	;* IRQ VECTOR LOCATION      *
TMOFF	FDB  TOFF	;* TIMER OFF ROUTINE        *
TMON	FDB  TON  	;* TIMER ON ROUTINE         *
TMINT	FDB  TINT	;* TIMER INITIALIZE ROUTINE *
MONITR	FDB  $E0D0	;* MONITOR RETURN ADDRESS   *
TINIT	FDB  INIT	;* TERMINAL INITIALIZATION  *
STAT	FDB  STATUS	;* CHECK TERMINAL STATUS    *
OUTCH	FDB  OUTPUT	;* TERMINAL CHAR OUTPUT     *
INCH	FDB  INPUT	;* TERMINAL CHAR INPUT      *
;*                                                             *
;***************************************************************


;* ACTUAL ROUTINES START HERE
;******************************

	ORG  $B390	;* 


;* TERMINAL INITIALIZE ROUTINE

INIT	LDAA #$13	;* RESET ACIA XXXXXXXX
	STAA ACIA       ;* (l == 2)
	LDAA #$11       ;* CONFIGURE ACIA (l == 2)
	STAA ACIA       ;* (l == 2)
	RTS		;* 


;* TERMINAL INPUT CHAR. ROUTINE - NO ECHO

INNECH	LDAA ACIA	;* GET ACIA STATUS XXXXXXXX
	ANDA #$01       ;* A CHARACTER PRESENT? (l == 2)
	BEQ  INNECH	;* LOOP IF NOT
	LDAA ACIA+1     ;* GET THE CHARACTER (l == 2)
	ANDA #$7F       ;* STRIP PARITY (l == 2)
	RTS		;* 


;* TERMINAL INPUT CHAR. ROUTINE - W/ ECHO

INPUT	BSR  INNECH	;*


;* TERMINAL OUTPUT CHARACTER ROUTINE


OUTPUT	PSHA            ;* SAVE CHARACTER XXXXXXXX
OUTPU2	LDAA ACIA	;* TRANSMIT BUFFER EMPTY? XXXXXXXX
	ANDA #$02	;* (l == 2)
	BEQ  OUTPU2	;* WAIT IF NOT
	PULA		;* RESTORE CHARACTER (l == 2)
	STAA ACIA+1     ;* OUTPUT IT (l == 2)
	RTS		;* 


;* TERMINAL STATUS CHECK (CHECK FOR CHARACTER HIT)


STATUS	PSHA            ;* SAVE A REG. XXXXXXXX
	LDAA ACIA       ;* GET STATUS (l == 2)
	ANDA #$01       ;* CHECK FOR CHARACTER (l == 2)
	PULA		;* RESTORE A REG. (l == 2)
	RTS		;* 


;* TIMER INITIALIZE ROUTINE


TINT	LDX  #TMPIA	;* GET PIA ADDRESS XXXXXXXX
	LDAA #$FF       ;* SET SIDE B AS OUTPUTS (l == 2)
	STAA 0,X        ;* (l == 2)
	LDAA #$3C       ;* CONFIGURE PIA CONTROL (l == 2)
	STAA 1,X	;* (l == 2)
	LDAA #$8F       ;* TURN OFF TIMER (l == 2)
	STAA 0,X        ;* (l == 2)
	LDAA 0,X        ;* CLR ANY PENDING INTRRPTS (l == 2)
	LDAA #$3D       ;* RECONFIGURE PIA (l == 2)
	STAA 1,X        ;* (l == 2)
	RTS		;* 


;* TIMER ON ROUTINE


TON	LDAA #$04	;* TURN ON TIMER (10ms) XXXXXXXX
	BRA  TOFF2	;* 


;* TIMER OFF ROUTINE


TOFF	LDAA #$8F	;* TURN OFF TIMER XXXXXXXX
TOFF2	STAA TMPIA	;*
	RTS		;* 


;* IRQ INTERRUPT HANDLER ROUTINE


IHND	LDAA TMPIA	;* CLR ANY PENDING INTRRPTS XXXXXXXX
	JMP  CHPR	;* SWITCH PROCESSES


;* CHANGE MEMEND UPPER LIMIT


	ORG  $AC2B	;* 
	FDB  $7FFF      ;* LIMIT MEMEND TO 7FFF


;* END STATEMENT HAS FLEX TRANSFER ADDRESS!


	END		;* $AD00 (l == 2)
;*[ Fini ]**********************************************************************
;/* Local Variables: */
;/* mode:asm         */
;/* End:             */
