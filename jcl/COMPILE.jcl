//COMPILE  JOB  (ACCT),'COMPILE COBOL PROGRAMS',CLASS=A,
//         MSGCLASS=X,NOTIFY=&SYSUID
//*
//* JOB:     COMPILE ALL COBOL PROGRAMS
//* PURPOSE: COMPILE SALES REPORT, CUSTOMER UPDATE, AND VALIDATION
//*
//*-------------------------------------------------------------------*
//* STEP 1: COMPILE SALESRPT                                          *
//*-------------------------------------------------------------------*
//CMPSALES EXEC PGM=IGYCRCTL,
//         PARM='LIB,OBJECT,RENT,APOST,NODYNAM'
//STEPLIB  DD   DSN=IGY.V6R3M0.SIGYCOMP,DISP=SHR
//SYSIN    DD   DSN=USER.COBOL.SOURCE(SALESRPT),DISP=SHR
//SYSLIB   DD   DSN=USER.COBOL.COPYLIB,DISP=SHR
//SYSLIN   DD   DSN=&&SALESOBJ,DISP=(NEW,PASS),
//              SPACE=(CYL,(1,1)),
//              DCB=(BLKSIZE=3200,LRECL=80,RECFM=FB)
//SYSPRINT DD   SYSOUT=*
//SYSUT1   DD   SPACE=(CYL,(1,1))
//SYSUT2   DD   SPACE=(CYL,(1,1))
//SYSUT3   DD   SPACE=(CYL,(1,1))
//SYSUT4   DD   SPACE=(CYL,(1,1))
//SYSUT5   DD   SPACE=(CYL,(1,1))
//SYSUT6   DD   SPACE=(CYL,(1,1))
//SYSUT7   DD   SPACE=(CYL,(1,1))
//*
//*-------------------------------------------------------------------*
//* STEP 2: LINK-EDIT SALESRPT                                        *
//*-------------------------------------------------------------------*
//LKEDSALE EXEC PGM=IEWL,PARM='LIST,XREF,LET',
//         COND=(0,NE,CMPSALES)
//SYSLIB   DD   DSN=CEE.SCEELKED,DISP=SHR
//SYSLIN   DD   DSN=&&SALESOBJ,DISP=(OLD,DELETE)
//SYSLMOD  DD   DSN=USER.COBOL.LOADLIB(SALESRPT),DISP=SHR
//SYSPRINT DD   SYSOUT=*
//SYSUT1   DD   SPACE=(CYL,(1,1))
//*
//*-------------------------------------------------------------------*
//* STEP 3: COMPILE CUSTUPD                                           *
//*-------------------------------------------------------------------*
//CMPCUST  EXEC PGM=IGYCRCTL,
//         PARM='LIB,OBJECT,RENT,APOST,NODYNAM'
//STEPLIB  DD   DSN=IGY.V6R3M0.SIGYCOMP,DISP=SHR
//SYSIN    DD   DSN=USER.COBOL.SOURCE(CUSTUPD),DISP=SHR
//SYSLIB   DD   DSN=USER.COBOL.COPYLIB,DISP=SHR
//SYSLIN   DD   DSN=&&CUSTOBJ,DISP=(NEW,PASS),
//              SPACE=(CYL,(1,1)),
//              DCB=(BLKSIZE=3200,LRECL=80,RECFM=FB)
//SYSPRINT DD   SYSOUT=*
//SYSUT1   DD   SPACE=(CYL,(1,1))
//SYSUT2   DD   SPACE=(CYL,(1,1))
//SYSUT3   DD   SPACE=(CYL,(1,1))
//SYSUT4   DD   SPACE=(CYL,(1,1))
//SYSUT5   DD   SPACE=(CYL,(1,1))
//SYSUT6   DD   SPACE=(CYL,(1,1))
//SYSUT7   DD   SPACE=(CYL,(1,1))
//*
//*-------------------------------------------------------------------*
//* STEP 4: LINK-EDIT CUSTUPD                                         *
//*-------------------------------------------------------------------*
//LKEDCUST EXEC PGM=IEWL,PARM='LIST,XREF,LET',
//         COND=(0,NE,CMPCUST)
//SYSLIB   DD   DSN=CEE.SCEELKED,DISP=SHR
//SYSLIN   DD   DSN=&&CUSTOBJ,DISP=(OLD,DELETE)
//SYSLMOD  DD   DSN=USER.COBOL.LOADLIB(CUSTUPD),DISP=SHR
//SYSPRINT DD   SYSOUT=*
//SYSUT1   DD   SPACE=(CYL,(1,1))
//*
//*-------------------------------------------------------------------*
//* STEP 5: COMPILE DATAVAL                                           *
//*-------------------------------------------------------------------*
//CMPVAL   EXEC PGM=IGYCRCTL,
//         PARM='LIB,OBJECT,RENT,APOST,NODYNAM'
//STEPLIB  DD   DSN=IGY.V6R3M0.SIGYCOMP,DISP=SHR
//SYSIN    DD   DSN=USER.COBOL.SOURCE(DATAVAL),DISP=SHR
//SYSLIB   DD   DSN=USER.COBOL.COPYLIB,DISP=SHR
//SYSLIN   DD   DSN=&&VALOBJ,DISP=(NEW,PASS),
//              SPACE=(CYL,(1,1)),
//              DCB=(BLKSIZE=3200,LRECL=80,RECFM=FB)
//SYSPRINT DD   SYSOUT=*
//SYSUT1   DD   SPACE=(CYL,(1,1))
//SYSUT2   DD   SPACE=(CYL,(1,1))
//SYSUT3   DD   SPACE=(CYL,(1,1))
//SYSUT4   DD   SPACE=(CYL,(1,1))
//SYSUT5   DD   SPACE=(CYL,(1,1))
//SYSUT6   DD   SPACE=(CYL,(1,1))
//SYSUT7   DD   SPACE=(CYL,(1,1))
//*
//*-------------------------------------------------------------------*
//* STEP 6: LINK-EDIT DATAVAL                                         *
//*-------------------------------------------------------------------*
//LKEDVAL  EXEC PGM=IEWL,PARM='LIST,XREF,LET',
//         COND=(0,NE,CMPVAL)
//SYSLIB   DD   DSN=CEE.SCEELKED,DISP=SHR
//SYSLIN   DD   DSN=&&VALOBJ,DISP=(OLD,DELETE)
//SYSLMOD  DD   DSN=USER.COBOL.LOADLIB(DATAVAL),DISP=SHR
//SYSPRINT DD   SYSOUT=*
//SYSUT1   DD   SPACE=(CYL,(1,1))
