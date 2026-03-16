      *>*************************************************************
      *> PROGRAM NAME: gnuCUSTUPD                                  *
      *> DESCRIPTION:  CUSTOMER MASTER FILE UPDATE                 *
      *>               PROCESSES TRANSACTION FILE TO:              *
      *>               - ADD NEW CUSTOMERS                         *
      *>               - UPDATE EXISTING CUSTOMERS                 *
      *>               - DELETE EXISTING CUSTOMERS                 *
      *>               - VALIDATE ALL TRANSACTIONS                 *
      *> INPUTS:       CUSTOMER MASTER FILE (CUSTMIN)              *
      *>               TRANSACTION FILE     (TRANSIN)              *
      *> OUTPUTS:      UPDATED MASTER FILE  (CUSTMOUT)             *
      *>               UPDATE REPORT        (RPTUPDOUT)            *
      *>               ERROR FILE           (ERROROUT)             *
      *>                                                           *
      *> COPYBOOKS:                                                *
      *>   CUSTREC.cpy  - CUSTOMER MASTER RECORD (200 BYTES)       *
      *>   ERRORREC.cpy - ERROR RECORD           (150 BYTES)       *
      *>                                                           *
      *> RECORD NAME CONVENTIONS:                                  *
      *>   CUST-IN-REC  - CUSTOMER MASTER INPUT                    *
      *>   CUST-OUT-REC - CUSTOMER MASTER OUTPUT                   *
      *>   TRANS-REC    - TRANSACTION INPUT                        *
      *>   WS-CUST-REC  - WORKING STORAGE COPY OF MASTER RECORD    *
      *>                                                           *
      *> GNUCOBOL CHANGES FROM z/OS VERSION (CUSTUPD.cbl):         *
      *>   G1 - FREE FORMAT SOURCE - 6 COLUMN LEFT MARGIN APPLIED  *
      *>   G2 - RECORDING MODE IS F REMOVED (NOT SUPPORTED)        *
      *>   G3 - BLOCK CONTAINS 0 RECORDS REMOVED (NOT SUPPORTED)   *
      *>   G4 - ASSIGN TO MAPS TO ENVIRONMENT VARIABLES            *
      *>   G5 - COMMENTS USE *> (FREE FORMAT STANDARD)             *
      *>                                                           *
      *> TO COMPILE:                                               *
      *>   cobc -x -free -I ./copybooks -o gnucustupd              *
      *>        gnuCUSTUPD.cbl                                      *
      *>                                                           *
      *> TO RUN - SET ENVIRONMENT VARIABLES THEN EXECUTE:          *
      *>   export CUSTMIN=custmin.dat                               *
      *>   export CUSTMOUT=custmout.dat                             *
      *>   export TRANSIN=transin.dat                               *
      *>   export RPTUPDOUT=report.txt                              *
      *>   export ERROROUT=errors.dat                               *
      *>   ./gnucustupd                                             *
      *>   echo "Return code: $?"                                   *
      *>                                                           *
      *> INPUT FILE FORMATS:                                        *
      *>   CUSTMIN  - FIXED 200-BYTE RECORDS (CUSTREC FORMAT)      *
      *>   TRANSIN  - FIXED 201-BYTE RECORDS                        *
      *>              BYTE 1      = TRANSACTION TYPE (A/U/D)        *
      *>              BYTES 2-201 = CUSTOMER DATA (CUSTREC FORMAT)  *
      *>*************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. gnuCUSTUPD.
       AUTHOR. PORTFOLIO DEMO.

      *>*************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

      *>   G4: ASSIGN TO USES ENVIRONMENT VARIABLE NAMES.
      *>       SET EACH VARIABLE TO THE REQUIRED FILENAME
      *>       BEFORE RUNNING THE PROGRAM.

           SELECT CUST-MASTER-IN  ASSIGN TO CUSTMIN
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE  IS SEQUENTIAL
                  FILE STATUS  IS WS-CUST-IN-STATUS.

           SELECT CUST-MASTER-OUT ASSIGN TO CUSTMOUT
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE  IS SEQUENTIAL
                  FILE STATUS  IS WS-CUST-OUT-STATUS.

           SELECT TRANS-FILE      ASSIGN TO TRANSIN
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE  IS SEQUENTIAL
                  FILE STATUS  IS WS-TRANS-STATUS.

           SELECT REPORT-FILE     ASSIGN TO RPTUPDOUT
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE  IS SEQUENTIAL
                  FILE STATUS  IS WS-REPORT-STATUS.

           SELECT ERROR-FILE      ASSIGN TO ERROROUT
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE  IS SEQUENTIAL
                  FILE STATUS  IS WS-ERROR-STATUS.

      *>*************************************************************
       DATA DIVISION.
       FILE SECTION.

      *>-----------------------------------------------------------*
      *> CUSTOMER MASTER INPUT FILE                                *
      *> G2/G3: RECORDING MODE AND BLOCK CONTAINS REMOVED         *
      *> CUSTREC REPLACING GIVES THIS COPY UNIQUE 01-LEVEL NAME   *
      *>-----------------------------------------------------------*
       FD  CUST-MASTER-IN.
           COPY CUSTREC REPLACING CUSTOMER-RECORD BY CUST-IN-REC.

      *>-----------------------------------------------------------*
      *> CUSTOMER MASTER OUTPUT FILE                               *
      *> G2/G3: RECORDING MODE AND BLOCK CONTAINS REMOVED         *
      *> CUSTREC REPLACING GIVES THIS COPY UNIQUE 01-LEVEL NAME   *
      *>-----------------------------------------------------------*
       FD  CUST-MASTER-OUT.
           COPY CUSTREC REPLACING CUSTOMER-RECORD BY CUST-OUT-REC.

      *>-----------------------------------------------------------*
      *> TRANSACTION INPUT FILE                                    *
      *> G2/G3: RECORDING MODE AND BLOCK CONTAINS REMOVED         *
      *> TRANS-TYPE BYTE PRECEDES THE CUSTOMER DATA PORTION        *
      *> CUSTREC REPLACING GIVES CUSTOMER PORTION UNIQUE NAME      *
      *>-----------------------------------------------------------*
       FD  TRANS-FILE.
       01  TRANS-INPUT-REC.
           05  TRANS-TYPE               PIC X(1).
               88  TRANS-ADD                    VALUE 'A'.
               88  TRANS-UPDATE                 VALUE 'U'.
               88  TRANS-DELETE                 VALUE 'D'.
           05  TRANS-CUST-DATA.
               COPY CUSTREC REPLACING CUSTOMER-RECORD
                                    BY TRANS-REC.

      *>-----------------------------------------------------------*
      *> REPORT OUTPUT FILE                                        *
      *> G2/G3: RECORDING MODE AND BLOCK CONTAINS REMOVED         *
      *>-----------------------------------------------------------*
       FD  REPORT-FILE.
       01  REPORT-LINE                  PIC X(132).

      *>-----------------------------------------------------------*
      *> ERROR OUTPUT FILE                                         *
      *> G2/G3: RECORDING MODE AND BLOCK CONTAINS REMOVED         *
      *> ERRORREC DEFINES ITS OWN 01-LEVEL (ERROR-RECORD)         *
      *> COPIED DIRECTLY UNDER FD - NO WRAPPER 01 REQUIRED        *
      *>-----------------------------------------------------------*
       FD  ERROR-FILE.
           COPY ERRORREC.

      *>*************************************************************
       WORKING-STORAGE SECTION.

      *>-----------------------------------------------------------*
      *> FILE STATUS FIELDS - ONE PER SELECT STATEMENT             *
      *>-----------------------------------------------------------*
       01  WS-FILE-STATUS.
           05  WS-CUST-IN-STATUS        PIC XX VALUE SPACES.
           05  WS-CUST-OUT-STATUS       PIC XX VALUE SPACES.
           05  WS-TRANS-STATUS          PIC XX VALUE SPACES.
           05  WS-REPORT-STATUS         PIC XX VALUE SPACES.
           05  WS-ERROR-STATUS          PIC XX VALUE SPACES.

      *>-----------------------------------------------------------*
      *> END-OF-FILE FLAGS                                         *
      *>-----------------------------------------------------------*
       01  WS-FLAGS.
           05  WS-MASTER-EOF-SW         PIC X VALUE 'N'.
               88  MASTER-EOF                   VALUE 'Y'.
           05  WS-TRANS-EOF-SW          PIC X VALUE 'N'.
               88  TRANS-EOF                    VALUE 'Y'.

      *>-----------------------------------------------------------*
      *> PER-TRANSACTION VALIDATION ERROR FLAG                     *
      *> RESET TO 'N' AT START OF EACH CALL TO 2700-VALIDATE       *
      *> SET TO 'Y' FOR EACH VALIDATION FAILURE FOUND              *
      *> TESTED IN 2400-ADD-CUSTOMER AND 2500-UPDATE-CUSTOMER       *
      *>-----------------------------------------------------------*
       01  WS-TRANS-ERROR-SW            PIC X VALUE 'N'.
           88  TRANS-HAS-ERROR                  VALUE 'Y'.
           88  TRANS-IS-VALID                   VALUE 'N'.

      *>-----------------------------------------------------------*
      *> PROGRAM COUNTERS                                          *
      *> WS-TRANS-READ-COUNT IS PIC 9(8) TO MATCH ERR-RECORD-NUM  *
      *>-----------------------------------------------------------*
       01  WS-COUNTERS.
           05  WS-MASTER-READ-COUNT     PIC 9(7) VALUE ZERO.
           05  WS-MASTER-WRITE-COUNT    PIC 9(7) VALUE ZERO.
           05  WS-TRANS-READ-COUNT      PIC 9(8) VALUE ZERO.
           05  WS-ADD-COUNT             PIC 9(7) VALUE ZERO.
           05  WS-UPDATE-COUNT          PIC 9(7) VALUE ZERO.
           05  WS-DELETE-COUNT          PIC 9(7) VALUE ZERO.
           05  WS-ERROR-COUNT           PIC 9(7) VALUE ZERO.

      *>-----------------------------------------------------------*
      *> ERROR STAGING FIELDS FOR 8000-LOG-ERROR                   *
      *> CALLERS MOVE VALUES HERE BEFORE PERFORMING 8000            *
      *> SIZES MATCH ACTUAL ERRORREC FIELD DEFINITIONS              *
      *>-----------------------------------------------------------*
       01  WS-ERROR-FIELDS.
           05  WS-ERROR-CODE            PIC X(10) VALUE SPACES.
           05  WS-ERROR-MESSAGE         PIC X(60) VALUE SPACES.

      *>-----------------------------------------------------------*
      *> WORKING STORAGE COPY OF CURRENT MASTER RECORD             *
      *> MASTER FILE IS READ INTO HERE VIA READ...INTO             *
      *> PREVENTS INPUT BUFFER BEING OVERWRITTEN BY OUTPUT WRITES  *
      *> CUSTREC REPLACING GIVES THIS COPY UNIQUE 01-LEVEL NAME   *
      *>-----------------------------------------------------------*
       01  WS-MASTER-AREA.
           COPY CUSTREC REPLACING CUSTOMER-RECORD BY WS-CUST-REC.

      *>-----------------------------------------------------------*
      *> WORKING STORAGE REPORT LINE BUFFER                        *
      *>-----------------------------------------------------------*
       01  WS-REPORT-LINE               PIC X(132) VALUE SPACES.

      *>-----------------------------------------------------------*
      *> FATAL ERROR MESSAGE STAGING AREA                          *
      *>-----------------------------------------------------------*
       01  WS-ABEND-MSG                 PIC X(80)  VALUE SPACES.

      *>*************************************************************
       PROCEDURE DIVISION.

      *>-----------------------------------------------------------*
      *> MAIN PROCESSING LOGIC                                     *
      *>-----------------------------------------------------------*
       0000-MAIN-PROCESS.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-PROCESS-UPDATES
               UNTIL MASTER-EOF AND TRANS-EOF
           PERFORM 3000-FINALIZE
           STOP RUN.

      *>-----------------------------------------------------------*
      *> INITIALIZATION                                            *
      *> OPEN ALL FILES THEN PRIME BOTH INPUT READS                *
      *> ANY FILE OPEN FAILURE IS IMMEDIATELY FATAL                *
      *>-----------------------------------------------------------*
       1000-INITIALIZE.
           OPEN INPUT CUST-MASTER-IN
           IF WS-CUST-IN-STATUS NOT = '00'
               MOVE 'OPEN FAILED: CUST-MASTER-IN  FS='
                                            TO WS-ABEND-MSG(1:36)
               MOVE WS-CUST-IN-STATUS       TO WS-ABEND-MSG(37:2)
               PERFORM 9900-FATAL-ERROR
           END-IF

           OPEN INPUT TRANS-FILE
           IF WS-TRANS-STATUS NOT = '00'
               MOVE 'OPEN FAILED: TRANS-FILE      FS='
                                            TO WS-ABEND-MSG(1:36)
               MOVE WS-TRANS-STATUS         TO WS-ABEND-MSG(37:2)
               PERFORM 9900-FATAL-ERROR
           END-IF

           OPEN OUTPUT CUST-MASTER-OUT
           IF WS-CUST-OUT-STATUS NOT = '00'
               MOVE 'OPEN FAILED: CUST-MASTER-OUT FS='
                                            TO WS-ABEND-MSG(1:36)
               MOVE WS-CUST-OUT-STATUS      TO WS-ABEND-MSG(37:2)
               PERFORM 9900-FATAL-ERROR
           END-IF

           OPEN OUTPUT REPORT-FILE
           IF WS-REPORT-STATUS NOT = '00'
               MOVE 'OPEN FAILED: REPORT-FILE     FS='
                                            TO WS-ABEND-MSG(1:36)
               MOVE WS-REPORT-STATUS        TO WS-ABEND-MSG(37:2)
               PERFORM 9900-FATAL-ERROR
           END-IF

           OPEN OUTPUT ERROR-FILE
           IF WS-ERROR-STATUS NOT = '00'
               MOVE 'OPEN FAILED: ERROR-FILE      FS='
                                            TO WS-ABEND-MSG(1:36)
               MOVE WS-ERROR-STATUS         TO WS-ABEND-MSG(37:2)
               PERFORM 9900-FATAL-ERROR
           END-IF

           PERFORM 1100-READ-MASTER
           PERFORM 1200-READ-TRANSACTION.

      *>-----------------------------------------------------------*
      *> READ NEXT MASTER RECORD INTO WS-CUST-REC                 *
      *> STATUS 00 = SUCCESSFUL READ                               *
      *> STATUS 10 = END OF FILE (NORMAL)                          *
      *> ANY OTHER STATUS = FATAL I/O ERROR                        *
      *>-----------------------------------------------------------*
       1100-READ-MASTER.
           READ CUST-MASTER-IN INTO WS-CUST-REC
               AT END
                   MOVE 'Y'               TO WS-MASTER-EOF-SW
               NOT AT END
                   ADD 1                  TO WS-MASTER-READ-COUNT
           END-READ
           IF WS-CUST-IN-STATUS NOT = '00'
          AND WS-CUST-IN-STATUS NOT = '10'
               MOVE 'READ ERROR: CUST-MASTER-IN   FS='
                                            TO WS-ABEND-MSG(1:36)
               MOVE WS-CUST-IN-STATUS       TO WS-ABEND-MSG(37:2)
               PERFORM 9900-FATAL-ERROR
           END-IF.

      *>-----------------------------------------------------------*
      *> READ NEXT TRANSACTION RECORD                              *
      *> STATUS 00 = SUCCESSFUL READ                               *
      *> STATUS 10 = END OF FILE (NORMAL)                          *
      *> ANY OTHER STATUS = FATAL I/O ERROR                        *
      *>-----------------------------------------------------------*
       1200-READ-TRANSACTION.
           READ TRANS-FILE
               AT END
                   MOVE 'Y'               TO WS-TRANS-EOF-SW
               NOT AT END
                   ADD 1                  TO WS-TRANS-READ-COUNT
           END-READ
           IF WS-TRANS-STATUS NOT = '00'
          AND WS-TRANS-STATUS NOT = '10'
               MOVE 'READ ERROR: TRANS-FILE       FS='
                                            TO WS-ABEND-MSG(1:36)
               MOVE WS-TRANS-STATUS         TO WS-ABEND-MSG(37:2)
               PERFORM 9900-FATAL-ERROR
           END-IF.

      *>-----------------------------------------------------------*
      *> SEQUENTIAL FILE MERGE LOGIC                               *
      *> BOTH FILES SORTED ASCENDING BY CUSTOMER ID                *
      *>                                                           *
      *> CASE 1: MASTER EOF, TRANS ACTIVE - PROCESS TRANS ONLY    *
      *> CASE 2: TRANS EOF, MASTER ACTIVE - COPY MASTER TO OUTPUT *
      *> CASE 3: MASTER KEY < TRANS KEY   - COPY MASTER TO OUTPUT *
      *> CASE 4: MASTER KEY > TRANS KEY   - PROCESS TRANS ONLY    *
      *> CASE 5: MASTER KEY = TRANS KEY   - PROCESS MATCHING       *
      *>-----------------------------------------------------------*
       2000-PROCESS-UPDATES.
           IF MASTER-EOF AND NOT TRANS-EOF
               PERFORM 2100-PROCESS-TRANS-ONLY
           ELSE IF TRANS-EOF AND NOT MASTER-EOF
               PERFORM 2200-COPY-MASTER-ONLY
           ELSE IF CUST-ID OF WS-CUST-REC
                  < CUST-ID OF TRANS-REC
               PERFORM 2200-COPY-MASTER-ONLY
           ELSE IF CUST-ID OF WS-CUST-REC
                  > CUST-ID OF TRANS-REC
               PERFORM 2100-PROCESS-TRANS-ONLY
           ELSE
               PERFORM 2300-PROCESS-MATCHING
           END-IF.

      *>-----------------------------------------------------------*
      *> NO MATCHING MASTER EXISTS FOR THIS TRANSACTION            *
      *> VALID ONLY FOR TRANS-ADD - ALL OTHER TYPES ARE ERRORS     *
      *> READS NEXT TRANSACTION BEFORE RETURNING                   *
      *>-----------------------------------------------------------*
       2100-PROCESS-TRANS-ONLY.
           EVALUATE TRUE
               WHEN TRANS-ADD
                   PERFORM 2400-ADD-CUSTOMER
               WHEN TRANS-UPDATE
                   MOVE 'E-UPDATE'         TO WS-ERROR-CODE
                   MOVE 'UPDATE TRANS FOR NON-EXISTENT CUSTOMER'
                                           TO WS-ERROR-MESSAGE
                   PERFORM 8000-LOG-ERROR
               WHEN TRANS-DELETE
                   MOVE 'E-DELETE'         TO WS-ERROR-CODE
                   MOVE 'DELETE TRANS FOR NON-EXISTENT CUSTOMER'
                                           TO WS-ERROR-MESSAGE
                   PERFORM 8000-LOG-ERROR
           END-EVALUATE

           PERFORM 1200-READ-TRANSACTION.

      *>-----------------------------------------------------------*
      *> NO TRANSACTION EXISTS FOR THIS MASTER RECORD              *
      *> COPY MASTER RECORD UNCHANGED TO OUTPUT                    *
      *> READS NEXT MASTER BEFORE RETURNING                        *
      *>-----------------------------------------------------------*
       2200-COPY-MASTER-ONLY.
           MOVE WS-CUST-REC               TO CUST-OUT-REC
           WRITE CUST-OUT-REC
           IF WS-CUST-OUT-STATUS NOT = '00'
               MOVE 'WRITE ERROR: CUST-MASTER-OUT FS='
                                            TO WS-ABEND-MSG(1:36)
               MOVE WS-CUST-OUT-STATUS      TO WS-ABEND-MSG(37:2)
               PERFORM 9900-FATAL-ERROR
           END-IF
           ADD 1                            TO WS-MASTER-WRITE-COUNT
           PERFORM 1100-READ-MASTER.

      *>-----------------------------------------------------------*
      *> TRANSACTION KEY MATCHES MASTER KEY                        *
      *> EVALUATE TRANSACTION TYPE AND PROCESS ACCORDINGLY         *
      *> READS BOTH MASTER AND TRANSACTION FORWARD BEFORE RETURN   *
      *>-----------------------------------------------------------*
       2300-PROCESS-MATCHING.
           EVALUATE TRUE
               WHEN TRANS-ADD
      *>           ADD FOR EXISTING CUSTOMER IS AN ERROR
      *>           LOG THE ERROR BUT PRESERVE EXISTING MASTER
                   MOVE 'E-ADD'            TO WS-ERROR-CODE
                   MOVE 'ADD TRANS FOR EXISTING CUSTOMER'
                                           TO WS-ERROR-MESSAGE
                   PERFORM 8000-LOG-ERROR
                   MOVE WS-CUST-REC        TO CUST-OUT-REC
                   WRITE CUST-OUT-REC
                   IF WS-CUST-OUT-STATUS NOT = '00'
                       MOVE 'WRITE ERROR: CUST-MASTER-OUT FS='
                                           TO WS-ABEND-MSG(1:36)
                       MOVE WS-CUST-OUT-STATUS
                                           TO WS-ABEND-MSG(37:2)
                       PERFORM 9900-FATAL-ERROR
                   END-IF
                   ADD 1                   TO WS-MASTER-WRITE-COUNT
               WHEN TRANS-UPDATE
                   PERFORM 2500-UPDATE-CUSTOMER
               WHEN TRANS-DELETE
                   PERFORM 2600-DELETE-CUSTOMER
           END-EVALUATE

           PERFORM 1100-READ-MASTER
           PERFORM 1200-READ-TRANSACTION.

      *>-----------------------------------------------------------*
      *> ADD NEW CUSTOMER TO OUTPUT FILE                           *
      *> VALIDATE FIRST - ONLY WRITE IF ALL VALIDATIONS PASS       *
      *> IF INVALID - RECORD DISCARDED AND ERRORS LOGGED           *
      *>-----------------------------------------------------------*
       2400-ADD-CUSTOMER.
           PERFORM 2700-VALIDATE-CUSTOMER

           IF TRANS-IS-VALID
               MOVE TRANS-REC             TO CUST-OUT-REC
               MOVE 'A'                   TO CUST-STATUS OF CUST-OUT-REC
               WRITE CUST-OUT-REC
               IF WS-CUST-OUT-STATUS NOT = '00'
                   MOVE 'WRITE ERROR: CUST-MASTER-OUT FS='
                                            TO WS-ABEND-MSG(1:36)
                   MOVE WS-CUST-OUT-STATUS  TO WS-ABEND-MSG(37:2)
                   PERFORM 9900-FATAL-ERROR
               END-IF
               ADD 1                        TO WS-MASTER-WRITE-COUNT
               ADD 1                        TO WS-ADD-COUNT
           END-IF.

      *>-----------------------------------------------------------*
      *> UPDATE EXISTING CUSTOMER IN OUTPUT FILE                   *
      *> VALIDATE FIRST                                            *
      *> IF VALID:   COPY MASTER TO OUTPUT THEN OVERLAY CHANGES    *
      *> IF INVALID: WRITE EXISTING MASTER UNCHANGED               *
      *>-----------------------------------------------------------*
       2500-UPDATE-CUSTOMER.
           PERFORM 2700-VALIDATE-CUSTOMER

           IF TRANS-IS-VALID
               MOVE WS-CUST-REC             TO CUST-OUT-REC
               MOVE CUST-NAME         OF TRANS-REC
                                      TO CUST-NAME       OF CUST-OUT-REC
               MOVE CUST-ADDRESS      OF TRANS-REC
                                      TO CUST-ADDRESS    OF CUST-OUT-REC
               MOVE CUST-CITY         OF TRANS-REC
                                      TO CUST-CITY       OF CUST-OUT-REC
               MOVE CUST-STATE        OF TRANS-REC
                                      TO CUST-STATE      OF CUST-OUT-REC
               MOVE CUST-ZIP          OF TRANS-REC
                                      TO CUST-ZIP        OF CUST-OUT-REC
               MOVE CUST-EMAIL        OF TRANS-REC
                                      TO CUST-EMAIL      OF CUST-OUT-REC
               MOVE CUST-PHONE        OF TRANS-REC
                                      TO CUST-PHONE      OF CUST-OUT-REC
               MOVE CUST-CREDIT-LIMIT OF TRANS-REC
                                      TO CUST-CREDIT-LIMIT 
                                                         OF CUST-OUT-REC
               WRITE CUST-OUT-REC
               IF WS-CUST-OUT-STATUS NOT = '00'
                   MOVE 'WRITE ERROR: CUST-MASTER-OUT FS='
                                            TO WS-ABEND-MSG(1:36)
                   MOVE WS-CUST-OUT-STATUS  TO WS-ABEND-MSG(37:2)
                   PERFORM 9900-FATAL-ERROR
               END-IF
               ADD 1                        TO WS-MASTER-WRITE-COUNT
               ADD 1                        TO WS-UPDATE-COUNT
           ELSE
      *>       VALIDATION FAILED - PRESERVE EXISTING MASTER
               MOVE WS-CUST-REC             TO CUST-OUT-REC
               WRITE CUST-OUT-REC
               IF WS-CUST-OUT-STATUS NOT = '00'
                   MOVE 'WRITE ERROR: CUST-MASTER-OUT FS='
                                            TO WS-ABEND-MSG(1:36)
                   MOVE WS-CUST-OUT-STATUS  TO WS-ABEND-MSG(37:2)
                   PERFORM 9900-FATAL-ERROR
               END-IF
               ADD 1                        TO WS-MASTER-WRITE-COUNT
           END-IF.

      *>-----------------------------------------------------------*
      *> DELETE EXISTING CUSTOMER FROM OUTPUT FILE                 *
      *> DELETION ACHIEVED BY NOT WRITING RECORD TO OUTPUT         *
      *> CUSTOMERS WITH NON-ZERO BALANCE CANNOT BE DELETED         *
      *> IF BALANCE > ZERO: LOG ERROR AND PRESERVE MASTER RECORD   *
      *>-----------------------------------------------------------*
       2600-DELETE-CUSTOMER.
           IF CUST-BALANCE OF WS-CUST-REC > ZERO
               MOVE 'E-BALANCE'            TO WS-ERROR-CODE
               MOVE 'CANNOT DELETE CUSTOMER WITH OUTSTANDING BALANCE'
                                           TO WS-ERROR-MESSAGE
               PERFORM 8000-LOG-ERROR
               MOVE WS-CUST-REC            TO CUST-OUT-REC
               WRITE CUST-OUT-REC
               IF WS-CUST-OUT-STATUS NOT = '00'
                   MOVE 'WRITE ERROR: CUST-MASTER-OUT FS='
                                            TO WS-ABEND-MSG(1:36)
                   MOVE WS-CUST-OUT-STATUS  TO WS-ABEND-MSG(37:2)
                   PERFORM 9900-FATAL-ERROR
               END-IF
               ADD 1                        TO WS-MASTER-WRITE-COUNT
           ELSE
               ADD 1                        TO WS-DELETE-COUNT
      *>       RECORD NOT WRITTEN TO OUTPUT - THIS IS THE DELETION
           END-IF.

      *>-----------------------------------------------------------*
      *> VALIDATE TRANSACTION DATA PRIOR TO ADD OR UPDATE          *
      *> WS-TRANS-ERROR-SW RESET TO 'N' ON ENTRY EVERY CALL        *
      *> SET TO 'Y' FOR EACH INDIVIDUAL VALIDATION FAILURE          *
      *> CALLERS TEST TRANS-IS-VALID OR TRANS-HAS-ERROR ON RETURN   *
      *>                                                            *
      *> NOTE ON CREDIT LIMIT CHECK:                               *
      *>   CUST-CREDIT-LIMIT IN CUSTREC IS PIC 9(8)V99 (UNSIGNED). *
      *>   THE < ZERO TEST CAN NEVER FIRE FOR AN UNSIGNED FIELD.    *
      *>   TO ACTIVATE, CUSTREC MUST DEFINE THE FIELD AS            *
      *>   PIC S9(8)V99 COMP-3. RETAINED FOR FUTURE USE.           *
      *>-----------------------------------------------------------*
       2700-VALIDATE-CUSTOMER.
           MOVE 'N'                        TO WS-TRANS-ERROR-SW

      *>   CHECK 1: CUSTOMER NAME MUST NOT BE SPACES
           IF CUST-NAME OF TRANS-REC = SPACES
               MOVE 'E-NAME'               TO WS-ERROR-CODE
               MOVE 'CUSTOMER NAME IS REQUIRED'
                                           TO WS-ERROR-MESSAGE
               PERFORM 8000-LOG-ERROR
               MOVE 'Y'                    TO WS-TRANS-ERROR-SW
           END-IF

      *>   CHECK 2: STATE CODE MUST BE ALPHABETIC
           IF CUST-STATE OF TRANS-REC NOT ALPHABETIC
               MOVE 'E-STATE'              TO WS-ERROR-CODE
               MOVE 'INVALID STATE CODE - MUST BE ALPHABETIC'
                                           TO WS-ERROR-MESSAGE
               PERFORM 8000-LOG-ERROR
               MOVE 'Y'                    TO WS-TRANS-ERROR-SW
           END-IF

      *>   CHECK 3: CREDIT LIMIT MUST NOT BE NEGATIVE (SEE NOTE)
           IF CUST-CREDIT-LIMIT OF TRANS-REC < ZERO
               MOVE 'E-CREDIT'             TO WS-ERROR-CODE
               MOVE 'CREDIT LIMIT CANNOT BE NEGATIVE'
                                           TO WS-ERROR-MESSAGE
               PERFORM 8000-LOG-ERROR
               MOVE 'Y'                    TO WS-TRANS-ERROR-SW
           END-IF.

      *>-----------------------------------------------------------*
      *> FINALIZATION                                              *
      *> PRINT SUMMARY REPORT BEFORE CLOSING ALL FILES             *
      *>-----------------------------------------------------------*
       3000-FINALIZE.
           PERFORM 9000-PRINT-SUMMARY

           CLOSE CUST-MASTER-IN
           CLOSE CUST-MASTER-OUT
           CLOSE TRANS-FILE
           CLOSE REPORT-FILE
           CLOSE ERROR-FILE.

      *>-----------------------------------------------------------*
      *> LOG ONE ERROR RECORD TO THE ERROR FILE                    *
      *> CALLER MUST SET WS-ERROR-CODE AND WS-ERROR-MESSAGE        *
      *> BEFORE PERFORMING THIS PARAGRAPH                          *
      *> CUST-ID OF TRANS-REC WRITTEN TO ERR-INPUT-DATA            *
      *> WS-ERROR-CODE AND WS-ERROR-MESSAGE CLEARED AFTER WRITE    *
      *>                                                           *
      *> NOTE: FUNCTION CURRENT-DATE RETURNS 21 CHARACTERS.        *
      *>       ERR-TIMESTAMP IS PIC X(26) - TRAILING 5 BYTES       *
      *>       WILL BE SPACE-FILLED. THIS IS ACCEPTABLE.           *
      *>-----------------------------------------------------------*
       8000-LOG-ERROR.
           MOVE FUNCTION CURRENT-DATE      TO ERR-TIMESTAMP
           MOVE WS-TRANS-READ-COUNT        TO ERR-RECORD-NUMBER
           MOVE WS-ERROR-CODE              TO ERR-ERROR-CODE
           MOVE WS-ERROR-MESSAGE           TO ERR-ERROR-MESSAGE
           MOVE CUST-ID OF TRANS-REC       TO ERR-INPUT-DATA

           WRITE ERROR-RECORD
           IF WS-ERROR-STATUS NOT = '00'
               MOVE 'WRITE ERROR: ERROR-FILE      FS='
                                            TO WS-ABEND-MSG(1:36)
               MOVE WS-ERROR-STATUS         TO WS-ABEND-MSG(37:2)
               PERFORM 9900-FATAL-ERROR
           END-IF

           ADD 1                            TO WS-ERROR-COUNT

           MOVE SPACES                      TO WS-ERROR-CODE
           MOVE SPACES                      TO WS-ERROR-MESSAGE.

      *>-----------------------------------------------------------*
      *> PRINT RUN SUMMARY TO REPORT-FILE AND ECHO TO CONSOLE     *
      *>-----------------------------------------------------------*
       9000-PRINT-SUMMARY.
           MOVE '============================================='
                                            TO WS-REPORT-LINE
           PERFORM 9100-WRITE-REPORT-LINE

           MOVE 'CUSTOMER MASTER FILE UPDATE - RUN SUMMARY'
                                            TO WS-REPORT-LINE
           PERFORM 9100-WRITE-REPORT-LINE

           MOVE '============================================='
                                            TO WS-REPORT-LINE
           PERFORM 9100-WRITE-REPORT-LINE

           MOVE SPACES                      TO WS-REPORT-LINE
           STRING 'MASTER RECORDS READ:    '
                  WS-MASTER-READ-COUNT
                  DELIMITED SIZE            INTO WS-REPORT-LINE
           PERFORM 9100-WRITE-REPORT-LINE

           MOVE SPACES                      TO WS-REPORT-LINE
           STRING 'MASTER RECORDS WRITTEN: '
                  WS-MASTER-WRITE-COUNT
                  DELIMITED SIZE            INTO WS-REPORT-LINE
           PERFORM 9100-WRITE-REPORT-LINE

           MOVE SPACES                      TO WS-REPORT-LINE
           STRING 'TRANSACTIONS READ:      '
                  WS-TRANS-READ-COUNT
                  DELIMITED SIZE            INTO WS-REPORT-LINE
           PERFORM 9100-WRITE-REPORT-LINE

           MOVE SPACES                      TO WS-REPORT-LINE
           STRING '  ADDS:                 '
                  WS-ADD-COUNT
                  DELIMITED SIZE            INTO WS-REPORT-LINE
           PERFORM 9100-WRITE-REPORT-LINE

           MOVE SPACES                      TO WS-REPORT-LINE
           STRING '  UPDATES:              '
                  WS-UPDATE-COUNT
                  DELIMITED SIZE            INTO WS-REPORT-LINE
           PERFORM 9100-WRITE-REPORT-LINE

           MOVE SPACES                      TO WS-REPORT-LINE
           STRING '  DELETES:              '
                  WS-DELETE-COUNT
                  DELIMITED SIZE            INTO WS-REPORT-LINE
           PERFORM 9100-WRITE-REPORT-LINE

           MOVE SPACES                      TO WS-REPORT-LINE
           STRING 'ERRORS DETECTED:        '
                  WS-ERROR-COUNT
                  DELIMITED SIZE            INTO WS-REPORT-LINE
           PERFORM 9100-WRITE-REPORT-LINE

           MOVE '============================================='
                                            TO WS-REPORT-LINE
           PERFORM 9100-WRITE-REPORT-LINE

      *>   ECHO SUMMARY TO CONSOLE FOR IMMEDIATE VISIBILITY
           DISPLAY '============================================='
           DISPLAY 'CUSTOMER MASTER FILE UPDATE - RUN SUMMARY'
           DISPLAY '============================================='
           DISPLAY 'MASTER RECORDS READ:    ' WS-MASTER-READ-COUNT
           DISPLAY 'MASTER RECORDS WRITTEN: ' WS-MASTER-WRITE-COUNT
           DISPLAY 'TRANSACTIONS READ:      ' WS-TRANS-READ-COUNT
           DISPLAY '  ADDS:                 ' WS-ADD-COUNT
           DISPLAY '  UPDATES:              ' WS-UPDATE-COUNT
           DISPLAY '  DELETES:              ' WS-DELETE-COUNT
           DISPLAY 'ERRORS DETECTED:        ' WS-ERROR-COUNT
           DISPLAY '============================================='.

      *>-----------------------------------------------------------*
      *> WRITE ONE LINE TO THE REPORT FILE                         *
      *> MOVES WS-REPORT-LINE TO REPORT-LINE THEN WRITES           *
      *> CLEARS WS-REPORT-LINE AFTER SUCCESSFUL WRITE              *
      *>-----------------------------------------------------------*
       9100-WRITE-REPORT-LINE.
           MOVE WS-REPORT-LINE             TO REPORT-LINE
           WRITE REPORT-LINE
           IF WS-REPORT-STATUS NOT = '00'
               MOVE 'WRITE ERROR: REPORT-FILE     FS='
                                            TO WS-ABEND-MSG(1:36)
               MOVE WS-REPORT-STATUS        TO WS-ABEND-MSG(37:2)
               PERFORM 9900-FATAL-ERROR
           END-IF
           MOVE SPACES                      TO WS-REPORT-LINE.
      *>-----------------------------------------------------------*
      *> FATAL ERROR HANDLER                                       *
      *> DISPLAY DIAGNOSTIC MESSAGE TO CONSOLE                    *
      *> SET RETURN CODE 16 TO SIGNAL FAILURE TO CALLING PROCESS   *
      *> TERMINATE THE PROGRAM                                     *
      *>-----------------------------------------------------------*
       9900-FATAL-ERROR.
           DISPLAY '*** gnuCUSTUPD FATAL ERROR: ' WS-ABEND-MSG
           MOVE 16                          TO RETURN-CODE
           STOP RUN.
