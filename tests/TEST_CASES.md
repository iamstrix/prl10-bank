# Test Cases: Banking and Transaction Management System

Each test has an input file in `tests/inputs/` with one value per line (one line = one thing the user types). Feed a file to the program through standard input:

```
fortran/bank < tests/inputs/test2.txt
julia julia/bank.jl < tests/inputs/test2.txt
```

To run every test on both versions, save the output in `sample_runs/` and compare the two versions, use `bash tests/run_tests.sh` (Linux/macOS/Git Bash) or `powershell -ExecutionPolicy Bypass -File tests\run_tests.ps1` (Windows).

**About piped output:** when input comes from a file, the typed values are *not* shown on screen. So in the output, each prompt such as `Enter your choice (1-5): ` is followed by an empty rest of line, and the program's reply starts on the next line. Interactively, you see what you type after the prompt, followed by a blank line.

**Expected output:** to keep this document short, each test lists only the *key lines* in order. The banner, the menu, and the `Enter your choice (1-5):` prompts are left out (the full screen is shown once, in TC07). The real captured outputs go in `sample_runs/fortran_testN.txt` and `sample_runs/julia_testN.txt`.

**Pass/Fail:** fill in after running the tests. Status at the time of writing: *not run yet, because gfortran and Julia were not installed on the development machine.* A test passes when the output contains the expected lines **and** the Fortran and Julia outputs are identical (the run scripts check the second part automatically).

---

## TC01: Check initial balance

| | |
|---|---|
| **Description** | On start the balance is 5000.00 and is displayed; Check Balance shows the same. |
| **Input file** | `inputs/test1.txt` |
| **Input sequence** | `1` (Check Balance), `5` (Exit) |

**Expected output (key lines)**
```
Account initialized.
Starting balance: PHP 5000.00
Current balance: PHP 5000.00
Thank you for using the Banking and Transaction System. Goodbye!
```

| Fortran | Julia | Outputs identical |
|---|---|---|
| ☐ Pass ☐ Fail | ☐ Pass ☐ Fail | ☐ Yes ☐ No |

---

## TC02: Valid deposit

| | |
|---|---|
| **Description** | Depositing 1500 adds it to the balance (5000.00 → 6500.00). |
| **Input file** | `inputs/test2.txt` |
| **Input sequence** | `2`, `1500`, `1`, `5` |

**Expected output (key lines)**
```
--- Deposit Money ---
Enter amount to deposit: 
Deposit successful. Amount deposited: PHP 1500.00
New balance: PHP 6500.00
Current balance: PHP 6500.00
Thank you for using the Banking and Transaction System. Goodbye!
```

| Fortran | Julia | Outputs identical |
|---|---|---|
| ☐ Pass ☐ Fail | ☐ Pass ☐ Fail | ☐ Yes ☐ No |

---

## TC03: Valid withdrawal

| | |
|---|---|
| **Description** | Withdrawing 2000 deducts it from the balance (5000.00 → 3000.00). |
| **Input file** | `inputs/test3.txt` |
| **Input sequence** | `3`, `2000`, `1`, `5` |

**Expected output (key lines)**
```
--- Withdraw Money ---
Enter amount to withdraw: 
Withdrawal successful. Amount withdrawn: PHP 2000.00
New balance: PHP 3000.00
Current balance: PHP 3000.00
Thank you for using the Banking and Transaction System. Goodbye!
```

| Fortran | Julia | Outputs identical |
|---|---|---|
| ☐ Pass ☐ Fail | ☐ Pass ☐ Fail | ☐ Yes ☐ No |

---

## TC04: Deposit of zero and a negative amount (both rejected)

| | |
|---|---|
| **Description** | `0` and `-500` are each rejected with their own message and the user is asked again. A valid `300` then succeeds. The history shows **only** the successful 300 deposit, which proves failed attempts are not recorded. |
| **Input file** | `inputs/test4.txt` |
| **Input sequence** | `2`, `0`, `-500`, `300`, `4`, `5` |

**Expected output (key lines)**
```
--- Deposit Money ---
Enter amount to deposit: 
Error: Amount must be greater than zero.
Enter amount to deposit: 
Error: Negative amounts are not allowed.
Enter amount to deposit: 
Deposit successful. Amount deposited: PHP 300.00
New balance: PHP 5300.00
--- Transaction History ---
No.  Type                  Amount     Balance After
---  ----------  ----------------  ----------------
  1  Deposit     PHP       300.00  PHP      5300.00
Total transactions: 1
Thank you for using the Banking and Transaction System. Goodbye!
```

| Fortran | Julia | Outputs identical |
|---|---|---|
| ☐ Pass ☐ Fail | ☐ Pass ☐ Fail | ☐ Yes ☐ No |

---

## TC05: Withdrawal exceeding the balance

| | |
|---|---|
| **Description** | Withdrawing 6000 from 5000.00 is rejected. The error shows the current balance, the transaction is cancelled, the balance stays 5000.00, and nothing is recorded. |
| **Input file** | `inputs/test5.txt` |
| **Input sequence** | `3`, `6000`, `1`, `4`, `5` |

**Expected output (key lines)**
```
--- Withdraw Money ---
Enter amount to withdraw: 
Error: Insufficient funds. Your current balance is PHP 5000.00.
Withdrawal cancelled.
Current balance: PHP 5000.00
--- Transaction History ---
No transactions yet.
Thank you for using the Banking and Transaction System. Goodbye!
```

| Fortran | Julia | Outputs identical |
|---|---|---|
| ☐ Pass ☐ Fail | ☐ Pass ☐ Fail | ☐ Yes ☐ No |

---

## TC06: Invalid menu choices and non-numeric amount

| | |
|---|---|
| **Description** | Menu inputs `0`, `6`, `9` (out of range), `abc` (not a number), an empty line, and `2.5` (not a whole number) each show an error, and the menu is shown again. Inside Deposit, `abc` and an empty line are rejected with different messages and the user is asked again. Then `250.75` succeeds. |
| **Input file** | `inputs/test6.txt` |
| **Input sequence** | `0`, `6`, `9`, `abc`, *(empty line)*, `2.5`, `2`, `abc`, *(empty line)*, `250.75`, `5` |

**Expected output (key lines)**
```
Error: Invalid choice. Please enter a number from 1 to 5.     (shown 6 times, menu redisplayed after each)
--- Deposit Money ---
Enter amount to deposit: 
Error: Invalid amount. Please enter a number such as 1500 or 250.75.
Enter amount to deposit: 
Error: No amount entered. Please type a number.
Enter amount to deposit: 
Deposit successful. Amount deposited: PHP 250.75
New balance: PHP 5250.75
Thank you for using the Banking and Transaction System. Goodbye!
```

| Fortran | Julia | Outputs identical |
|---|---|---|
| ☐ Pass ☐ Fail | ☐ Pass ☐ Fail | ☐ Yes ☐ No |

---

## TC07: Full session with transaction history (sample history)

| | |
|---|---|
| **Description** | Several deposits and withdrawals, then View Transaction History. All five transactions appear in order, with correct running balances, in an aligned table. |
| **Input file** | `inputs/test7.txt` |
| **Input sequence** | `2`, `1500`, `3`, `2000`, `2`, `750.50`, `3`, `1200.25`, `2`, `3000`, `4`, `5` |

Balance check: 5000.00 + 1500.00 = 6500.00 → − 2000.00 = 4500.00 → + 750.50 = 5250.50 → − 1200.25 = 4050.25 → + 3000.00 = **7050.25**

**Expected output (complete screen, exactly as captured from piped input)**
```
===========================================
      BANKING AND TRANSACTION SYSTEM
===========================================
Account initialized.
Starting balance: PHP 5000.00

---------------- MAIN MENU ----------------
1. Check Balance
2. Deposit Money
3. Withdraw Money
4. View Transaction History
5. Exit
Enter your choice (1-5): 
--- Deposit Money ---
Enter amount to deposit: 
Deposit successful. Amount deposited: PHP 1500.00
New balance: PHP 6500.00

---------------- MAIN MENU ----------------
1. Check Balance
2. Deposit Money
3. Withdraw Money
4. View Transaction History
5. Exit
Enter your choice (1-5): 
--- Withdraw Money ---
Enter amount to withdraw: 
Withdrawal successful. Amount withdrawn: PHP 2000.00
New balance: PHP 4500.00

---------------- MAIN MENU ----------------
1. Check Balance
2. Deposit Money
3. Withdraw Money
4. View Transaction History
5. Exit
Enter your choice (1-5): 
--- Deposit Money ---
Enter amount to deposit: 
Deposit successful. Amount deposited: PHP 750.50
New balance: PHP 5250.50

---------------- MAIN MENU ----------------
1. Check Balance
2. Deposit Money
3. Withdraw Money
4. View Transaction History
5. Exit
Enter your choice (1-5): 
--- Withdraw Money ---
Enter amount to withdraw: 
Withdrawal successful. Amount withdrawn: PHP 1200.25
New balance: PHP 4050.25

---------------- MAIN MENU ----------------
1. Check Balance
2. Deposit Money
3. Withdraw Money
4. View Transaction History
5. Exit
Enter your choice (1-5): 
--- Deposit Money ---
Enter amount to deposit: 
Deposit successful. Amount deposited: PHP 3000.00
New balance: PHP 7050.25

---------------- MAIN MENU ----------------
1. Check Balance
2. Deposit Money
3. Withdraw Money
4. View Transaction History
5. Exit
Enter your choice (1-5): 
--- Transaction History ---
No.  Type                  Amount     Balance After
---  ----------  ----------------  ----------------
  1  Deposit     PHP      1500.00  PHP      6500.00
  2  Withdrawal  PHP      2000.00  PHP      4500.00
  3  Deposit     PHP       750.50  PHP      5250.50
  4  Withdrawal  PHP      1200.25  PHP      4050.25
  5  Deposit     PHP      3000.00  PHP      7050.25
Total transactions: 5

---------------- MAIN MENU ----------------
1. Check Balance
2. Deposit Money
3. Withdraw Money
4. View Transaction History
5. Exit
Enter your choice (1-5): 
Thank you for using the Banking and Transaction System. Goodbye!
```

| Fortran | Julia | Outputs identical |
|---|---|---|
| ☐ Pass ☐ Fail | ☐ Pass ☐ Fail | ☐ Yes ☐ No |

---

## TC08: End of input without choosing Exit (EOF)

| | |
|---|---|
| **Description** | The input file ends after one deposit, without `5`. The program must exit cleanly with a message, with no crash, no error trace and no endless loop. |
| **Input file** | `inputs/test8.txt` |
| **Input sequence** | `2`, `1000`, *(end of file)* |

**Expected output (key lines)**
```
Deposit successful. Amount deposited: PHP 1000.00
New balance: PHP 6000.00
...
Enter your choice (1-5): 
End of input reached. Exiting program.
```

| Fortran | Julia | Outputs identical |
|---|---|---|
| ☐ Pass ☐ Fail | ☐ Pass ☐ Fail | ☐ Yes ☐ No |

---

## TC09: Withdraw the exact balance (boundary)

| | |
|---|---|
| **Description** | Withdrawing exactly 5000 is allowed (amount is not *greater* than the balance) and leaves 0.00. A further withdrawal of 0.01 is then rejected as an overdraft. |
| **Input file** | `inputs/test9.txt` |
| **Input sequence** | `3`, `5000`, `3`, `0.01`, `4`, `5` |

**Expected output (key lines)**
```
Withdrawal successful. Amount withdrawn: PHP 5000.00
New balance: PHP 0.00
Error: Insufficient funds. Your current balance is PHP 0.00.
Withdrawal cancelled.
--- Transaction History ---
No.  Type                  Amount     Balance After
---  ----------  ----------------  ----------------
  1  Withdrawal  PHP      5000.00  PHP         0.00
Total transactions: 1
```

| Fortran | Julia | Outputs identical |
|---|---|---|
| ☐ Pass ☐ Fail | ☐ Pass ☐ Fail | ☐ Yes ☐ No |

---

## TC10: Too many decimal places and per-transaction limit

| | |
|---|---|
| **Description** | `12.345` is rejected (money has at most 2 decimals). `1000000.01` is rejected (over the PHP 1000000.00 limit per transaction). Exactly `1000000` is accepted. |
| **Input file** | `inputs/test10.txt` |
| **Input sequence** | `2`, `12.345`, `1000000.01`, `1000000`, `1`, `5` |

**Expected output (key lines)**
```
Error: Amount can have at most 2 decimal places.
Enter amount to deposit: 
Error: Amount exceeds the limit of PHP 1000000.00 per transaction.
Enter amount to deposit: 
Deposit successful. Amount deposited: PHP 1000000.00
New balance: PHP 1005000.00
Current balance: PHP 1005000.00
```

| Fortran | Julia | Outputs identical |
|---|---|---|
| ☐ Pass ☐ Fail | ☐ Pass ☐ Fail | ☐ Yes ☐ No |
