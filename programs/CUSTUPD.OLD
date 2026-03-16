       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTUPD.
       AUTHOR. PORTFOLIO DEMO.
      ******************************************************************
      * PROGRAM NAME: CUSTUPD                                          *
      * DESCRIPTION:  CUSTOMER MASTER FILE UPDATE                      *
      *               PROCESSES TRANSACTION FILE TO:                   *
      *               - ADD NEW CUSTOMERS                              *
      *               - UPDATE EXISTING CUSTOMERS                      *
      *               - VALIDATE ALL TRANSACTIONS                      *
      * INPUTS:       CUSTOMER MASTER FILE                             *
      *               TRANSACTION FILE                                 *
      * OUTPUTS:      UPDATED MASTER FILE                              *
      *               UPDATE REPORT                                    *
      *               ERROR FILE                                       *
      ******************************************************************
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUST-MASTER-IN ASSIGN TO CUSTMIN
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE IS SEQUENTIAL
                  FILE STATUS IS WS-CUST-IN-STATUS.
           
           SELECT CUST-MASTER-OUT ASSIGN TO CUSTMOUT
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE IS SEQUENTIAL
                  FILE STATUS IS WS-CUST-OUT-STATUS.
           
           SELECT TRANS-FILE ASSIGN TO TRANSIN
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE IS SEQUENTIAL
                  FILE STATUS IS WS-TRANS-STATUS.
           
           SELECT REPORT-FILE ASSIGN TO RPTUPDOUT
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE IS SEQUENTIAL
                  FILE STATUS IS WS-REPORT-STATUS.
           
           SELECT ERROR-FILE ASSIGN TO ERROROUT
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE IS SEQUENTIAL
                  FILE STATUS IS WS-ERROR-STATUS.
       
       DATA DIVISION.
       FILE SECTION.
       
       FD  CUST-MASTER-IN
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
       01  CUST-MASTER-IN-REC.
           COPY CUSTREC.
       
       FD  CUST-MASTER-OUT
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
       01  CUST-MASTER-OUT-REC.
           COPY CUSTREC.
       
       FD  TRANS-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
       01  TRANS-REC.
           05  TRANS-TYPE               PIC X(1).
               88  TRANS-ADD                    VALUE 'A'.
               88  TRANS-UPDATE                 VALUE 'U'.
               88  TRANS-DELETE                 VALUE 'D'.
           05  TRANS-CUST-DATA.
               COPY CUSTREC REPLACING CUSTOMER-RECORD BY TRANS-CUST-REC.
       
       FD  REPORT-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
       01  REPORT-LINE                  PIC X(132).
       
       FD  ERROR-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
       COPY ERRORREC.
       
       WORKING-STORAGE SECTION.
       
       01  WS-FILE-STATUS.
           05  WS-CUST-IN-STATUS        PIC XX.
           05  WS-CUST-OUT-STATUS       PIC XX.
           05  WS-TRANS-STATUS          PIC XX.
           05  WS-REPORT-STATUS         PIC XX.
           05  WS-ERROR-STATUS          PIC XX.
       
       01  WS-FLAGS.
           05  WS-MASTER-EOF-SW         PIC X VALUE 'N'.
               88  MASTER-EOF                   VALUE 'Y'.
           05  WS-TRANS-EOF-SW          PIC X VALUE 'N'.
               88  TRANS-EOF                    VALUE 'Y'.
       
       01  WS-COUNTERS.
           05  WS-MASTER-READ-COUNT     PIC 9(7) VALUE ZERO.
           05  WS-MASTER-WRITE-COUNT    PIC 9(7) VALUE ZERO.
           05  WS-TRANS-READ-COUNT      PIC 9(7) VALUE ZERO.
           05  WS-ADD-COUNT             PIC 9(7) VALUE ZERO.
           05  WS-UPDATE-COUNT          PIC 9(7) VALUE ZERO.
           05  WS-DELETE-COUNT          PIC 9(7) VALUE ZERO.
           05  WS-ERROR-COUNT           PIC 9(7) VALUE ZERO.
       
       01  WS-CURRENT-TIMESTAMP         PIC X(26).
       
       PROCEDURE DIVISION.
       
      *----------------------------------------------------------------*
      * MAIN PROCESSING LOGIC                                          *
      *----------------------------------------------------------------*
       0000-MAIN-PROCESS.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-PROCESS-UPDATES
                  UNTIL MASTER-EOF AND TRANS-EOF
           PERFORM 3000-FINALIZE
           STOP RUN.
       
      *----------------------------------------------------------------*
      * INITIALIZATION                                                 *
      *----------------------------------------------------------------*
       1000-INITIALIZE.
           OPEN INPUT CUST-MASTER-IN
           OPEN INPUT TRANS-FILE
           OPEN OUTPUT CUST-MASTER-OUT
           OPEN OUTPUT REPORT-FILE
           OPEN OUTPUT ERROR-FILE
           
           PERFORM 1100-READ-MASTER
           PERFORM 1200-READ-TRANSACTION.
       
       1100-READ-MASTER.
           READ CUST-MASTER-IN INTO CUST-MASTER-OUT-REC
               AT END
                   MOVE 'Y' TO WS-MASTER-EOF-SW
               NOT AT END
                   ADD 1 TO WS-MASTER-READ-COUNT
           END-READ.
       
       1200-READ-TRANSACTION.
           READ TRANS-FILE
               AT END
                   MOVE 'Y' TO WS-TRANS-EOF-SW
               NOT AT END
                   ADD 1 TO WS-TRANS-READ-COUNT
           END-READ.
       
      *----------------------------------------------------------------*
      * PROCESS UPDATES - MERGE LOGIC                                  *
      *----------------------------------------------------------------*
       2000-PROCESS-UPDATES.
           IF MASTER-EOF AND NOT TRANS-EOF
               PERFORM 2100-PROCESS-TRANS-ONLY
           ELSE IF TRANS-EOF AND NOT MASTER-EOF
               PERFORM 2200-COPY-MASTER-ONLY
           ELSE IF CUST-ID < TRANS-CUST-ID OF TRANS-CUST-DATA
               PERFORM 2200-COPY-MASTER-ONLY
           ELSE IF CUST-ID > TRANS-CUST-ID OF TRANS-CUST-DATA
               PERFORM 2100-PROCESS-TRANS-ONLY
           ELSE
               PERFORM 2300-PROCESS-MATCHING
           END-IF.
       
       2100-PROCESS-TRANS-ONLY.
           EVALUATE TRUE
               WHEN TRANS-ADD
                   PERFORM 2400-ADD-CUSTOMER
               WHEN TRANS-UPDATE
                   PERFORM 8000-LOG-ERROR
                       WITH 'E-UPDATE' 
                       'UPDATE TRANS FOR NON-EXISTENT CUSTOMER'
               WHEN TRANS-DELETE
                   PERFORM 8000-LOG-ERROR
                       WITH 'E-DELETE'
                       'DELETE TRANS FOR NON-EXISTENT CUSTOMER'
           END-EVALUATE
           
           PERFORM 1200-READ-TRANSACTION.
       
       2200-COPY-MASTER-ONLY.
           WRITE CUST-MASTER-OUT-REC
           ADD 1 TO WS-MASTER-WRITE-COUNT
           PERFORM 1100-READ-MASTER.
       
       2300-PROCESS-MATCHING.
           EVALUATE TRUE
               WHEN TRANS-ADD
                   PERFORM 8000-LOG-ERROR
                       WITH 'E-ADD' 
                       'ADD TRANS FOR EXISTING CUSTOMER'
                   WRITE CUST-MASTER-OUT-REC
                   ADD 1 TO WS-MASTER-WRITE-COUNT
               WHEN TRANS-UPDATE
                   PERFORM 2500-UPDATE-CUSTOMER
               WHEN TRANS-DELETE
                   PERFORM 2600-DELETE-CUSTOMER
           END-EVALUATE
           
           PERFORM 1100-READ-MASTER
           PERFORM 1200-READ-TRANSACTION.
       
       2400-ADD-CUSTOMER.
           PERFORM 2700-VALIDATE-CUSTOMER
           
           IF WS-ERROR-COUNT = ZERO
               MOVE TRANS-CUST-DATA TO CUST-MASTER-OUT-REC
               MOVE 'A' TO CUST-STATUS
               WRITE CUST-MASTER-OUT-REC
               ADD 1 TO WS-MASTER-WRITE-COUNT
               ADD 1 TO WS-ADD-COUNT
           END-IF.
       
       2500-UPDATE-CUSTOMER.
           PERFORM 2700-VALIDATE-CUSTOMER
           
           IF WS-ERROR-COUNT = ZERO
               MOVE TRANS-CUST-NAME TO CUST-NAME
               MOVE TRANS-CUST-ADDRESS TO CUST-ADDRESS
               MOVE TRANS-CUST-CITY TO CUST-CITY
               MOVE TRANS-CUST-STATE TO CUST-STATE
               MOVE TRANS-CUST-ZIP TO CUST-ZIP
               MOVE TRANS-CUST-EMAIL TO CUST-EMAIL
               MOVE TRANS-CUST-PHONE TO CUST-PHONE
               MOVE TRANS-CUST-CREDIT-LIMIT TO CUST-CREDIT-LIMIT
               
               WRITE CUST-MASTER-OUT-REC
               ADD 1 TO WS-MASTER-WRITE-COUNT
               ADD 1 TO WS-UPDATE-COUNT
           ELSE
               WRITE CUST-MASTER-OUT-REC
               ADD 1 TO WS-MASTER-WRITE-COUNT
           END-IF.
       
       2600-DELETE-CUSTOMER.
           IF CUST-BALANCE > ZERO
               PERFORM 8000-LOG-ERROR
                   WITH 'E-BALANCE'
                   'CANNOT DELETE CUSTOMER WITH BALANCE'
               WRITE CUST-MASTER-OUT-REC
               ADD 1 TO WS-MASTER-WRITE-COUNT
           ELSE
               ADD 1 TO WS-DELETE-COUNT
               * Do not write - effectively deletes the record
           END-IF.
       
       2700-VALIDATE-CUSTOMER.
           * Validate customer name
           IF TRANS-CUST-NAME = SPACES
               PERFORM 8000-LOG-ERROR
                   WITH 'E-NAME' 'CUSTOMER NAME IS REQUIRED'
           END-IF
           
           * Validate state code
           IF TRANS-CUST-STATE NOT ALPHABETIC
               PERFORM 8000-LOG-ERROR
                   WITH 'E-STATE' 'INVALID STATE CODE'
           END-IF
           
           * Validate credit limit
           IF TRANS-CUST-CREDIT-LIMIT < ZERO
               PERFORM 8000-LOG-ERROR
                   WITH 'E-CREDIT' 'CREDIT LIMIT CANNOT BE NEGATIVE'
           END-IF.
       
      *----------------------------------------------------------------*
      * FINALIZATION                                                   *
      *----------------------------------------------------------------*
       3000-FINALIZE.
           CLOSE CUST-MASTER-IN
           CLOSE CUST-MASTER-OUT
           CLOSE TRANS-FILE
           CLOSE REPORT-FILE
           CLOSE ERROR-FILE
           
           PERFORM 9000-PRINT-SUMMARY.
       
      *----------------------------------------------------------------*
      * LOG ERROR TO ERROR FILE                                        *
      *----------------------------------------------------------------*
       8000-LOG-ERROR.
           MOVE FUNCTION CURRENT-DATE TO ERR-TIMESTAMP
           MOVE WS-TRANS-READ-COUNT TO ERR-RECORD-NUMBER
           MOVE ERROR-CODE TO ERR-ERROR-CODE
           MOVE ERROR-MESSAGE TO ERR-ERROR-MESSAGE
           MOVE TRANS-CUST-ID OF TRANS-CUST-DATA TO ERR-INPUT-DATA
           
           WRITE ERROR-RECORD
           ADD 1 TO WS-ERROR-COUNT.
       
      *----------------------------------------------------------------*
      * PRINT SUMMARY REPORT                                           *
      *----------------------------------------------------------------*
       9000-PRINT-SUMMARY.
           DISPLAY '========================================='
           DISPLAY 'CUSTOMER UPDATE SUMMARY'
           DISPLAY '========================================='
           DISPLAY 'MASTER RECORDS READ:     ' WS-MASTER-READ-COUNT
           DISPLAY 'MASTER RECORDS WRITTEN:  ' WS-MASTER-WRITE-COUNT
           DISPLAY 'TRANSACTIONS PROCESSED:  ' WS-TRANS-READ-COUNT
           DISPLAY '  ADDS:                  ' WS-ADD-COUNT
           DISPLAY '  UPDATES:               ' WS-UPDATE-COUNT
           DISPLAY '  DELETES:               ' WS-DELETE-COUNT
           DISPLAY 'ERRORS DETECTED:         ' WS-ERROR-COUNT
           DISPLAY '========================================='.
