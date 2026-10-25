# sample_runs

Real console output captured by running every test input through both versions:

- `fortran_test1.txt` ... `fortran_test10.txt`: Fortran version (gfortran 16.2.0, WinLibs, Windows)
- `julia_test1.txt` ... `julia_test10.txt`: Julia version (Julia 1.13.2)

Captured on 2026-10-25 with `bash tests/run_tests.sh`. All 10 tests reported `MATCH`, meaning the Fortran and Julia outputs are identical (ignoring line endings), and every output contains the expected lines listed in `tests/TEST_CASES.md`.

Because input was piped from a file, the values typed by the "user" are not shown after each prompt. See the note at the top of `tests/TEST_CASES.md`.

For a sample transaction history, see `julia_test7.txt` or `fortran_test7.txt` (5 transactions, final balance PHP 7050.25).

To regenerate these files, run from the project root:

- `bash tests/run_tests.sh` (Linux / macOS / Git Bash), or
- `powershell -ExecutionPolicy Bypass -File tests\run_tests.ps1` (Windows)
