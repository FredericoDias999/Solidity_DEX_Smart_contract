//Work done by:
//Frederico Dias nº59807
//Pedro Rosa nº60294
//Group 4

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Recomendo usar uma versão um pouco mais recente para maior segurança

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DecentralizedFinance is ERC20 {
    
    // --- Variáveis de Estado Requeridas ---
    address public owner; // Endereço de quem faz o deploy 
    uint256 public loanCounter; // Usado como ID único para os empréstimos 
    
    // Parâmetros do sistema (configurados no construtor) 
    uint256 public dexSwapRate; // Valor de 1 DEX em Wei 
    uint256 public paymentCycle; // Duração do ciclo (ex: 4 semanas ou 3 min) 
    uint256 public interestRate; // Taxa de juros do empréstimo
    uint256 public terminationFee; // Taxa fixa aplicada no cancelamento antecipado
    uint256 public maxLoanDuration; // Prazo máximo de um empréstimo 

    // --- Estrutura do Empréstimo  ---
    struct Loan {
        address borrower; // Endereço do utilizador com o empréstimo 
        uint256 collateral; // Quantidade de DEX usada como garantia 
        uint256 amount; // Quantidade de ETH (em Wei) emprestada 
        uint256 deadline; // Número de períodos (ciclos) do empréstimo
        
        // Variáveis extra de controlo necessárias para lógica de pagamentos e punições
        uint256 nextPaymentDue; // Timestamp que indica o limite para o próximo pagamento
        uint256 periodsPaid; // Quantos períodos já foram efetivamente pagos
        bool active; // Determina se o empréstimo ainda está em curso
    }

    // Mapeamento para guardar os empréstimos 
    mapping(uint256 => Loan) public loans;

    // --- Eventos ---
    event loanCreated(address borrower, uint256 amount, uint256 deadline); 
    event loanFinished(address borrower, uint256 amount); 

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // --- Construtor ---
    constructor(
        uint256 _dexSwapRate,
        uint256 _paymentCycle,
        uint256 _interestRate,
        uint256 _terminationFee,
        uint256 _maxLoanDuration
    ) ERC20("DEX", "DEX") payable { 
        owner = msg.sender;
        
        // Inicialização de variáveis pelo input
        dexSwapRate = _dexSwapRate;
        paymentCycle = _paymentCycle;
        interestRate = _interestRate;
        terminationFee = _terminationFee;
        maxLoanDuration = _maxLoanDuration;

        // O enunciado pede 10^18 DEX mintados. Como os ERC20 usam 18 casas decimais,
        // o valor real gerado é 10**18 * 10**decimals().
        _mint(address(this), 1000 * 10**decimals()); 
        //_mint(address(this), 10**18);
    }

    function buyDex() external payable {
        // Garantir que o utilizador enviou algum ETH
        require(msg.value > 0, "Tem de enviar ETH para comprar DEX.");

        // Calcular a quantidade de DEX.
        // Multiplicamos por 10**18 devido as casas decimais do token ERC20.
        uint256 dexAmount = (msg.value * 10**18) / dexSwapRate;

        // Garantir que o contrato tem DEX suficiente para vender
        require(balanceOf(address(this)) >= dexAmount, "O contrato nao tem DEX suficiente para esta venda.");

        // O contrato transfere os DEX do seu proprio saldo para o utilizador
        _transfer(address(this), msg.sender, dexAmount);
    }

    function sellDex(uint256 dexAmount) external {
        // Garantir que o utilizador quer vender uma quantidade valida
        require(dexAmount > 0, "A quantidade de DEX tem de ser maior que zero.");
        
        // Garantir que o utilizador tem realmente o DEX que quer vender
        require(balanceOf(msg.sender) >= dexAmount, "Saldo de DEX insuficiente.");

        // Calcular a quantidade de ETH (Wei) a devolver ao utilizador
        uint256 ethAmount = (dexAmount * dexSwapRate) / 10**18;

        // Verificar se o contrato tem saldo de ETH (Wei) suficiente para pagar 
        require(address(this).balance >= ethAmount, "O contrato nao tem saldo de ETH suficiente para esta transacao.");

        // 1. O contrato retira o DEX do utilizador e guarda para si
        _transfer(msg.sender, address(this), dexAmount);

        // 2. O contrato envia o ETH de volta para o utilizador de forma moderna e segura
        (bool success, ) = payable(msg.sender).call{value: ethAmount}("");
        require(success, "A transferencia de ETH falhou.");
    }

    function loan(uint256 dexAmount, uint256 deadline) external returns (uint256) {
        // 1. Validações iniciais de segurança
        require(dexAmount > 0, "A quantidade de colateral DEX tem de ser maior que zero.");
        require(deadline > 0 && deadline <= maxLoanDuration, "O prazo e invalido ou excede o limite maximo.");
        require(balanceOf(msg.sender) >= dexAmount, "Nao tem saldo DEX suficiente para usar como colateral.");

        // 2. Calcular o valor do colateral em ETH (Wei)
        // Multiplicar o DEX pela taxa e dividir pelas casas decimais (10^18)
        uint256 collateralValueInWei = (dexAmount * dexSwapRate) / 10**18;
        
        // 3. A regra dos 50%: O utilizador recebe metade do valor do colateral em ETH
        uint256 loanAmount = collateralValueInWei / 2;
        
        require(loanAmount > 0, "O valor do colateral e demasiado baixo para gerar um emprestimo.");
        require(address(this).balance >= loanAmount, "O contrato nao tem liquidez de ETH suficiente no momento.");

        // 4. Trancar o colateral: Transferir DEX do utilizador para o contrato
        _transfer(msg.sender, address(this), dexAmount);

        // 5. Registar o empréstimo
        uint256 currentLoanId = loanCounter;
        
        loans[currentLoanId] = Loan({
            borrower: msg.sender,
            collateral: dexAmount,
            amount: loanAmount,
            deadline: deadline,
            nextPaymentDue: block.timestamp + paymentCycle, // O relógio começa a contar agora!
            periodsPaid: 0,
            active: true
        });
        
        // Preparar o ID para o próximo empréstimo
        loanCounter++;

        // 6. Enviar o ETH (empréstimo) para o utilizador de forma moderna e segura
        (bool success, ) = payable(msg.sender).call{value: loanAmount}("");
        require(success, "A transferencia de ETH do emprestimo falhou.");

        // 7. Emitir o evento de criação de empréstimo
        emit loanCreated(msg.sender, loanAmount, deadline);

        // 8. Retornar o ID do empréstimo
        return currentLoanId;
    }

    function makePayment(uint256 loanId) external payable {
        // 1. Carregar o empréstimo da memória (usamos storage para poder alterar os valores)
        Loan storage currentLoan = loans[loanId];

        // 2. Validações de segurança
        require(currentLoan.active, "O emprestimo nao existe ou ja foi encerrado.");
        require(msg.sender == currentLoan.borrower, "Apenas o titular do emprestimo pode fazer o pagamento.");
        require(block.timestamp <= currentLoan.nextPaymentDue, "O prazo expirou. O colateral foi perdido.");

        // 3. Calcular o valor do pagamento periódico
        // Formula original: amount * interest / deadline
        // Dividimos por 100 assumindo que interestRate é uma percentagem inteira (ex: 10 para 10%)
        uint256 cyclePayment = (currentLoan.amount * interestRate) / (100 * currentLoan.deadline);
        
        uint256 totalToPay = cyclePayment;

        // 4. Verificar se é o último pagamento do empréstimo
        // Se os períodos pagos forem iguais ao prazo total menos 1, este é o último!
        bool isLastPayment = (currentLoan.periodsPaid == currentLoan.deadline - 1);

        if (isLastPayment) {
            // No último ciclo, o utilizador tem de devolver também o valor que pediu emprestado
            totalToPay += currentLoan.amount;
        }

        // 5. Garantir que o utilizador enviou a quantidade exata de ETH (Wei)
        require(msg.value == totalToPay, "O valor enviado em ETH nao corresponde ao valor da prestacao atual.");

        // 6. Atualizar o estado do empréstimo
        currentLoan.periodsPaid += 1;
        currentLoan.nextPaymentDue += paymentCycle; // Atualiza o relógio para o próximo ciclo

        // 7. Lógica de Encerramento (se for o último pagamento)
        if (isLastPayment) {
            currentLoan.active = false; // Desativa o empréstimo
            
            // Devolve o colateral (DEX) ao utilizador
            _transfer(address(this), currentLoan.borrower, currentLoan.collateral);
            
            // Emite o evento de conclusão exigido
            emit loanFinished(currentLoan.borrower, currentLoan.amount);
        }
    }

    function terminateLoan(uint256 loanId) external payable {
        // 1. Carregar o empréstimo da memória
        Loan storage currentLoan = loans[loanId];

        // 2. Validações de segurança
        require(currentLoan.active, "O emprestimo ja foi encerrado ou nao existe.");
        require(msg.sender == currentLoan.borrower, "Apenas o titular do emprestimo o pode terminar.");
        
        // Opcional: Garantir que não expirou por falta de pagamento
        require(block.timestamp <= currentLoan.nextPaymentDue, "O prazo expirou. O colateral foi perdido.");

        // 3. Calcular o valor total a pagar
        // O enunciado exige o pagamento total do empréstimo (amount) mais a taxa de cancelamento (terminationFee)
        uint256 totalToPay = currentLoan.amount + terminationFee;

        // 4. Verificar se o utilizador enviou o valor exato em ETH (Wei)
        require(msg.value == totalToPay, "Valor incorreto. Deve pagar a totalidade do emprestimo mais a taxa de terminacao.");

        // 5. Atualizar o estado do empréstimo
        currentLoan.active = false; // Desativa o empréstimo para não poder ser manipulado novamente

        // 6. Devolver a garantia (colateral) em DEX ao utilizador
        _transfer(address(this), currentLoan.borrower, currentLoan.collateral);

        // 7. Emitir o evento de finalização exigido pelo enunciado
        emit loanFinished(currentLoan.borrower, currentLoan.amount);
    }

    // --- Função de Polícia (apenas para o dono) ---
    function checkLoan(uint256 loanId) external onlyOwner {
        // 1. Carregar o empréstimo da memória
        Loan storage currentLoan = loans[loanId];

        // 2. Garantir que o empréstimo ainda está ativo
        require(currentLoan.active, "O emprestimo ja esta inativo ou foi concluido.");

        // 3. Verificar se o devedor falhou o prazo de pagamento
        if (block.timestamp > currentLoan.nextPaymentDue) {
            // PUNIÇÃO: O utilizador falhou o pagamento!
            // O empréstimo é encerrado e o colateral fica retido no contrato (é perdido pelo utilizador).
            currentLoan.active = false;
        } else {
            revert("O emprestimo esta em dia. Nenhuma punicao aplicada.");
        }
    }

    // --- Funções de Leitura (View) ---

    // Retorna o saldo total de ETH no contrato (apenas para o dono)
    function getBalance() external view onlyOwner returns (uint256) {
        return address(this).balance; // Retorna o saldo em Wei [cite: 108]
    }

    // Retorna a quantidade de tokens DEX que o utilizador possui
    function getDexBalance() external view returns (uint256) {
        return balanceOf(msg.sender); // Retorna o saldo DEX de quem chama a função 
    }

    receive() external payable {}
}