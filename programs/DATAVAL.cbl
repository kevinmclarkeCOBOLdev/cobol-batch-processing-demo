       IDENTIFICATION DIVISION.
       PROGRAM-ID. DATAVAL.
       AUTHOR. PORTFOLIO DEMO.
      ******************************************************************
      * PROGRAM NAME: DATAVAL                                          *
      * DESCRIPTION:  DATA VALIDATION PROGRAM                          *
      *               VALIDATES INPUT DATA FILE FOR:                   *
      *               - REQUIRED FIELDS                                *
      *               - NUMERIC FIELD VALIDITY                         *
      *               - DATE FORMAT VALIDATION                         *
      *               - BUSINESS RULE VALIDATION                       *
      * INPUT:        RAW DATA FILE                                    *
      * OUTPUTS:      CLEAN DATA FILE                                  *
      *               ERROR REPORT FILE                                *
      ******************************************************************
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INPUT-FILE ASSIGN TO DATAIN
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE IS SEQUENTIAL
                  FILE STATUS IS WS-INPUT-STATUS.
           
           SELECT CLEAN-FILE ASSIGN TO DATAOUT
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE IS SEQUENTIAL
                  FILE STATUS IS WS-CLEAN-STATUS.
           
           SELECT ERROR-FILE ASSIGN TO ERROROUT
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE IS SEQUENTIAL
                  FILE STATUS IS WS-ERROR-STATUS.
       
       DATA DIVISION.
       FILE SECTION.
       
       FD  INPUT-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
       COPY SALESREC REPLACING SALES-RECORD BY INPUT-RECORD.
       
       FD  CLEAN-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
       COPY SALESREC REPLACING SALES-RECORD BY CLEAN-RECORD.
       
       FD  ERROR-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
       COPY ERRORREC.
       
       WORKING-STORAGE SECTION.
       
       01  WS-FILE-STATUS.
           05  WS-INPUT-STATUS          PIC XX.
           05  WS-CLEAN-STATUS          PIC XX.
           05  WS-ERROR-STATUS          PIC XX.
       
       01  WS-FLAGS.
           05  WS-EOF-SW                PIC X VALUE 'N'.
               88  END-OF-FILE                  VALUE 'Y'.
           05  WS-RECORD-VALID-SW       PIC X VALUE 'Y'.
               88  RECORD-VALID                 VALUE 'Y'.
               88  RECORD-INVALID               VALUE 'N'.
       
       01  WS-COUNTERS.
           05  WS-RECORDS-READ          PIC 9(7) VALUE ZERO.
           05  WS-RECORDS-CLEAN         PIC 9(7) VALUE ZERO.
           05  WS-RECORDS-ERROR         PIC 9(7) VALUE ZERO.
       
       01  WS-DATE-FIELDS.
           05  WS-YEAR                  PIC 9(4).
           05  WS-MONTH                 PIC 9(2).
           05  WS-DAY                   PIC 9(2).
       
       01  WS-NUMERIC-TEST              PIC 9(10).
       
       PROCEDURE DIVISION.
       
      *----------------------------------------------------------------*
      * MAIN PROCESSING LOGIC                                          *
      *----------------------------------------------------------------*
       0000-MAIN-PROCESS.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-PROCESS-RECORDS UNTIL END-OF-FILE
           PERFORM 3000-FINALIZE
           STOP RUN.
       
      *----------------------------------------------------------------*
      * INITIALIZATION                                                 *
      *----------------------------------------------------------------*
       1000-INITIALIZE.
           OPEN INPUT INPUT-FILE
           OPEN OUTPUT CLEAN-FILE
           OPEN OUTPUT ERROR-FILE
           
           PERFORM 1100-READ-INPUT.
       
       1100-READ-INPUT.
           READ INPUT-FILE
               AT END
                   MOVE 'Y' TO WS-EOF-SW
               NOT AT END
                   ADD 1 TO WS-RECORDS-READ
           END-READ.
       
      *----------------------------------------------------------------*
      * PROCESS RECORDS                                                *
      *----------------------------------------------------------------*
       2000-PROCESS-RECORDS.
           MOVE 'Y' TO WS-RECORD-VALID-SW
           
           PERFORM 2100-VALIDATE-SALESPERSON-ID
           PERFORM 2200-VALIDATE-SALESPERSON-NAME
           PERFORM 2300-VALIDATE-SALE-DATE
           PERFORM 2400-VALIDATE-PRODUCT-CODE
           PERFORM 2500-VALIDATE-QUANTITY
           PERFORM 2600-VALIDATE-SALE-AMOUNT
           PERFORM 2700-VALIDATE-REGION
           
           IF RECORD-VALID
               MOVE INPUT-RECORD TO CLEAN-RECORD
               WRITE CLEAN-RECORD
               ADD 1 TO WS-RECORDS-CLEAN
           ELSE
               ADD 1 TO WS-RECORDS-ERROR
           END-IF
           
           PERFORM 1100-READ-INPUT.
       
      *----------------------------------------------------------------*
      * VALIDATE SALESPERSON ID                                        *
      *----------------------------------------------------------------*
       2100-VALIDATE-SALESPERSON-ID.
           IF SR-SALESPERSON-ID = ZERO
               PERFORM 8000-LOG-ERROR
                   WITH 'V-SALESID' 'SALESPERSON ID IS REQUIRED'
               MOVE 'N' TO WS-RECORD-VALID-SW
           END-IF.
       
      *----------------------------------------------------------------*
      * VALIDATE SALESPERSON NAME                                      *
      *----------------------------------------------------------------*
       2200-VALIDATE-SALESPERSON-NAME.
           IF SR-SALESPERSON-NAME = SPACES
               PERFORM 8000-LOG-ERROR
                   WITH 'V-NAME' 'SALESPERSON NAME IS REQUIRED'
               MOVE 'N' TO WS-RECORD-VALID-SW
           END-IF.
       
      *----------------------------------------------------------------*
      * VALIDATE SALE DATE                                             *
      *----------------------------------------------------------------*
       2300-VALIDATE-SALE-DATE.
           IF SR-SALE-DATE = SPACES
               PERFORM 8000-LOG-ERROR
                   WITH 'V-DATE' 'SALE DATE IS REQUIRED'
               MOVE 'N' TO WS-RECORD-VALID-SW
           ELSE
               * Validate date format YYYY-MM-DD
               IF SR-SALE-DATE(1:4) NOT NUMERIC
                  OR SR-SALE-DATE(5:1) NOT = '-'
                  OR SR-SALE-DATE(6:2) NOT NUMERIC
                  OR SR-SALE-DATE(8:1) NOT = '-'
                  OR SR-SALE-DATE(9:2) NOT NUMERIC
                   PERFORM 8000-LOG-ERROR
                       WITH 'V-DATEFMT' 'INVALID DATE FORMAT'
                   MOVE 'N' TO WS-RECORD-VALID-SW
               ELSE
                   * Validate month range
                   MOVE SR-SALE-DATE(6:2) TO WS-MONTH
                   IF WS-MONTH < 1 OR WS-MONTH > 12
                       PERFORM 8000-LOG-ERROR
                           WITH 'V-MONTH' 'INVALID MONTH'
                       MOVE 'N' TO WS-RECORD-VALID-SW
                   END-IF
                   
                   * Validate day range
                   MOVE SR-SALE-DATE(9:2) TO WS-DAY
                   IF WS-DAY < 1 OR WS-DAY > 31
                       PERFORM 8000-LOG-ERROR
                           WITH 'V-DAY' 'INVALID DAY'
                       MOVE 'N' TO WS-RECORD-VALID-SW
                   END-IF
               END-IF
           END-IF.
       
      *----------------------------------------------------------------*
      * VALIDATE PRODUCT CODE                                          *
      *----------------------------------------------------------------*
       2400-VALIDATE-PRODUCT-CODE.
           IF SR-PRODUCT-CODE = SPACES
               PERFORM 8000-LOG-ERROR
                   WITH 'V-PRODUCT' 'PRODUCT CODE IS REQUIRED'
               MOVE 'N' TO WS-RECORD-VALID-SW
           END-IF.
       
      *----------------------------------------------------------------*
      * VALIDATE QUANTITY                                              *
      *----------------------------------------------------------------*
       2500-VALIDATE-QUANTITY.
           IF SR-QUANTITY = ZERO
               PERFORM 8000-LOG-ERROR
                   WITH 'V-QTY' 'QUANTITY MUST BE GREATER THAN ZERO'
               MOVE 'N' TO WS-RECORD-VALID-SW
           END-IF
           
           IF SR-QUANTITY > 999999
               PERFORM 8000-LOG-ERROR
                   WITH 'V-QTYMAX' 'QUANTITY EXCEEDS MAXIMUM'
               MOVE 'N' TO WS-RECORD-VALID-SW
           END-IF.
       
      *----------------------------------------------------------------*
      * VALIDATE SALE AMOUNT                                           *
      *----------------------------------------------------------------*
       2600-VALIDATE-SALE-AMOUNT.
           IF SR-SALE-AMOUNT = ZERO
               PERFORM 8000-LOG-ERROR
                   WITH 'V-AMOUNT' 'SALE AMOUNT MUST BE GREATER THAN ZERO'
               MOVE 'N' TO WS-RECORD-VALID-SW
           END-IF.
       
      *----------------------------------------------------------------*
      * VALIDATE REGION                                                *
      *----------------------------------------------------------------*
       2700-VALIDATE-REGION.
           IF SR-REGION = SPACES
               PERFORM 8000-LOG-ERROR
                   WITH 'V-REGION' 'REGION IS REQUIRED'
               MOVE 'N' TO WS-RECORD-VALID-SW
           ELSE
               EVALUATE SR-REGION
                   WHEN 'NORTHEAST'
                   WHEN 'SOUTHEAST'
                   WHEN 'MIDWEST'
                   WHEN 'SOUTHWEST'
                   WHEN 'WEST'
                       CONTINUE
                   WHEN OTHER
                       PERFORM 8000-LOG-ERROR
                           WITH 'V-REGCODE' 'INVALID REGION CODE'
                       MOVE 'N' TO WS-RECORD-VALID-SW
               END-EVALUATE
           END-IF.
       
      *----------------------------------------------------------------*
      * FINALIZATION                                                   *
      *----------------------------------------------------------------*
       3000-FINALIZE.
           CLOSE INPUT-FILE
           CLOSE CLEAN-FILE
           CLOSE ERROR-FILE
           
           PERFORM 9000-PRINT-STATISTICS.
       
      *----------------------------------------------------------------*
      * LOG ERROR TO ERROR FILE                                        *
      *----------------------------------------------------------------*
       8000-LOG-ERROR.
           MOVE FUNCTION CURRENT-DATE TO ERR-TIMESTAMP
           MOVE WS-RECORDS-READ TO ERR-RECORD-NUMBER
           MOVE ERROR-CODE TO ERR-ERROR-CODE
           MOVE ERROR-MESSAGE TO ERR-ERROR-MESSAGE
           MOVE INPUT-RECORD(1:40) TO ERR-INPUT-DATA
           
           WRITE ERROR-RECORD.
       
      *----------------------------------------------------------------*
      * PRINT PROCESSING STATISTICS                                    *
      *----------------------------------------------------------------*
       9000-PRINT-STATISTICS.
           DISPLAY '========================================='
           DISPLAY 'DATA VALIDATION STATISTICS'
           DISPLAY '========================================='
           DISPLAY 'RECORDS READ:     ' WS-RECORDS-READ
           DISPLAY 'RECORDS CLEAN:    ' WS-RECORDS-CLEAN
           DISPLAY 'RECORDS WITH ERRORS: ' WS-RECORDS-ERROR
           
           COMPUTE WS-NUMERIC-TEST = 
                   (WS-RECORDS-CLEAN * 100) / WS-RECORDS-READ
           DISPLAY 'CLEAN RATE:       ' WS-NUMERIC-TEST '%'
           DISPLAY '========================================='.
