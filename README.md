# COBOL Batch Processing Demo

A comprehensive demonstration of COBOL batch processing on IBM mainframe, showcasing file processing, reporting, and data validation patterns.

## 📋 Overview

This repository contains production-style COBOL batch programs that demonstrate:

- **Sequential file processing** (reading and writing flat files)
- **Report generation** with control breaks
- **Data validation** and error handling
- **Master file updates** with transaction processing
- **Sort/merge operations**
- **JCL job streams** for batch execution

## 🗂️ Repository Structure

```
cobol-batch-processing-demo/
├── README.md                    # This file
├── programs/                    # COBOL source programs
│   ├── SALESRPT.cbl            # Sales report generator
│   ├── CUSTUPD.cbl             # Customer master file update
│   ├── DATAVAL.cbl             # Data validation program
│   └── FILEMERGE.cbl           # File merge utility
├── copybooks/                   # COBOL copybooks
│   ├── SALESREC.cpy            # Sales record layout
│   ├── CUSTREC.cpy             # Customer record layout
│   └── ERRORREC.cpy            # Error record layout
├── jcl/                        # Job Control Language
│   ├── SALESRPT.jcl            # Run sales report
│   ├── CUSTUPD.jcl             # Run customer update
│   ├── DATAVAL.jcl             # Run data validation
│   ├── COMPILE.jcl             # Compile all programs
│   └── JOBSTREAM.jcl           # Complete job stream
├── data/                        # Sample data files
│   ├── SALES.txt               # Sample sales transactions
│   ├── CUSTOMER.txt            # Sample customer master
│   └── README.md               # Data file documentation
└── docs/                        # Documentation
    ├── ARCHITECTURE.md         # System architecture
    ├── SETUP.md                # Setup instructions
    └── TESTING.md              # Testing guide

```

## 🚀 Quick Start

### Prerequisites

- IBM z/OS or compatible mainframe environment
- Enterprise COBOL compiler (V4.2 or higher)
- TSO/ISPF access or z/OS USS shell
- Datasets allocated for programs, copybooks, and data

### Running the Demo

1. **Compile Programs**
   ```
   Submit JCL: jcl/COMPILE.jcl
   ```

2. **Run Sales Report**
   ```
   Submit JCL: jcl/SALESRPT.jcl
   ```

3. **Run Customer Update**
   ```
   Submit JCL: jcl/CUSTUPD.jcl
   ```

4. **Run Complete Job Stream**
   ```
   Submit JCL: jcl/JOBSTREAM.jcl
   ```

## 📊 Programs Description

### SALESRPT.cbl - Sales Report Generator
Reads sales transaction file and produces formatted report with:
- Daily sales totals by salesperson
- Regional subtotals
- Grand totals
- Control break logic

**Input:** Sales transaction file (80-byte records)  
**Output:** Formatted sales report (132-byte print records)

### CUSTUPD.cbl - Customer Master Update
Updates customer master file with transaction data:
- Adds new customers
- Updates existing customer information
- Validates all transactions
- Produces update summary report

**Inputs:** Customer master, Transaction file  
**Outputs:** Updated master, Transaction report, Error file

### DATAVAL.cbl - Data Validation
Validates incoming data files:
- Field-level validation (numeric, date, required fields)
- Business rule validation
- Produces clean output file
- Writes errors to error file with detailed messages

**Input:** Raw data file  
**Outputs:** Clean data file, Error report

### FILEMERGE.cbl - File Merge Utility
Merges two sorted files:
- Reads two input files in sequence
- Merges based on key field
- Eliminates duplicates (optional)
- Produces single merged output

**Inputs:** Two sorted files  
**Output:** Merged file

## 🔧 Technical Details

### COBOL Features Demonstrated

- Sequential file processing (OPEN, READ, WRITE, CLOSE)
- Control break reporting
- File status checking and error handling
- SORT verb usage
- Copybook inclusion
- Procedure division organization
- Working-storage management
- Condition names (88-level)
- Structured programming (PERFORM, EVALUATE)

### JCL Features Demonstrated

- DD statements for file allocation
- DISP parameter usage
- SYSOUT classes
- Cataloged procedures
- JOB statements with CLASS and MSGCLASS
- EXEC statements for program execution
- Condition code checking
- Multi-step job streams

## 📈 Sample Output

### Sales Report Output
```
SALES REPORT - BY SALESPERSON                    PAGE:    1
RUN DATE: 02/16/2026

SALESPERSON: ANDERSON, JOHN
  REGION: NORTHEAST
    
    DATE        PRODUCT      QUANTITY    AMOUNT
    02/14/2026  WIDGET-A          100  $ 1,250.00
    02/14/2026  WIDGET-B           50  $ 1,500.00
    02/15/2026  WIDGET-A          150  $ 1,875.00
                                      --------------
    SALESPERSON TOTAL:                $  4,625.00

SALESPERSON: BAKER, MARY
  REGION: NORTHEAST
    ...

NORTHEAST REGIONAL TOTAL:                        $ 23,450.00
SOUTHEAST REGIONAL TOTAL:                        $ 18,790.00
SOUTHWEST REGIONAL TOTAL:                        $ 31,225.00

GRAND TOTAL:                                     $ 73,465.00
```

## 🎯 Learning Objectives

This demo helps you learn:

1. **File Processing**: How to read, process, and write sequential files in COBOL
2. **Batch Architecture**: Typical mainframe batch job structure and flow
3. **JCL Skills**: How to write JCL to compile and execute COBOL programs
4. **Error Handling**: Proper file status checking and error recovery
5. **Reporting**: Generating formatted reports with control breaks
6. **Data Validation**: Implementing business rules and data quality checks
7. **Best Practices**: Professional COBOL coding standards and patterns

## 📝 Data File Formats

### Sales Transaction File
```
Positions   Field Name        Type      Description
1-6         Salesperson ID    Numeric   Unique ID
7-26        Salesperson Name  Alpha     Last, First
27-36       Sale Date         Date      YYYY-MM-DD
37-46       Product Code      Alpha     Product identifier
47-52       Quantity          Numeric   Units sold
53-62       Sale Amount       Numeric   Dollar amount (2 decimals)
63-72       Region            Alpha     Sales region
73-80       Filler            Alpha     Reserved
```

### Customer Master File
```
Positions   Field Name        Type      Description
1-6         Customer ID       Numeric   Unique ID
7-36        Customer Name     Alpha     Company/person name
37-66       Address           Alpha     Street address
67-86       City              Alpha     City name
87-88       State             Alpha     State code
89-98       Zip Code          Alpha     Postal code
99-148      Email             Alpha     Email address
149-163     Phone             Alpha     Phone number
164-173     Credit Limit      Numeric   Dollar amount (2 decimals)
174-183     Balance           Numeric   Dollar amount (2 decimals)
184-193     Last Order Date   Date      YYYY-MM-DD
194-200     Filler            Alpha     Reserved
```

## 🧪 Testing

See [docs/TESTING.md](docs/TESTING.md) for:
- Unit testing approach
- Test data creation
- Expected results validation
- Troubleshooting common issues

## 📚 Additional Resources

- [IBM Enterprise COBOL Documentation](https://www.ibm.com/docs/en/cobol-zos)
- [JCL Reference](https://www.ibm.com/docs/en/zos/2.4.0?topic=mvs-jcl-reference)
- [Mainframe Best Practices](https://www.ibm.com/support/pages/cobol-programming-best-practices)

## 🤝 Contributing

This is a demonstration repository for portfolio purposes. If you find issues or have suggestions:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is provided as-is for educational and demonstration purposes.

## 👤 Author

Created as a portfolio demonstration of COBOL batch processing skills.

## 🌟 Acknowledgments

- IBM for COBOL and mainframe technology
- The mainframe community for best practices and patterns

---

**Note:** This is a demonstration repository. For production use, additional error handling, logging, security, and operational procedures would be required.
