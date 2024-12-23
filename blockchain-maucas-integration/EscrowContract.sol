// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    // Events
    event EscrowCreated(
        uint256 escrowId,
        address indexed payer,
        address indexed payee,
        uint256 amount,
        uint256 timestamp
    );
    event EscrowFunded(uint256 escrowId, uint256 amount, uint256 timestamp);
    event PaymentReleased(uint256 escrowId, address indexed payee, uint256 amount, uint256 timestamp);
    event DisputeRaised(uint256 escrowId, address indexed initiator, string reason, uint256 timestamp);
    event DisputeResolved(uint256 escrowId, string resolution, uint256 timestamp);

    // Struct for Escrow
    struct EscrowDetails {
        uint256 escrowId;
        address payer;
        address payee;
        uint256 amount;
        bool isFunded;
        bool isCompleted;
        bool isDisputed;
    }

    // Counter for unique escrow IDs
    uint256 private escrowCounter;

    // Mapping for storing escrow details
    mapping(uint256 => EscrowDetails) public escrows;

    // Role management
    address public arbitrator;

    // Modifiers
    modifier onlyPayer(uint256 escrowId) {
        require(msg.sender == escrows[escrowId].payer, "Caller is not the payer");
        _;
    }

    modifier onlyArbitrator() {
        require(msg.sender == arbitrator, "Caller is not the arbitrator");
        _;
    }

    modifier escrowExists(uint256 escrowId) {
        require(escrows[escrowId].payer != address(0), "Escrow does not exist");
        _;
    }

    // Constructor to set arbitrator
    constructor(address _arbitrator) {
        arbitrator = _arbitrator;
    }

    // Function to create an escrow
    function createEscrow(address payee, uint256 amount) external returns (uint256) {
        require(amount > 0, "Escrow amount must be greater than zero");
        require(payee != address(0), "Invalid payee address");

        escrowCounter++;

        escrows[escrowCounter] = EscrowDetails({
            escrowId: escrowCounter,
            payer: msg.sender,
            payee: payee,
            amount: amount,
            isFunded: false,
            isCompleted: false,
            isDisputed: false
        });

        emit EscrowCreated(escrowCounter, msg.sender, payee, amount, block.timestamp);
        return escrowCounter;
    }

    // Function to fund an escrow
    function fundEscrow(uint256 escrowId) external payable onlyPayer(escrowId) escrowExists(escrowId) {
        EscrowDetails storage escrow = escrows[escrowId];
        require(msg.value == escrow.amount, "Incorrect funding amount");
        require(!escrow.isFunded, "Escrow is already funded");

        escrow.isFunded = true;

        emit EscrowFunded(escrowId, msg.value, block.timestamp);
    }

    // Function to release payment to the payee
    function releasePayment(uint256 escrowId) external onlyPayer(escrowId) escrowExists(escrowId) {
        EscrowDetails storage escrow = escrows[escrowId];
        require(escrow.isFunded, "Escrow is not funded");
        require(!escrow.isCompleted, "Escrow is already completed");
        require(!escrow.isDisputed, "Escrow is under dispute");

        escrow.isCompleted = true;

        payable(escrow.payee).transfer(escrow.amount);

        emit PaymentReleased(escrowId, escrow.payee, escrow.amount, block.timestamp);
    }

    // Function to raise a dispute
    function raiseDispute(uint256 escrowId, string calldata reason) external escrowExists(escrowId) {
        EscrowDetails storage escrow = escrows[escrowId];
        require(msg.sender == escrow.payer || msg.sender == escrow.payee, "Caller is not part of the escrow");
        require(!escrow.isCompleted, "Escrow is already completed");
        require(!escrow.isDisputed, "Dispute is already raised");

        escrow.isDisputed = true;

        emit DisputeRaised(escrowId, msg.sender, reason, block.timestamp);
    }

    // Function to resolve a dispute
    function resolveDispute(uint256 escrowId, string calldata resolution, bool favorPayee) 
        external 
        onlyArbitrator 
        escrowExists(escrowId) 
    {
        EscrowDetails storage escrow = escrows[escrowId];
        require(escrow.isDisputed, "No dispute to resolve");

        escrow.isCompleted = true;
        escrow.isDisputed = false;

        if (favorPayee) {
            payable(escrow.payee).transfer(escrow.amount);
        } else {
            payable(escrow.payer).transfer(escrow.amount);
        }

        emit DisputeResolved(escrowId, resolution, block.timestamp);
    }

    // Function to get escrow details
    function getEscrowDetails(uint256 escrowId)
        external
        view
        returns (
            address payer,
            address payee,
            uint256 amount,
            bool isFunded,
            bool isCompleted,
            bool isDisputed
        )
    {
        EscrowDetails memory escrow = escrows[escrowId];
        return (
            escrow.payer,
            escrow.payee,
            escrow.amount,
            escrow.isFunded,
            escrow.isCompleted,
            escrow.isDisputed
        );
    }
}
