# Banking and Transaction Management System (Fortran + Julia)

A console banking program written twice, with **identical behavior and identical on-screen text**:

| Version | File | Language |
|---|---|---|
| Fortran | `fortran/bank.f90` | Fortran 2008, compiled with gfortran |
| Julia | `julia/bank.jl` | Julia 1.10 or newer |

Features: the starting balance is PHP 5000.00, and a menu loop offers Check Balance, Deposit, Withdraw, View Transaction History and Exit. All input is validated and the program never crashes on bad input. Only successful transactions are recorded, and end of input (EOF) exits cleanly. Both source files start with a **concept map** showing where each required programming concept is used.

Both versions use only the standard library (Julia uses `Printf`, which ships with Julia).

## Project structure

```
fortran/bank.f90        Fortran source
julia/bank.jl           Julia source
tests/inputs/           test1.txt ... test10.txt (stdin input, one value per line)
tests/TEST_CASES.md     10 test cases: description, inputs, expected output, pass/fail
tests/run_tests.sh      run all tests on both versions (Linux / macOS / Git Bash)
tests/run_tests.ps1     run all tests on both versions (Windows PowerShell)
sample_runs/            real captured output: fortran_testN.txt, julia_testN.txt
```

## Input rules (same in both versions)

| Input | Result |
|---|---|
| Menu: anything other than a whole number 1-5 (`0`, `6`, `abc`, `2.5`, empty line) | `Error: Invalid choice...`, and the menu is shown again |
| Amount: empty line | `Error: No amount entered...`, and you are asked again |
| Amount: not a plain number (`abc`, `12abc`, `1e3`, `1,000`) | `Error: Invalid amount...`, and you are asked again |
| Amount: negative / zero | its own error message, and you are asked again |
| Amount: more than 2 decimal places (`12.345`) | `Error: Amount can have at most 2 decimal places.` |
| Amount: over PHP 1000000.00 | `Error: Amount exceeds the limit...` (limit per transaction) |
| Withdrawal greater than the balance | error that shows the current balance; the withdrawal is cancelled and you return to the menu |

Both programs check the *text* first (an optional sign, digits, and at most one decimal point) and only then convert it to a number. This guarantees that Fortran and Julia accept exactly the same inputs. Without this check, Fortran's `read` would accept things like `1d3` or `12 abc` that Julia's `tryparse` rejects. The balance is rounded to centavos after every transaction, so floating-point errors cannot build up.

---

## 1. Install the tools

You need **gfortran** (for the Fortran version) and **Julia 1.10+** (for the Julia version). Check what you already have:

```
gfortran --version
julia --version
```

### Windows

**Julia (via juliaup):** in PowerShell:
```powershell
winget install --name Julia --id 9NJNWW8PVKMN -e -s msstore
```
Close and reopen the terminal, then run `julia --version`.

**gfortran, option A (MSYS2, recommended):**
```powershell
winget install --id MSYS2.MSYS2 -e
```
Open the **"MSYS2 UCRT64"** shell from the Start menu and run:
```bash
pacman -Syu                                   # if it asks to close the window, reopen it and run again
pacman -S mingw-w64-ucrt-x86_64-gcc-fortran
```
Add the compiler to your user PATH (in PowerShell), then reopen the terminal:
```powershell
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\msys64\ucrt64\bin", "User")
```

**gfortran, option B (WinLibs via winget, no MSYS2):**
```powershell
winget install --id BrechtSanders.WinLibs.POSIX.UCRT -e
```
Reopen the terminal and check `gfortran --version`.

### macOS

```bash
brew install gcc                                  # includes gfortran (needs Homebrew: https://brew.sh)
curl -fsSL https://install.julialang.org | sh     # installs juliaup + Julia
```

### Linux

```bash
sudo apt install gfortran          # Debian / Ubuntu
sudo dnf install gcc-gfortran      # Fedora
curl -fsSL https://install.julialang.org | sh     # installs juliaup + Julia
```

---

## 2. Compile and run

Run these commands from the project folder.

### Fortran

```bash
gfortran -std=f2008 -Wall -o fortran/bank fortran/bank.f90
./fortran/bank
```
On Windows (PowerShell):
```powershell
gfortran -std=f2008 -Wall -o fortran\bank.exe fortran\bank.f90
.\fortran\bank.exe
```
If Windows says a DLL such as `libgfortran-5.dll` is missing, either add `C:\msys64\ucrt64\bin` to PATH (see above) or compile with `-static`.

### Julia (no compile step)

```bash
julia julia/bank.jl
```

---

## 3. Run the tests

Run one test by piping an input file into the program:

```bash
./fortran/bank       < tests/inputs/test7.txt
julia julia/bank.jl  < tests/inputs/test7.txt
```
(In PowerShell, `<` does not work. Use `Get-Content tests\inputs\test7.txt | .\fortran\bank.exe`.)

To run **all** tests on **both** versions, save the real output to `sample_runs/` and check that Fortran and Julia match:

```bash
bash tests/run_tests.sh                                     # Linux / macOS / Git Bash
```
```powershell
powershell -ExecutionPolicy Bypass -File tests\run_tests.ps1   # Windows
```

Each test prints `MATCH` or `DIFFERENT`. Then compare the outputs with the expected lines in `tests/TEST_CASES.md` and tick Pass/Fail.

Note: gfortran on Windows ends lines with CRLF, while Julia uses LF. The run scripts ignore this difference, and the visible text is the same.
