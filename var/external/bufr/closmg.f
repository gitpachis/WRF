      SUBROUTINE CLOSMG(LUNIN)

C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C
C SUBPROGRAM:    CLOSMG
C   PRGMMR: WOOLLEN          ORG: NP20       DATE: 1994-01-06
C
C ABSTRACT: THIS SUBROUTINE SHOULD ONLY BE CALLED WHEN LOGICAL UNIT
C   ABS(LUNIN) HAS BEEN OPENED FOR OUTPUT OPERATIONS.  IT CLOSES A BUFR
C   MESSAGE PREVIOUSLY OPENED BY EITHER BUFR ARCHIVE LIBRARY
C   SUBROUTINES OPENMG OR OPENMB AND WRITES IT TO THE UNIT ABS(LUNIN).
C   SINCE OPENMG AND OPENMB NORMALLY CALL THIS INTERNALLY, IT IS NOT
C   CALLED TOO OFTEN FROM AN APPLICATION PROGRAM.
C
C PROGRAM HISTORY LOG:
C 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C 1998-07-08  J. WOOLLEN -- REPLACED CALL TO CRAY LIBRARY ROUTINE
C                           "ABORT" WITH CALL TO NEW INTERNAL BUFRLIB
C                           ROUTINE "BORT"
C 1999-11-18  J. WOOLLEN -- THE NUMBER OF BUFR FILES WHICH CAN BE
C                           OPENED AT ONE TIME INCREASED FROM 10 TO 32
C                           (NECESSARY IN ORDER TO PROCESS MULTIPLE
C                           BUFR FILES UNDER THE MPI)
C 2000-09-19  J. WOOLLEN -- MAXIMUM MESSAGE LENGTH INCREASED FROM
C                           10,000 TO 20,000 BYTES
C 2003-05-19  J. WOOLLEN -- CORRECTED A PROBLEM INTRODUCED IN A
C                           PREVIOUS (MAY 2002) IMPLEMENTATION WHICH
C                           PREVENTED THE DUMP CENTER TIME AND
C                           INTITIATION TIME MESSAGES FROM BEING
C                           WRITTEN OUT (THIS AFFECTED APPLICATION
C                           PROGRAM BUFR_DUMPMD, IF IT WERE RECOMPILED,
C                           IN THE DATA DUMPING PROCESS)
C 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C                           INTERDEPENDENCIES
C 2003-11-04  D. KEYSER  -- UNIFIED/PORTABLE FOR WRF; ADDED
C                           DOCUMENTATION (INCLUDING HISTORY); OUTPUTS
C                           MORE COMPLETE DIAGNOSTIC INFO WHEN ROUTINE
C                           TERMINATES ABNORMALLY
C 2004-08-09  J. ATOR    -- MAXIMUM MESSAGE LENGTH INCREASED FROM
C                           20,000 TO 50,000 BYTES
C 2005-05-26  D. KEYSER  -- ALLOWS OVERRIDE OF PREVIOUS LOGIC THAT HAD
C                           ALWAYS WRITTEN OUT MESSAGE NUMBERS 1 AND 2
C                           EVEN WHEN THEY CONTAINED ZERO SUBSETS
C                           (ASSUMED THESE ARE DUMMIES, CONTAINING ONLY
C                           CENTER AND DUMP TIME) (NO OTHER EMPTY
C                           MESSAGES WERE WRITTEN OUT), DONE BY PASSING
C                           IN A NEGATIVE UNIT NUMBER ARGUMENT THE
C                           FIRST TIME THIS ROUTINE IS CALLED BY AN
C                           APPLICATION PROGRAM (ALL EMPTY MESSAGES ARE
C                           SKIPPED) (ASSUMES DUMMY MESSAGES ARE NOT IN
C                           INPUT FILE), NOTE: THIS REMAINS SET FOR THE
C                           PARTICULAR FILE BEING WRITTEN TO EACH TIME
C                           CLOSMG IS CALLED, REGARDLESS OF THE SIGN OF
C                           THE UNIT NUMBER - THIS IS NECESSARY BECAUSE
C                           THIS ROUTINE IS CALLED BY OTHER BUFRLIB
C                           ROUTINES WHICH ALWAYS PASS IN A POSITIVE
C                           UNIT NUMBER (THE APPLICATION PROGRAM SHOULD
C                           ALWAYS CALL CLOSMG WITH A NEGATIVE UNIT
C                           NUMBER IMMEDIATELY AFTER CALLING OPENBF FOR
C                           THIS OUTPUT FILE IF THE INTENTION IS TO
C                           NOT WRITE ANY EMPTY MESSAGES)
C
C USAGE:    CALL CLOSMG (LUNIN)
C   INPUT ARGUMENT LIST:
C     LUNIN    - INTEGER: ABSOLUTE VALUE IS FORTRAN LOGICAL UNIT NUMBER
C                FOR BUFR FILE
C                  - IF LUNIN IS GREATER THAN ZERO, THEN MESSAGE NUMBER
C                    1 OR 2 IS WRITTEN OUT EVEN IF THE NUMBER OF
C                    SUBSETS WRITTEN INTO THE MESSAGE IS ZERO (THIS
C                    ALLOWS "DUMMY" MESSAGES CONTAINING DUMP CENTER AND
C                    INITIATION TIME TO BE COPIED), MESSAGE NUMBERS 3
C                    AND HIGHER ARE NOT WRITTEN OUT IF THEY CONTAIN
C                    ZERO SUBSETS
C                  - IF LUNIN IS LESS THAN ZERO, THEN NO MESSAGES WITH
C                    ZERO SUBSETS WRITTEN INTO THEM ARE WRITTEN OUT
C                    FOR A PARTICULAR FILE BOTH IN THIS CALL AND IN ALL
C                    SUBSEQUENT CALLS TO THIS ROUTINE BY AN APPLICATION
C                    PROGRAM
C
C REMARKS:
C    THIS ROUTINE CALLS:        BORT     MSGWRT   STATUS   WRCMPS
C                               WTSTAT
C    THIS ROUTINE IS CALLED BY: CLOSBF   MAKESTAB OPENMB   OPENMG
C                               WRITSA
C                               Also called by application programs.
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 77
C   MACHINE:  PORTABLE TO ALL PLATFORMS
C
C$$$

      INCLUDE 'bufrlib.prm'

      COMMON /BITBUF/ MAXBYT,IBIT,IBAY(MXMSGLD4),MBYT(NFILES),
     .                MBAY(MXMSGLD4,NFILES)
      COMMON /MSGCWD/ NMSG(NFILES),NSUB(NFILES),MSUB(NFILES),
     .                INODE(NFILES),IDATE(NFILES)

      DIMENSION MSGLIM(NFILES)

      DATA MSGLIM/NFILES*3/

      SAVE MSGLIM

C-----------------------------------------------------------------------
C-----------------------------------------------------------------------

C  CHECK THE FILE STATUS
C  ---------------------

      LUNIT = ABS(LUNIN)
      CALL STATUS(LUNIT,LUN,IL,IM)
      IF(LUNIT.NE.LUNIN) MSGLIM(LUN) = 0
      IF(IL.EQ.0) GOTO 900
      IF(IL.LT.0) GOTO 901
      IF(IM.NE.0) THEN
         IF(NSUB(LUN).GT.0) THEN
            CALL MSGWRT(LUNIT,MBAY(1,LUN),MBYT(LUN))
         ELSE IF(NSUB(LUN).EQ.0.AND.NMSG(LUN).LT.MSGLIM(LUN)) THEN
            CALL MSGWRT(LUNIT,MBAY(1,LUN),MBYT(LUN))
         ELSE IF(NSUB(LUN).LT.0) THEN
            CALL WRCMPS(-LUNIT)
         ENDIF
      ENDIF
      CALL WTSTAT(LUNIT,LUN,IL,0)

C  EXITS
C  -----

      RETURN
900   CALL BORT('BUFRLIB: CLOSMG - OUTPUT BUFR FILE IS CLOSED, IT '//
     . 'MUST BE OPEN FOR OUTPUT')
901   CALL BORT('BUFRLIB: CLOSMG - OUTPUT BUFR FILE IS OPEN FOR '//
     . 'INPUT, IT MUST BE OPEN FOR OUTPUT')
      END
