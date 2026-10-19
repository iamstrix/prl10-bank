# run_tests.ps1 - for Windows PowerShell.
# Compiles the Fortran version, runs BOTH versions on every test input,
# saves the real console output in sample_runs\, and compares the two.
#
# Usage (from the project root):
#   powershell -ExecutionPolicy Bypass -File tests\run_tests.ps1

Set-Location (Join-Path $PSScriptRoot "..")

Write-Host "Compiling Fortran version..."
gfortran -std=f2008 -Wall -o fortran\bank.exe fortran\bank.f90
if ($LASTEXITCODE -ne 0) { exit 1 }

$allMatch = $true
$i = 1
while (Test-Path "tests\inputs\test$i.txt") {
    $inFile  = "tests\inputs\test$i.txt"
    $fortOut = "sample_runs\fortran_test$i.txt"
    $juliaOut = "sample_runs\julia_test$i.txt"

    # cmd's < and > pass the bytes through unchanged (PowerShell 5.1's own
    # > operator would re-encode the output as UTF-16).
    cmd /c "fortran\bank.exe < $inFile > $fortOut"
    cmd /c "julia julia\bank.jl < $inFile > $juliaOut"

    # Compare line by line (this ignores CRLF vs LF line endings).
    $diff = Compare-Object (Get-Content $fortOut) (Get-Content $juliaOut) -CaseSensitive
    if ($null -eq $diff) {
        Write-Host "test${i}: MATCH"
    } else {
        Write-Host "test${i}: DIFFERENT"
        $diff | Format-Table -AutoSize
        $allMatch = $false
    }
    $i = $i + 1
}

if ($allMatch) {
    Write-Host "All tests: Fortran and Julia outputs match."
} else {
    Write-Host "Some tests differ - see above."
    exit 1
}
