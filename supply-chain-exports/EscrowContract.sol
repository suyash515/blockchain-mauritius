// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EscrowContract {
    struct Escrow {
        string escrowId;
        address payer;
        address payee;
        uint256 amount;
        string status; // e.g., "Pending", "Released", "Refunded"
        bool isActive;
    }

    mapping(string => Escrow) private escrows;
    address public owner;

    event EscrowCreated(string escrowId, address payer, address payee, uint256 amount, string status);
    event EscrowReleased(string escrowId, uint256 amount);
    event EscrowRefunded(string escrowId, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createEscrow(
        string memory _escrowId,
        address _payer,
        address _payee,
        uint256 _amount
    ) public onlyOwner {
        require(bytes(_escrowId).length > 0, "Escrow ID cannot be empty.");
        require(_payer != address(0), "Invalid payer address.");
        require(_payee != address(0), "Invalid payee address.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(!escrows[_escrowId].isActive, "Escrow ID already exists.");

        escrows[_escrowId] = Escrow(_escrowId, _payer, _payee, _amount, "Pending", true);

        emit EscrowCreated(_escrowId, _payer, _payee, _amount, "Pending");
    }

    function releaseFunds(string memory _escrowId) public onlyOwner {
        require(bytes(_escrowId).length > 0, "Escrow ID cannot be empty.");
        require(escrows[_escrowId].isActive, "Escrow not found or inactive.");
        require(keccak256(bytes(escrows[_escrowId].status)) == keccak256(bytes("Pending")), "Escrow is not in a pending state.");

        address payee = escrows[_escrowId].payee;
        uint256 amount = escrows[_escrowId].amount;

        escrows[_escrowId].status = "Released";
        escrows[_escrowId].isActive = false;

        (bool sent, ) = payee.call{value: amount}("");
        require(sent, "Failed to send funds to payee.");

        emit EscrowReleased(_escrowId, amount);
    }

    function refundFunds(string memory _escrowId) public onlyOwner {
        require(bytes(_escrowId).length > 0, "Escrow ID cannot be empty.");
        require(escrows[_escrowId].isActive, "Escrow not found or inactive.");
        require(keccak256(bytes(escrows[_escrowId].status)) == keccak256(bytes("Pending")), "Escrow is not in a pending state.");

        address payer = escrows[_escrowId].payer;
        uint256 amount = escrows[_escrowId].amount;

        escrows[_escrowId].status = "Refunded";
        escrows[_escrowId].isActive = false;

        (bool sent, ) = payer.call{value: amount}("");
        require(sent, "Failed to refund funds to payer.");

        emit EscrowRefunded(_escrowId, amount);
    }

    function getEscrowDetails(string memory _escrowId)
        public
        view
        returns (
            address payer,
            address payee,
            uint256 amount,
            string memory status,
            bool isActive
        )
    {
        require(bytes(_escrowId).length > 0, "Escrow ID cannot be empty.");
        require(escrows[_escrowId].isActive, "Escrow not found or inactive.");

        Escrow memory escrow = escrows[_escrowId];
        return (escrow.payer, escrow.payee, escrow.amount, escrow.status, escrow.isActive);
    }

    receive() external payable {}
}

