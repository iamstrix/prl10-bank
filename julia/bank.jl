#===============================================================================
 Banking and Transaction Management System  (Julia version, Julia 1.10+)

 Run:  julia bank.jl

 CONCEPT MAP  (where each required concept appears in this file)
 ---------------------------------------------------------------------------
 Variables with explicit types  : type annotations on struct fields
                                  (Transaction), function arguments and return
                                  values (e.g. deposit(balance::Float64, ...)::Float64),
                                  and local variables in main (balance::Float64).
 Constants                      : STARTING_BALANCE, MAX_AMOUNT at the top.
 Arithmetic operators           : deposit (balance + amount), withdraw
                                  (balance - amount), round_cents (* and /).
 Comparison operators           : read_amount (< 0, == 0, > MAX_AMOUNT),
                                  withdraw (amount > balance),
                                  is_digits / looks_like_number ('0' <= c <= '9').
 if / elseif / else             : main menu loop, read_amount, withdraw,
                                  show_history, read_line.
 (Julia has no select case, so the menu uses an if/elseif chain in main.)
 Loops                          : main "while running" menu loop; read_amount
                                  "while !valid" re-prompt loop; "for" loops in
                                  show_history, is_digits, looks_like_number.
 User-defined functions         : show_menu, read_menu_choice, read_amount,
                                  deposit, withdraw, show_balance, show_history,
                                  plus helpers read_line, is_digits,
                                  looks_like_number, count_decimals, round_cents,
                                  format_money.
 Data structure (record type)   : struct Transaction with fields
                                  type, amount, balance_after.
 Growing collection             : history::Vector{Transaction} in main; records
                                  are appended with push! in deposit / withdraw.
 Safe input / error handling    : read_line uses readline() and exits cleanly on
                                  EOF; read_menu_choice and read_amount convert
                                  with tryparse() and check for `nothing`.
===============================================================================#

using Printf    # standard library: @sprintf / @printf for 2-decimal formatting

# ----- Constants -----
const STARTING_BALANCE = 5000.00     # Float64
const MAX_AMOUNT = 1000000.00        # Float64, limit per transaction

# ----- Data structure: one transaction record -----
struct Transaction
    type::String            # "Deposit" or "Withdrawal"
    amount::Float64         # amount of money moved
    balance_after::Float64  # balance right after this transaction
end

#-------------------------------------------------------------------------------
# read_line: read one line of text from the keyboard (or a piped file).
# Tabs and carriage returns become spaces, and spaces at both ends are removed.
# If there is no more input (EOF), print a message and end the program.
#-------------------------------------------------------------------------------
function read_line()::String
    if eof(stdin)
        println()
        println("End of input reached. Exiting program.")
        exit(0)
    end

    line::String = readline(stdin)
    line = replace(line, '\t' => ' ', '\r' => ' ')
    line = String(strip(line, ' '))

    # Move to a fresh line so the next message does not follow the prompt.
    println()
    return line
end

#-------------------------------------------------------------------------------
# is_digits: true if text is not empty and contains only 0-9.
#-------------------------------------------------------------------------------
function is_digits(text::String)::Bool
    if length(text) == 0
        return false
    end
    for c in text
        if !('0' <= c <= '9')
            return false
        end
    end
    return true
end

#-------------------------------------------------------------------------------
# looks_like_number: true if text is an optional + or - sign followed by
# digits with at most one decimal point (for example 1500, 250.75, -20).
# This keeps the Julia and Fortran versions accepting exactly the same input.
#-------------------------------------------------------------------------------
function looks_like_number(text::String)::Bool
    if length(text) == 0
        return false
    end

    num_digits::Int = 0
    num_dots::Int = 0
    for (position, c) in enumerate(text)
        if position == 1 && (c == '+' || c == '-')
            continue                # a sign is allowed only at the start
        elseif '0' <= c <= '9'
            num_digits = num_digits + 1
        elseif c == '.'
            num_dots = num_dots + 1
        else
            return false            # any other character: not a number
        end
    end

    return num_digits > 0 && num_dots <= 1
end

#-------------------------------------------------------------------------------
# count_decimals: number of characters after the decimal point (0 if none).
#-------------------------------------------------------------------------------
function count_decimals(text::String)::Int
    dot_position = findfirst('.', text)
    if dot_position === nothing
        return 0
    else
        return length(text) - dot_position
    end
end

#-------------------------------------------------------------------------------
# round_cents: round a money value to the nearest centavo (2 decimals),
# so tiny floating-point errors never build up in the balance.
# RoundNearestTiesAway matches Fortran's anint().
#-------------------------------------------------------------------------------
function round_cents(x::Float64)::Float64
    return round(x * 100.0, RoundNearestTiesAway) / 100.0
end

#-------------------------------------------------------------------------------
# format_money: turn 5000.0 into the text "PHP 5000.00".
#-------------------------------------------------------------------------------
function format_money(x::Float64)::String
    return "PHP " * @sprintf("%.2f", x)
end

#-------------------------------------------------------------------------------
# show_menu: print the main menu (the prompt is printed by read_menu_choice).
#-------------------------------------------------------------------------------
function show_menu()
    println()
    println("---------------- MAIN MENU ----------------")
    println("1. Check Balance")
    println("2. Deposit Money")
    println("3. Withdraw Money")
    println("4. View Transaction History")
    println("5. Exit")
end

#-------------------------------------------------------------------------------
# read_menu_choice: ask for a menu choice and return it as an integer.
# Returns -1 if the input is empty or not a whole number; main then shows an
# error and redisplays the menu.
#-------------------------------------------------------------------------------
function read_menu_choice()::Int
    print("Enter your choice (1-5): ")
    flush(stdout)
    line = read_line()

    if is_digits(line)
        choice = tryparse(Int, line)
        if choice !== nothing
            return choice
        end
    end
    return -1
end

#-------------------------------------------------------------------------------
# read_amount: keep asking until the user types a valid positive amount.
# Each kind of mistake gets its own error message.
#-------------------------------------------------------------------------------
function read_amount(prompt::String)::Float64
    amount::Float64 = 0.0
    valid::Bool = false

    while !valid
        print(prompt)
        flush(stdout)
        line = read_line()

        if length(line) == 0
            println("Error: No amount entered. Please type a number.")
        elseif !looks_like_number(line)
            println("Error: Invalid amount. Please enter a number such as 1500 or 250.75.")
        else
            # The text looks like a number, so convert it safely.
            parsed = tryparse(Float64, line)
            if parsed === nothing
                println("Error: Invalid amount. Please enter a number such as 1500 or 250.75.")
            elseif parsed < 0.0
                println("Error: Negative amounts are not allowed.")
            elseif parsed == 0.0
                println("Error: Amount must be greater than zero.")
            elseif count_decimals(line) > 2
                println("Error: Amount can have at most 2 decimal places.")
            elseif parsed > MAX_AMOUNT
                println("Error: Amount exceeds the limit of " * format_money(MAX_AMOUNT) *
                        " per transaction.")
            else
                amount = parsed
                valid = true
            end
        end
    end
    return amount
end

#-------------------------------------------------------------------------------
# show_balance: print the current balance.
#-------------------------------------------------------------------------------
function show_balance(balance::Float64)
    println("Current balance: " * format_money(balance))
end

#-------------------------------------------------------------------------------
# deposit: read a valid amount, add it to the balance, record it.
# Returns the new balance (history is changed in place by push!).
#-------------------------------------------------------------------------------
function deposit(balance::Float64, history::Vector{Transaction})::Float64
    println("--- Deposit Money ---")
    amount = read_amount("Enter amount to deposit: ")

    balance = round_cents(balance + amount)
    push!(history, Transaction("Deposit", amount, balance))

    println("Deposit successful. Amount deposited: " * format_money(amount))
    println("New balance: " * format_money(balance))
    return balance
end

#-------------------------------------------------------------------------------
# withdraw: read a valid amount; if it is more than the balance, cancel.
# Otherwise subtract it from the balance and record it.
# Returns the (possibly unchanged) balance.
#-------------------------------------------------------------------------------
function withdraw(balance::Float64, history::Vector{Transaction})::Float64
    println("--- Withdraw Money ---")
    amount = read_amount("Enter amount to withdraw: ")

    if amount > balance
        # Overdraft: nothing changes and nothing is recorded.
        println("Error: Insufficient funds. Your current balance is " *
                format_money(balance) * ".")
        println("Withdrawal cancelled.")
    else
        balance = round_cents(balance - amount)
        push!(history, Transaction("Withdrawal", amount, balance))

        println("Withdrawal successful. Amount withdrawn: " * format_money(amount))
        println("New balance: " * format_money(balance))
    end
    return balance
end

#-------------------------------------------------------------------------------
# show_history: print all successful transactions as an aligned table.
#-------------------------------------------------------------------------------
function show_history(history::Vector{Transaction})
    println("--- Transaction History ---")
    if length(history) == 0
        println("No transactions yet.")
    else
        println("No.  Type                  Amount     Balance After")
        println("---  ----------  ----------------  ----------------")
        for i in 1:length(history)
            t = history[i]
            @printf("%3d  %-10s  PHP %12.2f  PHP %12.2f\n", i, t.type, t.amount, t.balance_after)
        end
        println("Total transactions: ", length(history))
    end
end

#-------------------------------------------------------------------------------
# main: set up the account, then run the menu loop until Exit.
#-------------------------------------------------------------------------------
function main()
    # ----- Account initialization -----
    balance::Float64 = STARTING_BALANCE
    history::Vector{Transaction} = Transaction[]
    running::Bool = true

    println("===========================================")
    println("      BANKING AND TRANSACTION SYSTEM")
    println("===========================================")
    println("Account initialized.")
    println("Starting balance: " * format_money(balance))

    # ----- Main menu loop -----
    while running
        show_menu()
        choice::Int = read_menu_choice()

        if choice == 1
            show_balance(balance)
        elseif choice == 2
            balance = deposit(balance, history)
        elseif choice == 3
            balance = withdraw(balance, history)
        elseif choice == 4
            show_history(history)
        elseif choice == 5
            println("Thank you for using the Banking and Transaction System. Goodbye!")
            running = false
        else
            println("Error: Invalid choice. Please enter a number from 1 to 5.")
        end
    end
end

main()
