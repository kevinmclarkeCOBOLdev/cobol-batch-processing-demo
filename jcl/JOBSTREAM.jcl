//JOBSTREAM JOB (ACCT),'COMPLETE JOB STREAM',CLASS=A,
//         MSGCLASS=X,NOTIFY=&SYSUID
//*
//* JOB:     COMPLETE BATCH JOB STREAM
//* PURPOSE: DEMONSTRATES MULTI-STEP BATCH PROCESSING
//*          1. VALIDATE INCOMING DATA
//*          2. UPDATE CUSTOMER MASTER
//*          3. GENERATE SALES REPORT
//*
//*-------------------------------------------------------------------*
//* STEP 1: DATA VALIDATION                                           *
//*-------------------------------------------------------------------*
//VALIDATE EXEC PGM=DATAVAL
//STEPLIB  DD   DSN=USER.COBOL.LOADLIB,DISP=SHR
//         DD   DSN=CEE.SCEERUN,DISP=SHR
//DATAIN   DD   DSN=USER.SALES.RAW,DISP=SHR
//DATAOUT  DD   DSN=&&CLEAN,DISP=(NEW,PASS),
//              SPACE=(TRK,(50,10)),
//              DCB=(RECFM=FB,LRECL=80,BLKSIZE=8000)
//ERROROUT DD   DSN=USER.SALES.ERRORS,
//              DISP=(NEW,CATLG,DELETE),
//              SPACE=(TRK,(10,5),RLSE),
//              DCB=(RECFM=FB,LRECL=150,BLKSIZE=15000)
//SYSOUT   DD   SYSOUT=*
//SYSPRINT DD   SYSOUT=*
//SYSUDUMP DD   SYSOUT=*
//*
//*-------------------------------------------------------------------*
//* STEP 2: SORT VALIDATED DATA BY SALESPERSON AND REGION             *
//*-------------------------------------------------------------------*
//SORT     EXEC PGM=SORT,COND=(0,NE,VALIDATE)
//SORTIN   DD   DSN=&&CLEAN,DISP=(OLD,DELETE)
//SORTOUT  DD   DSN=&&SORTED,DISP=(NEW,PASS),
//              SPACE=(TRK,(50,10)),
//              DCB=(RECFM=FB,LRECL=80,BLKSIZE=8000)
//SYSOUT   DD   SYSOUT=*
//SYSIN    DD   *
  SORT FIELDS=(63,10,CH,A,1,6,CH,A)
  END
/*
//*
//*-------------------------------------------------------------------*
//* STEP 3: GENERATE SALES REPORT                                     *
//*-------------------------------------------------------------------*
//SALESRPT EXEC PGM=SALESRPT,COND=(0,NE,SORT)
//STEPLIB  DD   DSN=USER.COBOL.LOADLIB,DISP=SHR
//         DD   DSN=CEE.SCEERUN,DISP=SHR
//SALESIN  DD   DSN=&&SORTED,DISP=(OLD,DELETE)
//RPTOUT   DD   DSN=USER.SALES.REPORT,
//              DISP=(NEW,CATLG,DELETE),
//              SPACE=(TRK,(50,10),RLSE),
//              DCB=(RECFM=FBA,LRECL=132,BLKSIZE=13200)
//SYSOUT   DD   SYSOUT=*
//SYSPRINT DD   SYSOUT=*
//SYSUDUMP DD   SYSOUT=*
//*
//*-------------------------------------------------------------------*
//* STEP 4: BACKUP CUSTOMER MASTER                                    *
//*-------------------------------------------------------------------*
//BACKUP   EXEC PGM=IEBGENER,COND=(0,NE,SALESRPT)
//SYSPRINT DD   SYSOUT=*
//SYSUT1   DD   DSN=USER.CUSTOMER.MASTER,DISP=SHR
//SYSUT2   DD   DSN=USER.CUSTOMER.BACKUP,
//              DISP=(NEW,CATLG,DELETE),
//              SPACE=(TRK,(100,10),RLSE),
//              DCB=(RECFM=FB,LRECL=200,BLKSIZE=20000)
//SYSIN    DD   DUMMY
//*
//*-------------------------------------------------------------------*
//* STEP 5: UPDATE CUSTOMER MASTER                                    *
//*-------------------------------------------------------------------*
//CUSTUPD  EXEC PGM=CUSTUPD,COND=(0,NE,BACKUP)
//STEPLIB  DD   DSN=USER.COBOL.LOADLIB,DISP=SHR
//         DD   DSN=CEE.SCEERUN,DISP=SHR
//CUSTMIN  DD   DSN=USER.CUSTOMER.MASTER,DISP=SHR
//TRANSIN  DD   DSN=USER.CUSTOMER.TRANS,DISP=SHR
//CUSTMOUT DD   DSN=USER.CUSTOMER.MASTER.NEW,
//              DISP=(NEW,CATLG,DELETE),
//              SPACE=(TRK,(100,10),RLSE),
//              DCB=(RECFM=FB,LRECL=200,BLKSIZE=20000)
//RPTUPDOUT DD  DSN=USER.CUSTOMER.REPORT,
//              DISP=(NEW,CATLG,DELETE),
//              SPACE=(TRK,(10,5),RLSE),
//              DCB=(RECFM=FBA,LRECL=132,BLKSIZE=13200)
//ERROROUT DD   DSN=USER.CUSTOMER.ERRORS,
//              DISP=(NEW,CATLG,DELETE),
//              SPACE=(TRK,(10,5),RLSE),
//              DCB=(RECFM=FB,LRECL=150,BLKSIZE=15000)
//SYSOUT   DD   SYSOUT=*
//SYSPRINT DD   SYSOUT=*
//SYSUDUMP DD   SYSOUT=*
//*
//*-------------------------------------------------------------------*
//* STEP 6: REPLACE OLD MASTER WITH NEW                               *
//*-------------------------------------------------------------------*
//REPLACE  EXEC PGM=IEBGENER,COND=(0,NE,CUSTUPD)
//SYSPRINT DD   SYSOUT=*
//SYSUT1   DD   DSN=USER.CUSTOMER.MASTER.NEW,DISP=SHR
//SYSUT2   DD   DSN=USER.CUSTOMER.MASTER,DISP=OLD
//SYSIN    DD   DUMMY
//*
//*-------------------------------------------------------------------*
//* STEP 7: CLEANUP - DELETE TEMPORARY FILES                          *
//*-------------------------------------------------------------------*
//CLEANUP  EXEC PGM=IEFBR14,COND=(0,NE,REPLACE)
//DELETE1  DD   DSN=USER.CUSTOMER.MASTER.NEW,
//              DISP=(OLD,DELETE,DELETE)
