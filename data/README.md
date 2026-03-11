# Sample Data Files

This directory contains sample data files for testing the COBOL batch programs.

## Files

### SALES.txt
Sales transaction file with 22 sample records.

**Format:** 80-byte fixed-length records  
**Records:** 22 sales transactions  
**Date Range:** February 14-15, 2026  
**Salespersons:** 10 different sales representatives  
**Regions:** NORTHEAST, SOUTHEAST, MIDWEST, SOUTHWEST, WEST  

**Usage:**
```jcl
//SALESIN  DD   DSN=USER.SALES.TRANS,DISP=SHR
```

### CUSTOMER.txt
Customer master file with 10 sample records.

**Format:** 200-byte fixed-length records  
**Records:** 10 customer companies  
**Status:** 9 Active (A), 1 Inactive (I)  
**Total Credit Limit:** $5,450,000.00  
**Total Balance:** $370,000.00  

**Usage:**
```jcl
//CUSTMIN  DD   DSN=USER.CUSTOMER.MASTER,DISP=SHR
```

## Loading Sample Data

### Option 1: Using FTP (from workstation)
```bash
# Upload to mainframe dataset
ftp zos.example.com
binary
put SALES.txt 'USER.SALES.TRANS'
put CUSTOMER.txt 'USER.CUSTOMER.MASTER'
quit
```

### Option 2: Using z/OS Unix (USS)
```bash
# Copy from USS to dataset
cp /path/to/SALES.txt "//'USER.SALES.TRANS'"
cp /path/to/CUSTOMER.txt "//'USER.CUSTOMER.MASTER'"
```

### Option 3: Using IEBGENER JCL
```jcl
//UPLOAD   JOB  (ACCT),'UPLOAD DATA',CLASS=A,MSGCLASS=X
//STEP1    EXEC PGM=IEBGENER
//SYSPRINT DD   SYSOUT=*
//SYSUT1   DD   PATH='/u/userid/data/SALES.txt'
//SYSUT2   DD   DSN=USER.SALES.TRANS,
//              DISP=(NEW,CATLG,DELETE),
//              SPACE=(TRK,(10,5),RLSE),
//              DCB=(RECFM=FB,LRECL=80,BLKSIZE=8000)
//SYSIN    DD   DUMMY
```

## Dataset Allocation

Before loading data, allocate datasets with these specifications:

### Sales Transaction File
```
Dataset Name: USER.SALES.TRANS
Record Format: FB (Fixed Block)
Logical Record Length: 80
Block Size: 8000
Space: (TRK,(10,5),RLSE)
```

### Customer Master File
```
Dataset Name: USER.CUSTOMER.MASTER
Record Format: FB (Fixed Block)
Logical Record Length: 200
Block Size: 20000
Space: (TRK,(50,10),RLSE)
```

## Creating Test Data

### Generate Additional Sales Records

Use this template to create more sales records:
```
Columns 1-6:    Salesperson ID (numeric)
Columns 7-26:   Salesperson Name
Columns 27-36:  Sale Date (YYYY-MM-DD)
Columns 37-46:  Product Code
Columns 47-52:  Quantity (numeric, right-justified)
Columns 53-62:  Sale Amount (numeric with 2 decimals)
Columns 63-72:  Region
Columns 73-80:  Filler (spaces)
```

### Generate Additional Customer Records

Use this template:
```
Columns 1-6:     Customer ID (numeric)
Columns 7-36:    Customer Name
Columns 37-66:   Address
Columns 67-86:   City
Columns 87-88:   State
Columns 89-98:   ZIP Code
Columns 99-148:  Email
Columns 149-163: Phone
Columns 164-173: Credit Limit (numeric with 2 decimals)
Columns 174-183: Balance (numeric with 2 decimals)
Columns 184-193: Last Order Date (YYYY-MM-DD)
Columns 194:     Status (A=Active, I=Inactive, S=Suspended)
Columns 195-200: Filler (spaces)
```

## Data Validation Rules

The DATAVAL program validates:

1. **Required Fields**: All key fields must have values
2. **Numeric Fields**: Must be valid numbers
3. **Date Format**: Must be YYYY-MM-DD
4. **Region Codes**: NORTHEAST, SOUTHEAST, MIDWEST, SOUTHWEST, WEST
5. **Business Rules**:
   - Quantity must be > 0
   - Sale amount must be > 0
   - Customer name cannot be blank
   - Credit limit cannot be negative

## Expected Output

### Sales Report
The SALESRPT program produces:
- Page headers with run date
- Salesperson sections
- Regional subtotals
- Grand total
- Approximately 3-4 pages for 22 sample records

### Customer Update
The CUSTUPD program produces:
- Update summary statistics
- Error file if any validation failures
- Updated master file

### Data Validation
The DATAVAL program produces:
- Clean data file (valid records only)
- Error file with detailed validation messages
- Processing statistics (clean rate percentage)
