# screenshots

Screenshots of the program running interactively in a Windows console, taken on 2026-10-25. Each version was run as one continuous session, and a screenshot was taken after each step. The `fortran_` and `julia_` files show the same session in the two versions.

| File | What it shows |
|---|---|
| `*_01_start_check_balance.png` | Start-up (starting balance PHP 5000.00) and Check Balance |
| `*_02_deposit.png` | Valid deposit of 1500 (balance 6500.00) |
| `*_03_withdraw.png` | Valid withdrawal of 2000 (balance 4500.00) |
| `*_04_invalid_amounts.png` | Deposit rejects 0, -500, `abc` and an empty line, then accepts 750.50 |
| `*_05_overdraft.png` | Withdrawal of 99999 rejected as insufficient funds; balance unchanged |
| `*_06_invalid_menu.png` | Invalid menu choices 0, 6 and `abc` rejected |
| `*_07_history.png` | Withdrawal of 1200.25, then the transaction history (4 transactions, final balance 4050.25) |
| `*_08_exit.png` | Exit |
