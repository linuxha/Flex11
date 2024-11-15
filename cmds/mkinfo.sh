#!/bin/bash

CMDNOM=${1}
INFNOM="$(basename ${CMDNOM} .CMD)"
INFNOM="${INFNOM,,}"

TMPLATE="* FILE filename [baseaddr]
* f9dasm -info ${INFNOM}.info |& tee ${INFNOM}.dis
FILE ${CMDNOM} 0100
OPTION 6800
*
INCLUDE flex.info

*
LABEL   0100 START

INCLUDE dpage.info

LABEL   7E JMP

COMMENT 0100 ------------------------------------------------------------------------------
LABEL   0100 START
"

echo "${TMPLATE}" > $INFNOM.info
