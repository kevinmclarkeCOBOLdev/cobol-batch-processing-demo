       IDENTIFICATION DIVISION.
       PROGRAM-ID. SALESRPT.
       AUTHOR. PORTFOLIO DEMO.
      ******************************************************************
      * PROGRAM NAME: SALESRPT                                         *
      * DESCRIPTION:  SALES REPORT WITH CONTROL BREAKS                 *
      *               PRODUCES FORMATTED REPORT WITH:                  *
      *               - SALESPERSON TOTALS                             *
      *               - REGIONAL SUBTOTALS                             *
      *               - GRAND TOTALS                                   *
      * INPUT:        SALES TRANSACTION FILE (80-BYTE RECORDS)         *
      * OUTPUT:       FORMATTED SALES REPORT (132-BYTE PRINT RECORDS)  *
      ******************************************************************
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SALES-FILE ASSIGN TO SALESIN
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE IS SEQUENTIAL
                  FILE STATUS IS WS-SALES-STATUS.
           
           SELECT REPORT-FILE ASSIGN TO RPTOUT
                  ORGANIZATION IS SEQUENTIAL
                  ACCESS MODE IS SEQUENTIAL
                  FILE STATUS IS WS-REPORT-STATUS.
       
       DATA DIVISION.
       FILE SECTION.
       
       FD  SALES-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
       COPY SALESREC.
       
       FD  REPORT-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
       01  REPORT-LINE                  PIC X(132).
       
       WORKING-STORAGE SECTION.
       
       01  WS-FILE-STATUS.
           05  WS-SALES-STATUS          PIC XX.
           05  WS-REPORT-STATUS         PIC XX.
       
       01  WS-FLAGS.
           05  WS-END-OF-FILE-SW        PIC X VALUE 'N'.
               88  END-OF-FILE                  VALUE 'Y'.
           05  WS-FIRST-RECORD-SW       PIC X VALUE 'Y'.
               88  FIRST-RECORD                 VALUE 'Y'.
       
       01  WS-COUNTERS.
           05  WS-RECORD-COUNT          PIC 9(7) VALUE ZERO.
           05  WS-PAGE-COUNT            PIC 9(4) VALUE ZERO.
           05  WS-LINE-COUNT            PIC 9(3) VALUE 99.
       
       01  WS-ACCUMULATORS.
           05  WS-SALESPERSON-TOTAL     PIC 9(9)V99 VALUE ZERO.
           05  WS-REGION-TOTAL          PIC 9(9)V99 VALUE ZERO.
           05  WS-GRAND-TOTAL           PIC 9(9)V99 VALUE ZERO.
       
       01  WS-CONTROL-FIELDS.
           05  WS-PREV-SALESPERSON-ID   PIC 9(6) VALUE ZERO.
           05  WS-PREV-REGION           PIC X(10) VALUE SPACES.
       
       01  WS-CURRENT-DATE.
           05  WS-CURR-YEAR             PIC 9(4).
           05  WS-CURR-MONTH            PIC 9(2).
           05  WS-CURR-DAY              PIC 9(2).
       
       01  WS-FORMATTED-DATE            PIC X(10).
       
       01  WS-DISPLAY-FIELDS.
           05  WS-AMOUNT-DISPLAY        PIC $$$,$$$,$$9.99.
           05  WS-QTY-DISPLAY           PIC ZZZ,ZZ9.
       
      *----------------------------------------------------------------*
      * REPORT HEADER LINES                                            *
      *----------------------------------------------------------------*
       01  HDR-LINE-1.
           05  FILLER                   PIC X(40) VALUE
               'SALES REPORT - BY SALESPERSON'.
           05  FILLER                   PIC X(52) VALUE SPACES.
           05  FILLER                   PIC X(6) VALUE 'PAGE: '.
           05  HDR-PAGE-NO              PIC ZZZ9.
           05  FILLER                   PIC X(30) VALUE SPACES.
       
       01  HDR-LINE-2.
           05  FILLER                   PIC X(10) VALUE 'RUN DATE: '.
           05  HDR-RUN-DATE             PIC X(10).
           05  FILLER                   PIC X(112) VALUE SPACES.
       
       01  HDR-LINE-3.
           05  FILLER                   PIC X(132) VALUE ALL '-'.
       
       01  HDR-LINE-4.
           05  FILLER                   PIC X(4) VALUE SPACES.
           05  FILLER                   PIC X(10) VALUE 'DATE'.
           05  FILLER                   PIC X(8) VALUE SPACES.
           05  FILLER                   PIC X(10) VALUE 'PRODUCT'.
           05  FILLER                   PIC X(6) VALUE SPACES.
           05  FILLER                   PIC X(10) VALUE 'QUANTITY'.
           05  FILLER                   PIC X(6) VALUE SPACES.
           05  FILLER                   PIC X(10) VALUE 'AMOUNT'.
           05  FILLER                   PIC X(68) VALUE SPACES.
       
      *----------------------------------------------------------------*
      * DETAIL LINES                                                   *
      *----------------------------------------------------------------*
       01  DTL-SALESPERSON-LINE.
           05  FILLER                   PIC X(13) VALUE 'SALESPERSON: '.
           05  DTL-SALESPERSON-NAME     PIC X(20).
           05  FILLER                   PIC X(99) VALUE SPACES.
       
       01  DTL-REGION-LINE.
           05  FILLER                   PIC X(10) VALUE '  REGION: '.
           05  DTL-REGION-NAME          PIC X(10).
           05  FILLER                   PIC X(112) VALUE SPACES.
       
       01  DTL-DETAIL-LINE.
           05  FILLER                   PIC X(4) VALUE SPACES.
           05  DTL-DATE                 PIC X(10).
           05  FILLER                   PIC X(4) VALUE SPACES.
           05  DTL-PRODUCT              PIC X(10).
           05  FILLER                   PIC X(4) VALUE SPACES.
           05  DTL-QUANTITY             PIC ZZZ,ZZ9.
           05  FILLER                   PIC X(2) VALUE SPACES.
           05  DTL-AMOUNT               PIC $$$,$$$,$$9.99.
           05  FILLER                   PIC X(71) VALUE SPACES.
       
      *----------------------------------------------------------------*
      * TOTAL LINES                                                    *
      *----------------------------------------------------------------*
       01  TOT-SALESPERSON-LINE.
           05  FILLER                   PIC X(46) VALUE SPACES.
           05  FILLER                   PIC X(14) VALUE ALL '-'.
           05  FILLER                   PIC X(72) VALUE SPACES.
       
       01  TOT-SALESPERSON-AMT.
           05  FILLER                   PIC X(4) VALUE SPACES.
           05  FILLER                   PIC X(20) VALUE 
               'SALESPERSON TOTAL: '.
           05  FILLER                   PIC X(22) VALUE SPACES.
           05  TOT-SP-AMOUNT            PIC $$$,$$$,$$9.99.
           05  FILLER                   PIC X(72) VALUE SPACES.
       
       01  TOT-REGION-LINE.
           05  FILLER                   PIC X(132) VALUE ALL '='.
       
       01  TOT-REGION-AMT.
           05  TOT-REGION-NAME          PIC X(10).
           05  FILLER                   PIC X(18) VALUE 
               ' REGIONAL TOTAL: '.
           05  FILLER                   PIC X(18) VALUE SPACES.
           05  TOT-REG-AMOUNT           PIC $$$,$$$,$$9.99.
           05  FILLER                   PIC X(72) VALUE SPACES.
       
       01  TOT-GRAND-LINE.
           05  FILLER                   PIC X(132) VALUE ALL '*'.
       
       01  TOT-GRAND-AMT.
           05  FILLER                   PIC X(14) VALUE 'GRAND TOTAL: '.
           05  FILLER                   PIC X(32) VALUE SPACES.
           05  TOT-GRAND-AMOUNT         PIC $$$,$$$,$$9.99.
           05  FILLER                   PIC X(72) VALUE SPACES.
       
       PROCEDURE DIVISION.
       
      *----------------------------------------------------------------*
      * MAIN PROCESSING LOGIC                                          *
      *----------------------------------------------------------------*
       0000-MAIN-PROCESS.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-PROCESS-SALES UNTIL END-OF-FILE
           PERFORM 3000-FINALIZE
           STOP RUN.
       
      *----------------------------------------------------------------*
      * INITIALIZATION                                                 *
      *----------------------------------------------------------------*
       1000-INITIALIZE.
           OPEN INPUT SALES-FILE
           OPEN OUTPUT REPORT-FILE
           
           MOVE FUNCTION CURRENT-DATE(1:8) TO WS-CURRENT-DATE
           STRING WS-CURR-YEAR '-' WS-CURR-MONTH '-' WS-CURR-DAY
                  DELIMITED BY SIZE INTO WS-FORMATTED-DATE
           END-STRING
           
           PERFORM 1100-READ-SALES-RECORD
           
           IF NOT END-OF-FILE
               MOVE SR-SALESPERSON-ID TO WS-PREV-SALESPERSON-ID
               MOVE SR-REGION TO WS-PREV-REGION
               PERFORM 8000-WRITE-HEADERS
           END-IF.
       
       1100-READ-SALES-RECORD.
           READ SALES-FILE
               AT END
                   MOVE 'Y' TO WS-END-OF-FILE-SW
               NOT AT END
                   ADD 1 TO WS-RECORD-COUNT
           END-READ.
       
      *----------------------------------------------------------------*
      * PROCESS SALES RECORDS                                          *
      *----------------------------------------------------------------*
       2000-PROCESS-SALES.
           IF SR-REGION NOT = WS-PREV-REGION
               PERFORM 2100-REGION-BREAK
           END-IF
           
           IF SR-SALESPERSON-ID NOT = WS-PREV-SALESPERSON-ID
               PERFORM 2200-SALESPERSON-BREAK
           END-IF
           
           PERFORM 2300-PRINT-DETAIL
           PERFORM 1100-READ-SALES-RECORD.
       
       2100-REGION-BREAK.
           IF NOT FIRST-RECORD
               PERFORM 2200-SALESPERSON-BREAK
               PERFORM 7200-PRINT-REGION-TOTAL
               MOVE ZERO TO WS-REGION-TOTAL
           END-IF
           MOVE SR-REGION TO WS-PREV-REGION.
       
       2200-SALESPERSON-BREAK.
           IF NOT FIRST-RECORD
               PERFORM 7100-PRINT-SALESPERSON-TOTAL
               MOVE ZERO TO WS-SALESPERSON-TOTAL
           END-IF
           
           MOVE SR-SALESPERSON-ID TO WS-PREV-SALESPERSON-ID
           PERFORM 7000-PRINT-SALESPERSON-HEADER
           MOVE 'N' TO WS-FIRST-RECORD-SW.
       
       2300-PRINT-DETAIL.
           IF WS-LINE-COUNT > 55
               PERFORM 8000-WRITE-HEADERS
           END-IF
           
           MOVE SR-SALE-DATE TO DTL-DATE
           MOVE SR-PRODUCT-CODE TO DTL-PRODUCT
           MOVE SR-QUANTITY TO DTL-QUANTITY
           MOVE SR-SALE-AMOUNT TO DTL-AMOUNT
           
           WRITE REPORT-LINE FROM DTL-DETAIL-LINE
           ADD 1 TO WS-LINE-COUNT
           
           ADD SR-SALE-AMOUNT TO WS-SALESPERSON-TOTAL
           ADD SR-SALE-AMOUNT TO WS-REGION-TOTAL
           ADD SR-SALE-AMOUNT TO WS-GRAND-TOTAL.
       
      *----------------------------------------------------------------*
      * FINALIZATION                                                   *
      *----------------------------------------------------------------*
       3000-FINALIZE.
           IF NOT FIRST-RECORD
               PERFORM 2200-SALESPERSON-BREAK
               PERFORM 7200-PRINT-REGION-TOTAL
               PERFORM 7300-PRINT-GRAND-TOTAL
           END-IF
           
           CLOSE SALES-FILE
           CLOSE REPORT-FILE
           
           DISPLAY 'SALESRPT COMPLETED SUCCESSFULLY'
           DISPLAY 'RECORDS PROCESSED: ' WS-RECORD-COUNT
           DISPLAY 'PAGES PRINTED: ' WS-PAGE-COUNT.
       
      *----------------------------------------------------------------*
      * PRINT SALESPERSON HEADER                                       *
      *----------------------------------------------------------------*
       7000-PRINT-SALESPERSON-HEADER.
           WRITE REPORT-LINE FROM DTL-SALESPERSON-LINE
                  AFTER ADVANCING 2 LINES
           MOVE SR-SALESPERSON-NAME TO DTL-SALESPERSON-NAME
           
           WRITE REPORT-LINE FROM DTL-REGION-LINE
                  AFTER ADVANCING 1 LINE
           MOVE SR-REGION TO DTL-REGION-NAME
           
           WRITE REPORT-LINE FROM HDR-LINE-4
                  AFTER ADVANCING 2 LINES
           
           ADD 5 TO WS-LINE-COUNT.
       
      *----------------------------------------------------------------*
      * PRINT SALESPERSON TOTAL                                        *
      *----------------------------------------------------------------*
       7100-PRINT-SALESPERSON-TOTAL.
           WRITE REPORT-LINE FROM TOT-SALESPERSON-LINE
                  AFTER ADVANCING 1 LINE
           
           MOVE WS-SALESPERSON-TOTAL TO TOT-SP-AMOUNT
           WRITE REPORT-LINE FROM TOT-SALESPERSON-AMT
                  AFTER ADVANCING 1 LINE
           
           ADD 2 TO WS-LINE-COUNT.
       
      *----------------------------------------------------------------*
      * PRINT REGION TOTAL                                             *
      *----------------------------------------------------------------*
       7200-PRINT-REGION-TOTAL.
           WRITE REPORT-LINE FROM TOT-REGION-LINE
                  AFTER ADVANCING 2 LINES
           
           MOVE WS-PREV-REGION TO TOT-REGION-NAME
           MOVE WS-REGION-TOTAL TO TOT-REG-AMOUNT
           WRITE REPORT-LINE FROM TOT-REGION-AMT
                  AFTER ADVANCING 1 LINE
           
           WRITE REPORT-LINE FROM TOT-REGION-LINE
                  AFTER ADVANCING 1 LINE
           
           ADD 4 TO WS-LINE-COUNT.
       
      *----------------------------------------------------------------*
      * PRINT GRAND TOTAL                                              *
      *----------------------------------------------------------------*
       7300-PRINT-GRAND-TOTAL.
           WRITE REPORT-LINE FROM TOT-GRAND-LINE
                  AFTER ADVANCING 3 LINES
           
           MOVE WS-GRAND-TOTAL TO TOT-GRAND-AMOUNT
           WRITE REPORT-LINE FROM TOT-GRAND-AMT
                  AFTER ADVANCING 1 LINE
           
           WRITE REPORT-LINE FROM TOT-GRAND-LINE
                  AFTER ADVANCING 1 LINE.
       
      *----------------------------------------------------------------*
      * WRITE REPORT HEADERS                                           *
      *----------------------------------------------------------------*
       8000-WRITE-HEADERS.
           ADD 1 TO WS-PAGE-COUNT
           MOVE WS-PAGE-COUNT TO HDR-PAGE-NO
           MOVE WS-FORMATTED-DATE TO HDR-RUN-DATE
           
           WRITE REPORT-LINE FROM HDR-LINE-1
                  AFTER ADVANCING PAGE
           
           WRITE REPORT-LINE FROM HDR-LINE-2
                  AFTER ADVANCING 1 LINE
           
           WRITE REPORT-LINE FROM HDR-LINE-3
                  AFTER ADVANCING 1 LINE
           
           MOVE 3 TO WS-LINE-COUNT.
