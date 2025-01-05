// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartPaymentAndEscrow {
    enum EscrowStatus { Pending, Released, Refunded }

    struct Escrow {
        uint256 escrowId;
        address payer;
        address payee;
        uint256 amount;
        EscrowStatus status;
    }

    uint256 private escrowCounter;
    mapping(uint256 => Escrow) private escrows;

    event EscrowCreated(uint256 escrowId, address payer, address payee, uint256 amount);
    event PaymentReleased(uint256 escrowId, address payee);
    event PaymentRefunded(uint256 escrowId, address payer);

    modifier onlyPayer(uint256 escrowId) {
        require(escrows[escrowId].payer == msg.sender, "Only the payer can call this function.");
        _;
    }

    modifier onlyPayee(uint256 escrowId) {
        require(escrows[escrowId].payee == msg.sender, "Only the payee can call this function.");
        _;
    }

    modifier escrowExists(uint256 escrowId) {
        require(escrows[escrowId].status == EscrowStatus.Pending, "Escrow does not exist or is not pending.");
        _;
    }

    function createEscrow(address payee) public payable returns (uint256) {
        require(msg.value > 0, "Escrow amount must be greater than zero.");
        escrowCounter++;
        escrows[escrowCounter] = Escrow({
            escrowId: escrowCounter,
            payer: msg.sender,
            payee: payee,
            amount: msg.value,
            status: EscrowStatus.Pending
        });

        emit EscrowCreated(escrowCounter, msg.sender, payee, msg.value);
        return escrowCounter;
    }

    function releasePayment(uint256 escrowId) public escrowExists(escrowId) onlyPayer(escrowId) {
        Escrow storage escrow = escrows[escrowId];
        escrow.status = EscrowStatus.Released;

        payable(escrow.payee).transfer(escrow.amount);

        emit PaymentReleased(escrowId, escrow.payee);
    }

    function refundPayment(uint256 escrowId) public escrowExists(escrowId) onlyPayer(escrowId) {
        Escrow storage escrow = escrows[escrowId];
        escrow.status = EscrowStatus.Refunded;

        payable(escrow.payer).transfer(escrow.amount);

        emit PaymentRefunded(escrowId, escrow.payer);
    }

    function getEscrowDetails(uint256 escrowId) public view returns (
        uint256 id,
        address payer,
        address payee,
        uint256 amount,
        EscrowStatus status
    ) {
        Escrow memory escrow = escrows[escrowId];
        return (
            escrow.escrowId,
            escrow.payer,
            escrow.payee,
            escrow.amount,
            escrow.status
        );
    }
}
