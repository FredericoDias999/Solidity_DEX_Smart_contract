buyDex

    _dexSwapRate=30
    _paymentCycle=999999999
    _interestRate=10
    _terminationFee=50
    _maxLoanDuration=40

    Transact Value = 10000
    buy_Dex Value = 3000
buyDex

    _dexSwapRate=30
    _paymentCycle=999999999
    _interestRate=10
    _terminationFee=50
    _maxLoanDuration=40

    Transact Value = 10000
    buy_Dex Value = 3000

sellDex

    _dexSwapRate=30
    _paymentCycle=999999999
    _interestRate=10
    _terminationFee=50
    _maxLoanDuration=40

    Transact Value = 10000
    buy_Dex Value = 300
    getDexBalance
    sell_Dex dexAmount = value of getDexBalance or less

loan

    _dexSwapRate=30
    _paymentCycle=999999999
    _interestRate=10
    _terminationFee=50
    _maxLoanDuration=40

    Transact Value = 10000
    buy_Dex Value = 3000
    Approve (spender = id_conta, value = 100000000000000000000)
    Loan (dexAmount = 100000000000000000000, deadline = 3)

makePayment

    _dexSwapRate=30
    _paymentCycle=999999999
    _interestRate=10
    _terminationFee=50
    _maxLoanDuration=40

    Transact Value = 10000
    buy_Dex Value = 3000
    Approve (spender = id_conta, value = 100000000000000000000)
    Loan (dexAmount = 100000000000000000000, deadline = 3)
    MakePayment(loanid, value = 50 until last cycle, when we put 1550)


    _dexSwapRate=30
    _paymentCycle=999999999
    _interestRate=10
    _terminationFee=50
    _maxLoanDuration=40

    Transact Value = 10000
    buy_Dex Value = 3000
    Approve (spender = id_conta, value = 100000000000000000000)
    Loan (dexAmount = 100000000000000000000, deadline = 3)
    MakePayment(loanid, value = 50 until last cycle, when we put 1550)


terminateLoan

    _dexSwapRate=30
    _paymentCycle=999999999
    _interestRate=10
    _terminationFee=50
    _maxLoanDuration=40

    Transact Value = 10000
    buy_Dex Value = 300
    Approve (spender = id_conta, value = 100000000000000000000)
    Loan (dexAmount = 100000000000000000000, deadline = 20)
    TerminateLoan(value = 200, loanid)

    _dexSwapRate=30
    _paymentCycle=999999999
    _interestRate=10
    _terminationFee=50
    _maxLoanDuration=40

    Transact Value = 10000
    buy_Dex Value = 300
    Approve (spender = id_conta, value = 100000000000000000000)
    Loan (dexAmount = 100000000000000000000, deadline = 20)
    TerminateLoan(value = 200, loanid)

checkLoan

    _dexSwapRate=30
    _paymentCycle=999999999
    _interestRate=10
    _terminationFee=50
    _maxLoanDuration=40

    Transact Value = 10000
    buy_Dex Value = 3000
    Approve (spender = id_conta, value = 100000000000000000000)
    Loan (dexAmount = 100000000000000000000, deadline = 3)
    check_loan(loanid)

    _dexSwapRate=30
    _paymentCycle=999999999
    _interestRate=10
    _terminationFee=50
    _maxLoanDuration=40

    Transact Value = 10000
    buy_Dex Value = 3000
    Approve (spender = id_conta, value = 100000000000000000000)
    Loan (dexAmount = 100000000000000000000, deadline = 3)
    check_loan(loanid)

getBalance

    Click getBalance

    Click getBalance

getDexBalance

    Click getDexBalance

    Click getDexBalance