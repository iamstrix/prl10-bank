# sample_runs

No output has been captured here yet. gfortran and Julia were not installed on the machine where the code was written, so the programs have not been run, and no sample output was made up.

After installing both tools (see the main README), run from the project root:

- `bash tests/run_tests.sh` (Linux / macOS / Git Bash), or
- `powershell -ExecutionPolicy Bypass -File tests\run_tests.ps1` (Windows)

This creates `fortran_test1.txt` ... `fortran_test10.txt` and `julia_test1.txt` ... `julia_test10.txt` here, containing the real console output, and reports whether the two versions match.
