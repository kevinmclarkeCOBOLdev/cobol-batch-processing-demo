# Setup Instructions

This guide walks you through setting up and running the COBOL Batch Processing Demo.

## Prerequisites

### System Requirements
- IBM z/OS operating system (version 2.1 or higher recommended)
- Enterprise COBOL compiler (V4.2 or higher)
- TSO/ISPF access or z/OS Unix System Services (USS)
- Sufficient storage allocation authority

### User Requirements
- TSO user ID with batch job submission privileges
- Authority to allocate datasets
- Access to COBOL compiler and runtime libraries

## Step 1: Allocate Datasets

### 1.1 Create PDS for Source Programs
```
Dataset: USER.COBOL.SOURCE
Type: PDS (Partitioned Dataset)
Record Format: FB
Logical Record Length: 80
Block Size: 3200
Directory Blocks: 10
Space: (CYL,(5,1,10))
```

TSO Command:
```
ALLOC DA('USER.COBOL.SOURCE') NEW CATALOG +
  DSORG(PO) RECFM(F,B) LRECL(80) BLKSIZE(3200) +
  DIR(10) SPACE(5,1) CYL
```

### 1.2 Create PDS for Copybooks
```
Dataset: USER.COBOL.COPYLIB
Type: PDS
Record Format: FB
Logical Record Length: 80
Block Size: 3200
Directory Blocks: 5
Space: (CYL,(2,1,5))
```

### 1.3 Create PDS for Load Modules
```
Dataset: USER.COBOL.LOADLIB
Type: PDSE (recommended) or PDS
Record Format: U
Block Size: 32760
Directory Blocks: 10
Space: (CYL,(5,1,10))
```

TSO Command:
```
ALLOC DA('USER.COBOL.LOADLIB') NEW CATALOG +
  DSNTYPE(LIBRARY) DSORG(PO) RECFM(U) BLKSIZE(32760) +
  DIR(10) SPACE(5,1) CYL
```

### 1.4 Create JCL Library
```
Dataset: USER.COBOL.JCLLIB
Type: PDS
Record Format: FB
Logical Record Length: 80
Block Size: 3200
Directory Blocks: 10
Space: (CYL,(3,1,10))
```

### 1.5 Create Data Files

**Sales Transaction File:**
```
Dataset: USER.SALES.TRANS
Type: PS (Physical Sequential)
Record Format: FB
Logical Record Length: 80
Block Size: 8000
Space: (TRK,(10,5),RLSE)
```

**Customer Master File:**
```
Dataset: USER.CUSTOMER.MASTER
Type: PS
Record Format: FB
Logical Record Length: 200
Block Size: 20000
Space: (TRK,(50,10),RLSE)
```

## Step 2: Upload Source Code

### 2.1 Upload COBOL Programs

Using TSO/ISPF:
1. Open ISPF (option 3.4)
2. Navigate to USER.COBOL.SOURCE
3. Upload each .cbl file as a member:
   - SALESRPT
   - CUSTUPD
   - DATAVAL

Or use FTP from workstation:
```bash
ftp zos.example.com
ascii
cd 'USER.COBOL.SOURCE'
put SALESRPT.cbl SALESRPT
put CUSTUPD.cbl CUSTUPD
put DATAVAL.cbl DATAVAL
quit
```

### 2.2 Upload Copybooks

Upload to USER.COBOL.COPYLIB:
- SALESREC (from SALESREC.cpy)
- CUSTREC (from CUSTREC.cpy)
- ERRORREC (from ERRORREC.cpy)

### 2.3 Upload JCL

Upload to USER.COBOL.JCLLIB:
- COMPILE
- SALESRPT
- CUSTUPD
- DATAVAL
- JOBSTREAM

### 2.4 Upload Sample Data

Upload to respective datasets:
- SALES.txt → USER.SALES.TRANS
- CUSTOMER.txt → USER.CUSTOMER.MASTER

## Step 3: Customize JCL

Edit all JCL members and replace:
- `USER` with your TSO user ID
- `IGY.V6R3M0.SIGYCOMP` with your COBOL compiler library
- `CEE.SCEELKED` with your Language Environment library
- `CEE.SCEERUN` with your LE runtime library

### Find Your Library Names

Check your site's standards or use:
```
TSO ISRDDN (ISPF 3.4)
```

Look for:
- COBOL compiler: Usually IGY*.SIGYCOMP
- LE link-edit: Usually CEE.SCEELKED
- LE runtime: Usually CEE.SCEERUN

## Step 4: Compile Programs

### 4.1 Submit Compile Job

1. Edit USER.COBOL.JCLLIB(COMPILE)
2. Verify all dataset names are correct
3. Submit the job: SUB command or SUBMIT option
4. Check job output for RC=0000

### 4.2 Verify Compilation

Check sysout for each compile step:
- Look for "RETURN CODE = 0000" or "RC=0000"
- Verify load modules created:
  ```
  TSO LISTDS 'USER.COBOL.LOADLIB' MEMBERS
  ```

Expected members:
- SALESRPT
- CUSTUPD
- DATAVAL

## Step 5: Test Individual Programs

### 5.1 Test Sales Report

```
Submit: USER.COBOL.JCLLIB(SALESRPT)
Expected RC: 0000
Output: Sales report in SYSOUT
Check: Record count in job log
```

### 5.2 Test Data Validation

```
Submit: USER.COBOL.JCLLIB(DATAVAL)
Expected RC: 0000
Output: Clean data file + error report
Check: Validation statistics
```

### 5.3 Test Customer Update

```
Submit: USER.COBOL.JCLLIB(CUSTUPD)
Expected RC: 0000
Output: Updated master + summary
Check: Update counts
```

## Step 6: Run Complete Job Stream

```
Submit: USER.COBOL.JCLLIB(JOBSTREAM)
```

This runs all programs in sequence:
1. Data validation
2. Sort by region/salesperson
3. Sales report generation
4. Customer master backup
5. Customer master update
6. Replace old master
7. Cleanup temporary files

## Troubleshooting

### Common Issues

**Issue: JCL Error - Dataset Not Found**
- Solution: Verify dataset name spelling
- Check: Use TSO LISTDS to verify existence

**Issue: Compilation Fails**
- Solution: Check SYSPRINT for error messages
- Common: Missing copybook - verify SYSLIB DD

**Issue: ABEND S0C7 (Data Exception)**
- Solution: Check input data format
- Verify: Numeric fields are properly formatted

**Issue: ABEND S013 (File Not Found)**
- Solution: Verify all DD statements point to existing datasets
- Check: DISP parameter is correct

**Issue: Program Runs But No Output**
- Solution: Check SYSOUT class
- Try: SYSOUT=* to route to held output queue

### Checking Job Status

View job output:
```
ISPF Option: 3.8 (Spool Display and Search)
Or: ST (Status) command from command line
Or: =SDSF in ISPF
```

### Verifying Datasets

List dataset contents:
```
ISPF: 3.4 then browse dataset
Or TSO: LISTDS 'dataset.name' HISTORY
```

### Getting Help

Check system logs:
```
ISPF: 1 (SDSF) then select job
View each step's output
Look for ABEND codes, return codes
```

## Performance Tuning

### Optimize Block Sizes

For better performance, use optimal block sizes:
- FB files: Half-track blocking (e.g., 27920 for 3390)
- Calculate: Use ISPF 3.7 (Dataset utility)

### Space Allocation

- Use RLSE (release unused space)
- Allocate enough primary space to avoid extents
- Monitor space usage: LISTDS with HISTORY

## Next Steps

After successful setup:
1. Review generated reports
2. Examine error files
3. Modify programs for your requirements
4. Create additional test data
5. Implement in your environment

## Support

For issues specific to this demo:
- Check documentation in /docs
- Review sample data formats
- Verify against provided examples

For z/OS system issues:
- Contact your system administrator
- Check IBM documentation
- Review installation guides
