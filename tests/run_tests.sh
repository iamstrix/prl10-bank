#!/usr/bin/env bash
# run_tests.sh - for Linux, macOS, or Git Bash / MSYS2 on Windows.
# Compiles the Fortran version, runs BOTH versions on every test input,
# saves the real console output in sample_runs/, and compares the two.
#
# Usage (from the project root):   bash tests/run_tests.sh

cd "$(dirname "$0")/.." || exit 1

echo "Compiling Fortran version..."
gfortran -std=f2008 -Wall -o fortran/bank fortran/bank.f90 || exit 1

all_match=1
i=1
while [ -f "tests/inputs/test$i.txt" ]; do
    input="tests/inputs/test$i.txt"
    ./fortran/bank       < "$input" > "sample_runs/fortran_test$i.txt"
    julia julia/bank.jl  < "$input" > "sample_runs/julia_test$i.txt"

    # --strip-trailing-cr: on Windows, gfortran writes CRLF line endings and
    # Julia writes LF, so line endings are ignored in the comparison.
    if diff --strip-trailing-cr -q "sample_runs/fortran_test$i.txt" \
                                   "sample_runs/julia_test$i.txt" > /dev/null; then
        echo "test$i: MATCH"
    else
        echo "test$i: DIFFERENT  (run: diff sample_runs/fortran_test$i.txt sample_runs/julia_test$i.txt)"
        all_match=0
    fi
    i=$((i + 1))
done

if [ "$all_match" -eq 1 ]; then
    echo "All tests: Fortran and Julia outputs match."
else
    echo "Some tests differ - see above."
    exit 1
fi
