      ******************************************************************
      * ERRORREC.CPY - ERROR RECORD LAYOUT                            *
      * LENGTH: 150 BYTES                                             *
      ******************************************************************
       01  ERROR-RECORD.
           05  ERR-TIMESTAMP            PIC X(26).
           05  ERR-RECORD-NUMBER        PIC 9(8).
           05  ERR-ERROR-CODE           PIC X(10).
           05  ERR-ERROR-MESSAGE        PIC X(60).
           05  ERR-INPUT-DATA           PIC X(40).
           05  FILLER                   PIC X(6).
