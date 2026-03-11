      ******************************************************************
      * SALESREC.CPY - SALES TRANSACTION RECORD LAYOUT                *
      * LENGTH: 80 BYTES                                              *
      ******************************************************************
       01  SALES-RECORD.
           05  SR-SALESPERSON-ID        PIC 9(6).
           05  SR-SALESPERSON-NAME      PIC X(20).
           05  SR-SALE-DATE             PIC X(10).
           05  SR-PRODUCT-CODE          PIC X(10).
           05  SR-QUANTITY              PIC 9(6).
           05  SR-SALE-AMOUNT           PIC 9(8)V99.
           05  SR-REGION                PIC X(10).
           05  SR-FILLER                PIC X(8).
