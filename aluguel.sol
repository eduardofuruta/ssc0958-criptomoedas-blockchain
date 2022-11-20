pragma solidity ^0.8.17;
contract ContratoAluguel {
    /* Estrutura de dados que guarda informações dos aluguéis pagos*/
    struct PaidRent {
    uint id; /* The paid rent id*/
    uint value; /* The amount of rent that is paid*/
    }

    PaidRent[] public paidrents;

    uint public createdTimestamp;

    uint public rent;
    /* Endereço real do imóvel - Rua, cidade, etc. Pode ser uma combinação de CEP + n° do imóvel*/
    string public house;

    /* Identificador do locador - dono do imóvel */
    address public landlord;

    /* Identificador do locatário - inquilino */
    address public tenant;
    
    /* Estado do contrato - Criado, Iniciado e Terminado 
       Quando o dono do imóvel coloca o imóvel para alugar basta ele criar o Smart Contract na blockchain (fazer o deploy) - State.Created
       O inquilino interessado que deseja alugar o imóvel ele chama a função alugar o imóvel e o contrato é iniciado - State.Started
       Quando o inquilino deixar o imóvel ou deixar de honrar com seus pagamentos o proprietário pode encerrar o contrato - State.Terminated
    */
    enum State {Created, Started, Terminated}
    State public state;

    /* Inicia os dados do contrato como o valor de aluguel e descrição do imóvel*/
    constructor() {
        rent = 1 ether;
        house = "Rua dos bobos num. 0";
        landlord = msg.sender;
        createdTimestamp = block.timestamp;
    }  
  
    /* Funções auxiliares para obter os dados do contrato Getters e Setters*/
    function getPaidRents() view internal returns (PaidRent[] memory) {
        return paidrents;
    }

    function getLandlord() view public returns (address) {
        return landlord;
    }

    function getTenant() view public returns (address) {
        return tenant;
    }

    function getRent() view public returns (uint) {
        return rent;
    }

    function getContractCreated() view public returns (uint) {
        return createdTimestamp;
    }

    function getState() view public returns (State) {
        return state;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    /* Events lançados por este contratos e utilizados pelas aplicações distribuídas (DApps) */
    event agreementConfirmed();

    event paidRent();

    event contractTerminated();

    /* Inicia o contrato de aluguel*/
    function alugarImovel() public {
        require(msg.sender != landlord);
        require(state == State.Created);
        emit agreementConfirmed();
        tenant = msg.sender;
        state = State.Started;
    }

    /* Inquilino paga o aluguel*/
    function payRent() payable public {
        require(msg.sender == tenant, "Nao eh o inquilino do contrato");
        require(state == State.Started);
        emit paidRent();
        require(msg.value == rent, "Valor pago diferente do aluguel");
        payable(landlord).transfer(msg.value);
        paidrents.push(PaidRent({
        id : paidrents.length + 1,
        value : msg.value
        }));
    }
    
    /* Proprietário finaliza o contrato */
    function terminateContract() public {
        require(msg.sender == landlord);
        emit contractTerminated();
        state = State.Terminated;   
    
    }
}