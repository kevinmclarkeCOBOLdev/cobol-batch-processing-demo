      ******************************************************************
      * CUSTREC.CPY - CUSTOMER MASTER RECORD LAYOUT                   *
      * LENGTH: 200 BYTES                                             *
      ******************************************************************
       01  CUSTOMER-RECORD.
           05  CUST-ID                  PIC 9(6).
           05  CUST-NAME                PIC X(30).
           05  CUST-ADDRESS             PIC X(30).
           05  CUST-CITY                PIC X(20).
           05  CUST-STATE               PIC X(2).
           05  CUST-ZIP                 PIC X(10).
           05  CUST-EMAIL               PIC X(50).
           05  CUST-PHONE               PIC X(15).
           05  CUST-CREDIT-LIMIT        PIC 9(8)V99.
           05  CUST-BALANCE             PIC 9(8)V99.
           05  CUST-LAST-ORDER-DATE     PIC X(10).
           05  CUST-STATUS              PIC X(1).
               88  CUST-ACTIVE                      VALUE 'A'.
               88  CUST-INACTIVE                    VALUE 'I'.
               88  CUST-SUSPENDED                   VALUE 'S'.
           05  FILLER                   PIC X(6).
