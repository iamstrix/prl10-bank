!===============================================================================
! Banking and Transaction Management System  (Fortran 2008 version)
!
! Compile:  gfortran -std=f2008 -Wall -o bank bank.f90
! Run:      ./bank            (Windows: bank.exe)
!
! CONCEPT MAP  (where each required concept appears in this file)
! ---------------------------------------------------------------------------
! Variables with explicit types  : "implicit none" everywhere; real(8) for money
!                                  (balance, amount), integer for counters and
!                                  menu choice, character for input lines.
!                                  See the main program "bank" and every procedure.
! Constants                      : STARTING_BALANCE, MAX_AMOUNT, LINE_LEN in the
!                                  module bank_procedures.
! Arithmetic operators           : deposit (balance + amount), withdraw
!                                  (balance - amount), round_cents (* and /),
!                                  add_transaction (2 * size, count + 1).
! Comparison operators           : read_amount (< 0, == 0, > MAX_AMOUNT),
!                                  withdraw (amount > balance),
!                                  is_digits / looks_like_number (>= '0', <= '9').
! if / else                      : read_amount, withdraw, show_history, read_line.
! select case                    : main program menu loop (choice 1..5, default).
! Loops                          : main program "do while (running)" menu loop;
!                                  read_amount "do while (.not. valid)" re-prompt
!                                  loop; "do i = ..." loops in show_history,
!                                  read_line, is_digits, looks_like_number.
! Functions                      : read_menu_choice, read_amount, format_money,
!                                  round_cents, is_digits, looks_like_number,
!                                  count_decimals.
! Subroutines                    : show_menu, show_balance, deposit, withdraw,
!                                  show_history, add_transaction, read_line.
! Data structure (record type)   : derived type "Transaction" with fields
!                                  type, amount, balance_after.
! Growing allocatable array      : "history" in the main program; it is grown
!                                  in add_transaction using move_alloc.
! Safe input / error handling    : read_line reads text first (EOF -> clean exit);
!                                  read_menu_choice and read_amount convert with
!                                  read(..., iostat=ios) and check ios.
!===============================================================================

module bank_procedures
    use, intrinsic :: iso_fortran_env, only: output_unit
    implicit none

    ! ----- Constants -----
    real(8), parameter :: STARTING_BALANCE = 5000.00d0
    real(8), parameter :: MAX_AMOUNT = 1000000.00d0   ! limit per transaction
    integer, parameter :: LINE_LEN = 256               ! max characters per input line
    integer, parameter :: INITIAL_CAPACITY = 4         ! first size of history array

    ! ----- Data structure: one transaction record -----
    type :: Transaction
        character(len=10) :: type            ! "Deposit" or "Withdrawal"
        real(8)           :: amount          ! amount of money moved
        real(8)           :: balance_after   ! balance right after this transaction
    end type Transaction

contains

    !---------------------------------------------------------------------------
    ! read_line: read one line of text from the keyboard (or a piped file).
    ! Tabs and carriage returns become spaces, and leading spaces are removed.
    ! If there is no more input (EOF), print a message and end the program.
    !---------------------------------------------------------------------------
    subroutine read_line(line)
        character(len=*), intent(out) :: line
        integer :: ios, i

        read(*, '(a)', iostat=ios) line
        if (ios /= 0) then
            write(*, '(a)') ''
            write(*, '(a)') 'End of input reached. Exiting program.'
            stop
        end if

        do i = 1, len(line)
            if (line(i:i) == achar(9) .or. line(i:i) == achar(13)) then
                line(i:i) = ' '
            end if
        end do
        line = adjustl(line)

        ! Move to a fresh line so the next message does not follow the prompt.
        write(*, '(a)') ''
    end subroutine read_line

    !---------------------------------------------------------------------------
    ! is_digits: .true. if text is not empty and contains only 0-9.
    !---------------------------------------------------------------------------
    logical function is_digits(text)
        character(len=*), intent(in) :: text
        integer :: i

        is_digits = (len(text) > 0)
        do i = 1, len(text)
            if (text(i:i) < '0' .or. text(i:i) > '9') then
                is_digits = .false.
            end if
        end do
    end function is_digits

    !---------------------------------------------------------------------------
    ! looks_like_number: .true. if text is an optional + or - sign followed by
    ! digits with at most one decimal point (for example 1500, 250.75, -20).
    ! This keeps the Fortran and Julia versions accepting exactly the same input.
    !---------------------------------------------------------------------------
    logical function looks_like_number(text)
        character(len=*), intent(in) :: text
        integer :: i, start, num_digits, num_dots

        looks_like_number = .false.
        if (len(text) == 0) return

        start = 1
        if (text(1:1) == '+' .or. text(1:1) == '-') start = 2

        num_digits = 0
        num_dots = 0
        do i = start, len(text)
            if (text(i:i) >= '0' .and. text(i:i) <= '9') then
                num_digits = num_digits + 1
            else if (text(i:i) == '.') then
                num_dots = num_dots + 1
            else
                return              ! any other character: not a number
            end if
        end do

        looks_like_number = (num_digits > 0 .and. num_dots <= 1)
    end function looks_like_number

    !---------------------------------------------------------------------------
    ! count_decimals: number of characters after the decimal point (0 if none).
    !---------------------------------------------------------------------------
    integer function count_decimals(text)
        character(len=*), intent(in) :: text
        integer :: dot_position

        dot_position = index(text, '.')
        if (dot_position == 0) then
            count_decimals = 0
        else
            count_decimals = len(text) - dot_position
        end if
    end function count_decimals

    !---------------------------------------------------------------------------
    ! round_cents: round a money value to the nearest centavo (2 decimals),
    ! so tiny floating-point errors never build up in the balance.
    !---------------------------------------------------------------------------
    real(8) function round_cents(x)
        real(8), intent(in) :: x
        round_cents = anint(x * 100.0d0) / 100.0d0
    end function round_cents

    !---------------------------------------------------------------------------
    ! format_money: turn 5000.0 into the text "PHP 5000.00".
    !---------------------------------------------------------------------------
    function format_money(x) result(text)
        real(8), intent(in) :: x
        character(len=:), allocatable :: text
        character(len=20) :: buffer

        write(buffer, '(f20.2)') x
        text = 'PHP ' // trim(adjustl(buffer))
    end function format_money

    !---------------------------------------------------------------------------
    ! show_menu: print the main menu (the prompt is printed by read_menu_choice).
    !---------------------------------------------------------------------------
    subroutine show_menu()
        write(*, '(a)') ''
        write(*, '(a)') '---------------- MAIN MENU ----------------'
        write(*, '(a)') '1. Check Balance'
        write(*, '(a)') '2. Deposit Money'
        write(*, '(a)') '3. Withdraw Money'
        write(*, '(a)') '4. View Transaction History'
        write(*, '(a)') '5. Exit'
    end subroutine show_menu

    !---------------------------------------------------------------------------
    ! read_menu_choice: ask for a menu choice and return it as an integer.
    ! Returns -1 if the input is empty or not a whole number; the main program
    ! then shows an error and redisplays the menu.
    !---------------------------------------------------------------------------
    integer function read_menu_choice()
        character(len=LINE_LEN) :: line
        integer :: ios

        write(*, '(a)', advance='no') 'Enter your choice (1-5): '
        flush(output_unit)
        call read_line(line)

        read_menu_choice = -1
        if (is_digits(trim(line))) then
            read(line, *, iostat=ios) read_menu_choice
            if (ios /= 0) read_menu_choice = -1     ! e.g. number too large
        end if
    end function read_menu_choice

    !---------------------------------------------------------------------------
    ! read_amount: keep asking until the user types a valid positive amount.
    ! Each kind of mistake gets its own error message.
    !---------------------------------------------------------------------------
    real(8) function read_amount(prompt)
        character(len=*), intent(in) :: prompt
        character(len=LINE_LEN) :: line
        integer :: ios
        logical :: valid

        read_amount = 0.0d0
        valid = .false.

        do while (.not. valid)
            write(*, '(a)', advance='no') prompt
            flush(output_unit)
            call read_line(line)

            if (len_trim(line) == 0) then
                write(*, '(a)') 'Error: No amount entered. Please type a number.'
            else if (.not. looks_like_number(trim(line))) then
                write(*, '(a)') 'Error: Invalid amount. Please enter a number such as 1500 or 250.75.'
            else
                ! The text looks like a number, so convert it safely.
                read(line, *, iostat=ios) read_amount
                if (ios /= 0) then
                    write(*, '(a)') 'Error: Invalid amount. Please enter a number such as 1500 or 250.75.'
                else if (read_amount < 0.0d0) then
                    write(*, '(a)') 'Error: Negative amounts are not allowed.'
                else if (read_amount == 0.0d0) then
                    write(*, '(a)') 'Error: Amount must be greater than zero.'
                else if (count_decimals(trim(line)) > 2) then
                    write(*, '(a)') 'Error: Amount can have at most 2 decimal places.'
                else if (read_amount > MAX_AMOUNT) then
                    write(*, '(a)') 'Error: Amount exceeds the limit of ' // format_money(MAX_AMOUNT) &
                                    // ' per transaction.'
                else
                    valid = .true.
                end if
            end if
        end do
    end function read_amount

    !---------------------------------------------------------------------------
    ! show_balance: print the current balance.
    !---------------------------------------------------------------------------
    subroutine show_balance(balance)
        real(8), intent(in) :: balance
        write(*, '(a)') 'Current balance: ' // format_money(balance)
    end subroutine show_balance

    !---------------------------------------------------------------------------
    ! add_transaction: append a record to the history array.
    ! If the array is full, make a new array twice as big, copy the old records,
    ! and hand it over to "history" with move_alloc.
    !---------------------------------------------------------------------------
    subroutine add_transaction(history, count, ttype, amount, balance_after)
        type(Transaction), allocatable, intent(inout) :: history(:)
        integer, intent(inout) :: count
        character(len=*), intent(in) :: ttype
        real(8), intent(in) :: amount, balance_after
        type(Transaction), allocatable :: bigger(:)

        if (count == size(history)) then
            allocate(bigger(2 * size(history)))
            bigger(1:count) = history(1:count)
            call move_alloc(bigger, history)    ! bigger is deallocated afterwards
        end if

        count = count + 1
        history(count) = Transaction(ttype, amount, balance_after)
    end subroutine add_transaction

    !---------------------------------------------------------------------------
    ! deposit: read a valid amount, add it to the balance, record it.
    !---------------------------------------------------------------------------
    subroutine deposit(balance, history, count)
        real(8), intent(inout) :: balance
        type(Transaction), allocatable, intent(inout) :: history(:)
        integer, intent(inout) :: count
        real(8) :: amount

        write(*, '(a)') '--- Deposit Money ---'
        amount = read_amount('Enter amount to deposit: ')

        balance = round_cents(balance + amount)
        call add_transaction(history, count, 'Deposit', amount, balance)

        write(*, '(a)') 'Deposit successful. Amount deposited: ' // format_money(amount)
        write(*, '(a)') 'New balance: ' // format_money(balance)
    end subroutine deposit

    !---------------------------------------------------------------------------
    ! withdraw: read a valid amount; if it is more than the balance, cancel.
    ! Otherwise subtract it from the balance and record it.
    !---------------------------------------------------------------------------
    subroutine withdraw(balance, history, count)
        real(8), intent(inout) :: balance
        type(Transaction), allocatable, intent(inout) :: history(:)
        integer, intent(inout) :: count
        real(8) :: amount

        write(*, '(a)') '--- Withdraw Money ---'
        amount = read_amount('Enter amount to withdraw: ')

        if (amount > balance) then
            ! Overdraft: nothing changes and nothing is recorded.
            write(*, '(a)') 'Error: Insufficient funds. Your current balance is ' &
                            // format_money(balance) // '.'
            write(*, '(a)') 'Withdrawal cancelled.'
        else
            balance = round_cents(balance - amount)
            call add_transaction(history, count, 'Withdrawal', amount, balance)

            write(*, '(a)') 'Withdrawal successful. Amount withdrawn: ' // format_money(amount)
            write(*, '(a)') 'New balance: ' // format_money(balance)
        end if
    end subroutine withdraw

    !---------------------------------------------------------------------------
    ! show_history: print all successful transactions as an aligned table.
    !---------------------------------------------------------------------------
    subroutine show_history(history, count)
        type(Transaction), intent(in) :: history(:)
        integer, intent(in) :: count
        integer :: i

        write(*, '(a)') '--- Transaction History ---'
        if (count == 0) then
            write(*, '(a)') 'No transactions yet.'
        else
            write(*, '(a)') 'No.  Type                  Amount     Balance After'
            write(*, '(a)') '---  ----------  ----------------  ----------------'
            do i = 1, count
                write(*, '(i3, 2x, a10, 2x, "PHP ", f12.2, 2x, "PHP ", f12.2)') &
                    i, history(i)%type, history(i)%amount, history(i)%balance_after
            end do
            write(*, '(a, i0)') 'Total transactions: ', count
        end if
    end subroutine show_history

end module bank_procedures


!===============================================================================
! Main program: set up the account, then run the menu loop until Exit.
!===============================================================================
program bank
    use bank_procedures
    implicit none

    real(8) :: balance                              ! current account balance
    type(Transaction), allocatable :: history(:)    ! successful transactions
    integer :: num_transactions                     ! how many are stored
    integer :: choice                               ! menu choice typed by user
    logical :: running                              ! .false. when user exits

    ! ----- Account initialization -----
    balance = STARTING_BALANCE
    num_transactions = 0
    allocate(history(INITIAL_CAPACITY))

    write(*, '(a)') '==========================================='
    write(*, '(a)') '      BANKING AND TRANSACTION SYSTEM'
    write(*, '(a)') '==========================================='
    write(*, '(a)') 'Account initialized.'
    write(*, '(a)') 'Starting balance: ' // format_money(balance)

    ! ----- Main menu loop -----
    running = .true.
    do while (running)
        call show_menu()
        choice = read_menu_choice()

        select case (choice)
        case (1)
            call show_balance(balance)
        case (2)
            call deposit(balance, history, num_transactions)
        case (3)
            call withdraw(balance, history, num_transactions)
        case (4)
            call show_history(history, num_transactions)
        case (5)
            write(*, '(a)') 'Thank you for using the Banking and Transaction System. Goodbye!'
            running = .false.
        case default
            write(*, '(a)') 'Error: Invalid choice. Please enter a number from 1 to 5.'
        end select
    end do

end program bank
