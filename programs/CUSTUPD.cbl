      *****************************************************************
      * PROGRAM NAME: CUSTUPD                                         *
      * DESCRIPTION:  CUSTOMER MASTER FILE UPDATE                     *
      *               PROCESSES TRANSACTION FILE TO:                  *
      *               - ADD NEW CUSTOMERS                             *
      *               - UPDATE EXISTING CUSTOMERS                     *
      *               - DELETE EXISTING CUSTOMERS                     *
      *               - VALIDATE ALL TRANSACTIONS                     *
      * INPUTS:       CUSTOMER MASTER FILE (CUSTMIN)                  *
      *               TRANSACTION FILE     (TRANSIN)                  *
      * OUTPUTS:      UPDATED MASTER FILE  (CUSTMOUT)                 *
      *               UPDATE REPORT        (RPTUPDOUT)                *
      *               ERROR FILE           (ERROROUT)                 *
      *                                                                *
      * COPYBOOKS:                                                     *
      *   CUSTREC  - CUSTOMER MASTER RECORD (200 BYTES)               *
      *              01 CUSTOMER-RECORD                                *
      *                 05 CUST-ID              PIC 9(6)              *
      *                 05 CUST-NAME            PIC X(30)             *
      *                 05 CUST-ADDRESS         PIC X(30)             *
      *                 05 CUST-CITY            PIC X(20)             *
      *                 05 CUST-STATE           PIC X(2)              *
      *                 05 CUST-ZIP             PIC X(10)             *
      *                 05 CUST-EMAIL           PIC X(50)             *
      *                 05 CUST-PHONE           PIC X(15)             *
      *                 05 CUST-CREDIT-LIMIT    PIC 9(8)V99           *
      *                 05 CUST-BALANCE         PIC 9(8)V99           *
      *                 05 CUST-LAST-ORDER-DATE PIC X(10)             *
      *                 05 CUST-STATUS          PIC X(1)              *
      *                 05 FILLER               PIC X(6)              *
      *   ERRORREC - ERROR RECORD (150 BYTES)                         *
      *              01 ERROR-RECORD                                   *
      *                 05 ERR-TIMESTAMP        PIC X(26)             *
      *                 05 ERR-RECORD-NUMBER    PIC 9(8)              *
      *                 05 ERR-ERROR-CODE       PIC X(10)             *
      *                 05 ERR-ERROR-MESSAGE    PIC X(60)             *
      *                 05 ERR-INPUT-DATA       PIC X(40)             *
      *                 05 FILLER               PIC X(6)              *
      *                                                                *
      * RECORD NAME CONVENTIONS USED IN THIS PROGRAM:                 *
      *   CUST-IN-REC  - CUSTOMER MASTER INPUT  (CUST-MASTER-IN FD)  *
      *   CUST-OUT-REC - CUSTOMER MASTER OUTPUT (CUST-MASTER-OUT FD) *
      *   TRANS-REC    - TRANSACTION INPUT      (TRANS-FILE FD)       *
      *   WS-CUST-REC  - WORKING STORAGE COPY OF MASTER RECORD        *
      *                                                                *
      * ALL CUSTREC FIELDS ARE REFERENCED AS:                         *
      *   CUST-xxxx OF CUST-IN-REC   (MASTER INPUT FIELDS)           *
      *   CUST-xxxx OF CUST-OUT-REC  (MASTER OUTPUT FIELDS)          *
      *   CUST-xxxx OF TRANS-REC     (TRANSACTION FIELDS)             *
      *   CUST-xxxx OF WS-CUST-REC   (WORKING STORAGE FIELDS)        *
      *                                                                *
      * FIXES APPLIED FROM ORIGINAL CODE REVIEW:                      *
      *   01 - REMOVED INVALID PERFORM...WITH SYNTAX                  *
      *   02 - DEFINED WS-ERROR-CODE / WS-ERROR-MESSAGE IN WS         *
      *   03 - ERRORREC COPIED DIRECTLY UNDER FD (HAS OWN 01-LEVEL)  *
      *   04 - READ MASTER INTO WS-CUST-REC NOT OUTPUT RECORD         *
      *   05 - EXPLICIT MOVE FROM WS TO OUTPUT RECORD BEFORE WRITE    *
      *   06 - ALL CUST-ID REFERENCES FULLY QUALIFIED                 *
      *   07 - ALL CUST-STATUS REFERENCES FULLY QUALIFIED             *
      *   08 - ALL CUST-BALANCE REFERENCES FULLY QUALIFIED            *
      *   09 - PER-TRANSACTION ERROR FLAG REPLACES CUMULATIVE COUNT   *
      *   10 - FILE STATUS CHECKED AFTER EVERY OPEN/READ/WRITE        *
      *   11 - DELETE READ SEQUENCING EXPLICIT AND CORRECT            *
      *   12 - UNUSED WS-CURRENT-TIMESTAMP REMOVED                    *
      *   13 - REPORT-FILE WRITTEN IN 9000-PRINT-SUMMARY              *
      *   W1 - ALL COMMENT LINES USE * IN COLUMN 7                    *
      *   W2 - ALL FIELD REFERENCES USE ACTUAL COPYBOOK FIELD NAMES   *
      *   W3 - FILE STATUS CHECKED AFTER EVERY WRITE                  *
      *   W4 - ERR-TIMESTAMP PIC X(26) MATCHES ACTUAL ERRORREC        *
      *   W5 - REMOVED SPURIOUS PERFORM...WITH TEST BEFORE            *
      *   W6 - CUSTREC REPLACING USED ON ALL FDS FOR UNIQUE NAMES     *
      *   W7 - WS-ERROR-MESSAGE SIZED TO X(60) TO MATCH ERRORREC      *
      *   W8 - WS-TRANS-READ-COUNT SIZED TO 9(8) TO MATCH ERRORREC    *
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTUPD.
       AUTHOR. PORTFOLIO DEMO.

      *****************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
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

      *****************************************************************
       DATA DIVISION.
       FILE SECTION.

      *---------------------------------------------------------------*
      * CUSTOMER MASTER INPUT FILE                                     *
      * CUSTREC REPLACING GIVES THIS COPY A UNIQUE 01-LEVEL NAME      *
      * EXPANDED AS: 01 CUST-IN-REC                                   *
      *                 05 CUST-ID, CUST-NAME ... etc                  *
      *---------------------------------------------------------------*
       FD  CUST-MASTER-IN
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
           COPY CUSTREC REPLACING CUSTOMER-RECORD BY CUST-IN-REC.

      *---------------------------------------------------------------*
      * CUSTOMER MASTER OUTPUT FILE                                    *
      * CUSTREC REPLACING GIVES THIS COPY A UNIQUE 01-LEVEL NAME      *
      * EXPANDED AS: 01 CUST-OUT-REC                                  *
      *                 05 CUST-ID, CUST-NAME ... etc                  *
      *---------------------------------------------------------------*
       FD  CUST-MASTER-OUT
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
           COPY CUSTREC REPLACING CUSTOMER-RECORD BY CUST-OUT-REC.

      *---------------------------------------------------------------*
      * TRANSACTION INPUT FILE                                         *
      * TRANS-TYPE BYTE PRECEDES THE CUSTOMER DATA PORTION             *
      * CUSTREC REPLACING GIVES THE CUSTOMER PORTION A UNIQUE NAME    *
      * EXPANDED AS: 05 TRANS-CUST-DATA                               *
      *                 01 TRANS-REC                                   *
      *                    05 CUST-ID, CUST-NAME ... etc               *
      *---------------------------------------------------------------*
       FD  TRANS-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
       01  TRANS-INPUT-REC.
           05  TRANS-TYPE               PIC X(1).
               88  TRANS-ADD                    VALUE 'A'.
               88  TRANS-UPDATE                 VALUE 'U'.
               88  TRANS-DELETE                 VALUE 'D'.
           05  TRANS-CUST-DATA.
               COPY CUSTREC REPLACING CUSTOMER-RECORD
                                    BY TRANS-REC.

      *---------------------------------------------------------------*
      * REPORT OUTPUT FILE                                             *
      *---------------------------------------------------------------*
       FD  REPORT-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
       01  REPORT-LINE                  PIC X(132).

      *---------------------------------------------------------------*
      * ERROR OUTPUT FILE                                              *
      * ERRORREC DEFINES ITS OWN 01-LEVEL (ERROR-RECORD)              *
      * COPIED DIRECTLY UNDER FD - NO WRAPPER 01 REQUIRED             *
      *---------------------------------------------------------------*
       FD  ERROR-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
           COPY ERRORREC.

      *****************************************************************
       WORKING-STORAGE SECTION.

      *---------------------------------------------------------------*
      * FILE STATUS FIELDS - ONE PER SELECT STATEMENT                  *
      *---------------------------------------------------------------*
       01  WS-FILE-STATUS.
           05  WS-CUST-IN-STATUS        PIC XX VALUE SPACES.
           05  WS-CUST-OUT-STATUS       PIC XX VALUE SPACES.
           05  WS-TRANS-STATUS          PIC XX VALUE SPACES.
           05  WS-REPORT-STATUS         PIC XX VALUE SPACES.
           05  WS-ERROR-STATUS          PIC XX VALUE SPACES.

      *---------------------------------------------------------------*
      * END-OF-FILE FLAGS                                              *
      *---------------------------------------------------------------*
       01  WS-FLAGS.
           05  WS-MASTER-EOF-SW         PIC X VALUE 'N'.
               88  MASTER-EOF                   VALUE 'Y'.
           05  WS-TRANS-EOF-SW          PIC X VALUE 'N'.
               88  TRANS-EOF                    VALUE 'Y'.

      *---------------------------------------------------------------*
      * PER-TRANSACTION VALIDATION ERROR FLAG                          *
      * RESET TO 'N' AT THE START OF EACH CALL TO 2700-VALIDATE       *
      * SET TO 'Y' FOR EACH VALIDATION FAILURE FOUND                   *
      * TESTED IN 2400-ADD-CUSTOMER AND 2500-UPDATE-CUSTOMER           *
      *---------------------------------------------------------------*
       01  WS-TRANS-ERROR-SW            PIC X VALUE 'N'.
           88  TRANS-HAS-ERROR                  VALUE 'Y'.
           88  TRANS-IS-VALID                   VALUE 'N'.

      *---------------------------------------------------------------*
      * PROGRAM COUNTERS                                               *
      * WS-TRANS-READ-COUNT IS PIC 9(8) TO MATCH ERR-RECORD-NUMBER    *
      *---------------------------------------------------------------*
       01  WS-COUNTERS.
           05  WS-MASTER-READ-COUNT     PIC 9(7) VALUE ZERO.
           05  WS-MASTER-WRITE-COUNT    PIC 9(7) VALUE ZERO.
           05  WS-TRANS-READ-COUNT      PIC 9(8) VALUE ZERO.
           05  WS-ADD-COUNT             PIC 9(7) VALUE ZERO.
           05  WS-UPDATE-COUNT          PIC 9(7) VALUE ZERO.
           05  WS-DELETE-COUNT          PIC 9(7) VALUE ZERO.
           05  WS-ERROR-COUNT           PIC 9(7) VALUE ZERO.

      *---------------------------------------------------------------*
      * ERROR STAGING FIELDS FOR 8000-LOG-ERROR                        *
      * CALLERS MOVE VALUES HERE BEFORE PERFORMING 8000                *
      * SIZES MATCH ACTUAL ERR-ERROR-CODE AND ERR-ERROR-MESSAGE        *
      * IN ERRORREC COPYBOOK                                           *
      *---------------------------------------------------------------*
       01  WS-ERROR-FIELDS.
           05  WS-ERROR-CODE            PIC X(10) VALUE SPACES.
           05  WS-ERROR-MESSAGE         PIC X(60) VALUE SPACES.

      *---------------------------------------------------------------*
      * WORKING STORAGE COPY OF CURRENT MASTER RECORD                  *
      * MASTER FILE IS READ INTO HERE VIA READ...INTO                  *
      * PREVENTS INPUT RECORD AREA BEING OVERWRITTEN BY OUTPUT WRITES  *
      * CUSTREC REPLACING GIVES THIS COPY A UNIQUE 01-LEVEL NAME      *
      * EXPANDED AS: 01 WS-CUST-REC                                   *
      *                 05 CUST-ID, CUST-NAME ... etc                  *
      *---------------------------------------------------------------*
       01  WS-MASTER-AREA.
           COPY CUSTREC REPLACING CUSTOMER-RECORD BY WS-CUST-REC.

      *---------------------------------------------------------------*
      * WORKING STORAGE REPORT LINE BUFFER                             *
      *---------------------------------------------------------------*
       01  WS-REPORT-LINE               PIC X(132) VALUE SPACES.

      *---------------------------------------------------------------*
      * FATAL ERROR MESSAGE STAGING AREA                               *
      *---------------------------------------------------------------*
       01  WS-ABEND-MSG                 PIC X(80)  VALUE SPACES.

      *****************************************************************
       PROCEDURE DIVISION.

      *---------------------------------------------------------------*
      * MAIN PROCESSING LOGIC                                          *
      *---------------------------------------------------------------*
       0000-MAIN-PROCESS.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-PROCESS-UPDATES
               UNTIL MASTER-EOF AND TRANS-EOF
           PERFORM 3000-FINALIZE
           STOP RUN.

      *---------------------------------------------------------------*
      * INITIALIZATION                                                 *
      * OPEN ALL FILES THEN PRIME BOTH INPUT READS                     *
      * ANY FILE OPEN FAILURE IS IMMEDIATELY FATAL                     *
      *---------------------------------------------------------------*
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

      *---------------------------------------------------------------*
      * READ NEXT MASTER RECORD INTO WS-CUST-REC                      *
      * USING READ...INTO KEEPS INPUT BUFFER SEPARATE FROM OUTPUT      *
      * STATUS 00 = SUCCESSFUL READ                                    *
      * STATUS 10 = END OF FILE (NORMAL TERMINATION)                  *
      * ANY OTHER STATUS = FATAL I/O ERROR                             *
      *---------------------------------------------------------------*
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

      *---------------------------------------------------------------*
      * READ NEXT TRANSACTION RECORD                                   *
      * STATUS 00 = SUCCESSFUL READ                                    *
      * STATUS 10 = END OF FILE (NORMAL TERMINATION)                  *
      * ANY OTHER STATUS = FATAL I/O ERROR                             *
      *---------------------------------------------------------------*
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

      *---------------------------------------------------------------*
      * SEQUENTIAL FILE MERGE LOGIC                                    *
      * BOTH FILES ARE SORTED ASCENDING BY CUSTOMER ID                 *
      *                                                                *
      * CASE 1: MASTER EOF, TRANS ACTIVE                               *
      *         ONLY ADDS ARE VALID - PROCESS TRANS ONLY               *
      * CASE 2: TRANS EOF, MASTER ACTIVE                               *
      *         COPY REMAINING MASTER RECORDS TO OUTPUT                *
      * CASE 3: MASTER KEY < TRANS KEY                                 *
      *         NO TRANSACTION FOR THIS MASTER - COPY TO OUTPUT        *
      * CASE 4: MASTER KEY > TRANS KEY                                 *
      *         NO MASTER FOR THIS TRANSACTION - MUST BE AN ADD        *
      * CASE 5: MASTER KEY = TRANS KEY                                 *
      *         MATCHING RECORDS - PROCESS UPDATE OR DELETE            *
      *---------------------------------------------------------------*
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

      *---------------------------------------------------------------*
      * NO MATCHING MASTER EXISTS FOR THIS TRANSACTION                 *
      * VALID ONLY FOR TRANS-ADD - ALL OTHER TYPES ARE ERRORS          *
      * READS NEXT TRANSACTION BEFORE RETURNING                        *
      *---------------------------------------------------------------*
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

      *---------------------------------------------------------------*
      * NO TRANSACTION EXISTS FOR THIS MASTER RECORD                   *
      * COPY MASTER RECORD UNCHANGED TO OUTPUT                         *
      * READS NEXT MASTER BEFORE RETURNING                             *
      *---------------------------------------------------------------*
       2200-COPY-MASTER-ONLY.
           MOVE WS-CUST-REC                TO CUST-OUT-REC
           WRITE CUST-OUT-REC
           IF WS-CUST-OUT-STATUS NOT = '00'
               MOVE 'WRITE ERROR: CUST-MASTER-OUT FS='
                                            TO WS-ABEND-MSG(1:36)
               MOVE WS-CUST-OUT-STATUS      TO WS-ABEND-MSG(37:2)
               PERFORM 9900-FATAL-ERROR
           END-IF
           ADD 1                            TO WS-MASTER-WRITE-COUNT
           PERFORM 1100-READ-MASTER.

      *---------------------------------------------------------------*
      * TRANSACTION KEY MATCHES MASTER KEY                             *
      * EVALUATE TRANSACTION TYPE AND PROCESS ACCORDINGLY             *
      * READS BOTH MASTER AND TRANSACTION FORWARD BEFORE RETURNING     *
      *---------------------------------------------------------------*
       2300-PROCESS-MATCHING.
           EVALUATE TRUE
               WHEN TRANS-ADD
      *            ADD FOR AN ALREADY-EXISTING CUSTOMER IS AN ERROR
      *            LOG THE ERROR BUT PRESERVE THE EXISTING MASTER
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

      *---------------------------------------------------------------*
      * ADD NEW CUSTOMER TO OUTPUT FILE                                *
      * VALIDATE FIRST - ONLY WRITE IF ALL VALIDATIONS PASS           *
      * IF INVALID - RECORD IS DISCARDED AND ERRORS ARE LOGGED         *
      *---------------------------------------------------------------*
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

      *---------------------------------------------------------------*
      * UPDATE EXISTING CUSTOMER IN OUTPUT FILE                        *
      * VALIDATE FIRST                                                 *
      * IF VALID:   COPY MASTER TO OUTPUT THEN OVERLAY CHANGED FIELDS  *
      * IF INVALID: WRITE EXISTING MASTER UNCHANGED - ERRORS LOGGED    *
      *---------------------------------------------------------------*
       2500-UPDATE-CUSTOMER.
           PERFORM 2700-VALIDATE-CUSTOMER

           IF TRANS-IS-VALID
               MOVE WS-CUST-REC           TO CUST-OUT-REC
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
      *        VALIDATION FAILED - PRESERVE EXISTING MASTER UNCHANGED
               MOVE WS-CUST-REC            TO CUST-OUT-REC
               WRITE CUST-OUT-REC
               IF WS-CUST-OUT-STATUS NOT = '00'
                   MOVE 'WRITE ERROR: CUST-MASTER-OUT FS='
                                            TO WS-ABEND-MSG(1:36)
                   MOVE WS-CUST-OUT-STATUS  TO WS-ABEND-MSG(37:2)
                   PERFORM 9900-FATAL-ERROR
               END-IF
               ADD 1                        TO WS-MASTER-WRITE-COUNT
           END-IF.

      *---------------------------------------------------------------*
      * DELETE EXISTING CUSTOMER FROM OUTPUT FILE                      *
      * DELETION IS ACHIEVED BY NOT WRITING THE RECORD TO OUTPUT       *
      * CUSTOMERS WITH A NON-ZERO BALANCE CANNOT BE DELETED           *
      * IF BALANCE > ZERO: LOG ERROR AND PRESERVE THE MASTER RECORD    *
      *---------------------------------------------------------------*
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
      *        RECORD NOT WRITTEN TO OUTPUT - THIS IS THE DELETION
           END-IF.

      *---------------------------------------------------------------*
      * VALIDATE TRANSACTION DATA PRIOR TO ADD OR UPDATE              *
      * WS-TRANS-ERROR-SW IS RESET TO 'N' ON ENTRY EVERY CALL         *
      * SET TO 'Y' FOR EACH INDIVIDUAL VALIDATION FAILURE              *
      * CALLERS TEST TRANS-IS-VALID OR TRANS-HAS-ERROR ON RETURN       *
      *                                                                *
      * NOTE ON CREDIT LIMIT CHECK:                                    *
      *   CUST-CREDIT-LIMIT IN CUSTREC IS PIC 9(8)V99 (UNSIGNED).     *
      *   THE < ZERO TEST BELOW CAN NEVER FIRE FOR AN UNSIGNED FIELD.  *
      *   TO ACTIVATE THIS VALIDATION CUSTREC WOULD NEED TO DEFINE     *
      *   CUST-CREDIT-LIMIT AS PIC S9(8)V99 COMP-3.                   *
      *   THE CHECK IS RETAINED HERE FOR COMPLETENESS AND FUTURE USE.  *
      *---------------------------------------------------------------*
       2700-VALIDATE-CUSTOMER.
           MOVE 'N'                        TO WS-TRANS-ERROR-SW

      *    CHECK 1: CUSTOMER NAME MUST NOT BE SPACES
           IF CUST-NAME OF TRANS-REC = SPACES
               MOVE 'E-NAME'               TO WS-ERROR-CODE
               MOVE 'CUSTOMER NAME IS REQUIRED'
                                           TO WS-ERROR-MESSAGE
               PERFORM 8000-LOG-ERROR
               MOVE 'Y'                    TO WS-TRANS-ERROR-SW
           END-IF

      *    CHECK 2: STATE CODE MUST BE ALPHABETIC
           IF CUST-STATE OF TRANS-REC NOT ALPHABETIC
               MOVE 'E-STATE'              TO WS-ERROR-CODE
               MOVE 'INVALID STATE CODE - MUST BE ALPHABETIC'
                                           TO WS-ERROR-MESSAGE
               PERFORM 8000-LOG-ERROR
               MOVE 'Y'                    TO WS-TRANS-ERROR-SW
           END-IF

      *    CHECK 3: CREDIT LIMIT MUST NOT BE NEGATIVE (SEE NOTE ABOVE)
           IF CUST-CREDIT-LIMIT OF TRANS-REC < ZERO
               MOVE 'E-CREDIT'             TO WS-ERROR-CODE
               MOVE 'CREDIT LIMIT CANNOT BE NEGATIVE'
                                           TO WS-ERROR-MESSAGE
               PERFORM 8000-LOG-ERROR
               MOVE 'Y'                    TO WS-TRANS-ERROR-SW
           END-IF.

      *---------------------------------------------------------------*
      * FINALIZATION                                                   *
      * PRINT SUMMARY REPORT BEFORE CLOSING ALL FILES                  *
      *---------------------------------------------------------------*
       3000-FINALIZE.
           PERFORM 9000-PRINT-SUMMARY

           CLOSE CUST-MASTER-IN
           CLOSE CUST-MASTER-OUT
           CLOSE TRANS-FILE
           CLOSE REPORT-FILE
           CLOSE ERROR-FILE.

      *---------------------------------------------------------------*
      * LOG ONE ERROR RECORD TO THE ERROR FILE                         *
      * CALLER MUST MOVE VALUES TO WS-ERROR-CODE AND WS-ERROR-MESSAGE  *
      * BEFORE PERFORMING THIS PARAGRAPH                               *
      * CUST-ID OF TRANS-REC IS WRITTEN TO ERR-INPUT-DATA FOR CONTEXT  *
      * WS-ERROR-CODE AND WS-ERROR-MESSAGE ARE CLEARED AFTER WRITE     *
      *                                                                *
      * NOTE: FUNCTION CURRENT-DATE RETURNS 21 CHARACTERS.            *
      *       ERR-TIMESTAMP IS PIC X(26). THE MOVE WILL SPACE-FILL    *
      *       THE TRAILING 5 BYTES. THIS IS ACCEPTABLE BEHAVIOUR.      *
      *---------------------------------------------------------------*
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

      *---------------------------------------------------------------*
      * PRINT RUN SUMMARY TO REPORT-FILE AND ECHO TO SYSOUT           *
      *---------------------------------------------------------------*
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

      *    ECHO SUMMARY TO SYSOUT FOR OPERATOR VISIBILITY
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

      *---------------------------------------------------------------*
      * WRITE ONE LINE TO THE REPORT FILE                              *
      * MOVES WS-REPORT-LINE INTO REPORT-LINE BUFFER THEN WRITES      *
      * CLEARS WS-REPORT-LINE AFTER SUCCESSFUL WRITE                   *
      *---------------------------------------------------------------*
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
      *---------------------------------------------------------------*
      * FATAL ERROR HANDLER                                            *
      * DISPLAY DIAGNOSTIC MESSAGE TO SYSOUT                          *
      * SET RETURN CODE 16 TO SIGNAL FAILURE TO JCL                   *
      * TERMINATE THE PROGRAM                                          *
      *---------------------------------------------------------------*
       9900-FATAL-ERROR.
           DISPLAY '*** CUSTUPD FATAL ERROR: ' WS-ABEND-MSG
           MOVE 16                          TO RETURN-CODE
           STOP RUN.
