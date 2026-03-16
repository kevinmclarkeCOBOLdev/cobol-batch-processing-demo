#!/bin/bash
#################################################################
# SCRIPT NAME: run_gnucustupd.sh
# DESCRIPTION: COMPILE AND RUN gnuCUSTUPD.cbl USING GNUCOBOL
#
# USAGE:       ./run_gnucustupd.sh
#
# PRE-REQUISITES:
#   - GnuCOBOL installed (cobc must be on your PATH)
#   - Directory structure:
#       project/
#       ├── gnuCUSTUPD.cbl
#       ├── run_gnucustupd.sh   (this script)
#       ├── copybooks/
#       │   ├── CUSTREC.cpy
#       │   └── ERRORREC.cpy
#       └── data/
#           ├── custmin.dat     (input  - customer master)
#           ├── transin.dat     (input  - transactions)
#           ├── custmout.dat    (output - updated master)
#           ├── report.txt      (output - run report)
#           └── errors.dat      (output - error records)
#
# TO MAKE THIS SCRIPT EXECUTABLE:
#   chmod +x run_gnucustupd.sh
#################################################################

#----------------------------------------------------------------
# DIRECTORY AND FILE SETTINGS
# ADJUST THESE PATHS IF YOUR STRUCTURE DIFFERS
#----------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/gnuCUSTUPD.cbl"
COPYBOOK_DIR="$SCRIPT_DIR/copybooks"
DATA_DIR="$SCRIPT_DIR/data"
EXECUTABLE="$SCRIPT_DIR/gnucustupd"

#----------------------------------------------------------------
# DATA FILE ASSIGNMENTS
# ADJUST FILENAMES HERE IF YOURS DIFFER
#----------------------------------------------------------------
export CUSTMIN="$DATA_DIR/custmin.dat"
export CUSTMOUT="$DATA_DIR/custmout.dat"
export TRANSIN="$DATA_DIR/transin.dat"
export RPTUPDOUT="$DATA_DIR/report.txt"
export ERROROUT="$DATA_DIR/errors.dat"

#----------------------------------------------------------------
# DISPLAY SETTINGS BEING USED
#----------------------------------------------------------------
echo "================================================="
echo " gnuCUSTUPD - COMPILE AND RUN"
echo "================================================="
echo " Source file  : $SOURCE_FILE"
echo " Copybooks    : $COPYBOOK_DIR"
echo " Data dir     : $DATA_DIR"
echo " Executable   : $EXECUTABLE"
echo "-------------------------------------------------"
echo " File assignments:"
echo "   CUSTMIN    = $CUSTMIN"
echo "   CUSTMOUT   = $CUSTMOUT"
echo "   TRANSIN    = $TRANSIN"
echo "   RPTUPDOUT  = $RPTUPDOUT"
echo "   ERROROUT   = $ERROROUT"
echo "================================================="

#----------------------------------------------------------------
# PRE-RUN CHECKS
#----------------------------------------------------------------

# CHECK GNUCOBOL IS INSTALLED
if ! command -v cobc &> /dev/null; then
    echo ""
    echo "ERROR: cobc not found. Please install GnuCOBOL."
    echo "       On Ubuntu/Debian: sudo apt-get install gnucobol"
    echo "       On Fedora/RHEL:   sudo dnf install gnucobol"
    echo "       On macOS:         brew install gnucobol"
    exit 1
fi

# CHECK SOURCE FILE EXISTS
if [ ! -f "$SOURCE_FILE" ]; then
    echo ""
    echo "ERROR: Source file not found: $SOURCE_FILE"
    exit 1
fi

# CHECK COPYBOOK DIRECTORY EXISTS
if [ ! -d "$COPYBOOK_DIR" ]; then
    echo ""
    echo "ERROR: Copybook directory not found: $COPYBOOK_DIR"
    exit 1
fi

# CHECK REQUIRED COPYBOOKS EXIST
for CPY in CUSTREC.cpy ERRORREC.cpy; do
    if [ ! -f "$COPYBOOK_DIR/$CPY" ]; then
        echo ""
        echo "ERROR: Required copybook not found: $COPYBOOK_DIR/$CPY"
        exit 1
    fi
done

# CHECK DATA DIRECTORY EXISTS
if [ ! -d "$DATA_DIR" ]; then
    echo ""
    echo "ERROR: Data directory not found: $DATA_DIR"
    exit 1
fi

# CHECK INPUT FILES EXIST
for INFILE in "$CUSTMIN" "$TRANSIN"; do
    if [ ! -f "$INFILE" ]; then
        echo ""
        echo "ERROR: Input file not found: $INFILE"
        exit 1
    fi
done

#----------------------------------------------------------------
# COMPILE
#----------------------------------------------------------------
echo ""
echo "Compiling gnuCUSTUPD.cbl ..."
echo ""

cobc -x -free -I "$COPYBOOK_DIR" -o "$EXECUTABLE" "$SOURCE_FILE"

COMPILE_RC=$?

if [ $COMPILE_RC -ne 0 ]; then
    echo ""
    echo "================================================="
    echo " COMPILE FAILED - Return code: $COMPILE_RC"
    echo " Review compiler messages above for details."
    echo "================================================="
    exit $COMPILE_RC
fi

echo ""
echo "Compile successful."

#----------------------------------------------------------------
# RUN
#----------------------------------------------------------------
echo ""
echo "Running gnuCUSTUPD ..."
echo "================================================="
echo ""

"$EXECUTABLE"

RUN_RC=$?

echo ""
echo "================================================="
if [ $RUN_RC -eq 0 ]; then
    echo " RUN COMPLETED SUCCESSFULLY - Return code: $RUN_RC"
else
    echo " RUN FAILED - Return code: $RUN_RC"
fi
echo "================================================="

#----------------------------------------------------------------
# SHOW OUTPUT FILE SIZES AS A QUICK SANITY CHECK
#----------------------------------------------------------------
echo ""
echo "Output file summary:"
echo "-------------------------------------------------"
for OUTFILE in "$CUSTMOUT" "$RPTUPDOUT" "$ERROROUT"; do
    if [ -f "$OUTFILE" ]; then
        SIZE=$(wc -c < "$OUTFILE")
        LINES=$(wc -l < "$OUTFILE")
        echo "  $(basename $OUTFILE): $SIZE bytes, $LINES lines"
    else
        echo "  $(basename $OUTFILE): not created"
    fi
done
echo "================================================="

exit $RUN_RC
