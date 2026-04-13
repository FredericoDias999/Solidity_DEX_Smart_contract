buyDex    
    Buy DEX with valid ETH amount
    Try with VALUE = 0 Wei → should fail with "Tem de enviar ETH para comprar DEX"
    Try to buy more DEX than the contract has → should fail with "O contrato nao tem DEX suficiente"

sellDex
    Sell valid amount of DEX
    Try with dexAmount = 0 → should fail with "A quantidade de DEX tem de ser maior que zero"
    Try to sell more DEX than you own → should fail with "Saldo de DEX insuficiente"
    Try to sell when contract has no ETH → should fail with "O contrato nao tem saldo de ETH suficiente"

loan    
    Create loan with valid DEX collateral and deadline
    Try with dexAmount = 0 → should fail
    Try with deadline = 0 or deadline > maxLoanDuration → should fail
    Try without enough DEX balance → should fail
    Try when contract has no ETH liquidity → should fail

makePayment
    Pay a valid cycle instalment on time
    Try on inactive/non-existent loan → should fail
    Try from a different account → should fail
    Try after deadline expires → should fail
    Try with wrong ETH amount → should fail
    Pay the last instalment → loan should close and DEX returned

terminateLoan
    Terminate active loan with correct ETH amount
    Try on inactive loan → should fail
    Try from wrong account → should fail
    Try with wrong ETH amount → should fail
    Try after payment deadline expired → should fail

checkLoan
    Call as owner after payment deadline expires → loan closed, collateral kept
    Call as non-owner → should fail with "Only owner can call this function"
    Call on inactive loan → should fail
    Call before deadline expires → should revert with "O emprestimo esta em dia"

getBalance
    Call as owner → returns contract ETH balance
    Call from non-owner account → should fail with "Only owner can call this function"

getDexBalance
    Call after buying DEX → returns correct balance
    Call with no DEX → returns 0