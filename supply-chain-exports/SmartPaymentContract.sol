// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartPaymentContract {
    struct Payment {
        string paymentId;
        string payer;
        string payee;
        uint256 amount;
        string paymentDate;
        string status; // e.g., "Pending", "Completed", "Failed"
    }

    mapping(string => Payment) private payments;
    address public owner;

    event PaymentCreated(string paymentId, string payer, string payee, uint256 amount, string status);
    event PaymentCompleted(string paymentId, string paymentDate);
    event PaymentFailed(string paymentId, string reason);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createPayment(
        string memory _paymentId,
        string memory _payer,
        string memory _payee,
        uint256 _amount
    ) public onlyOwner {
        require(bytes(_paymentId).length > 0, "Payment ID cannot be empty.");
        require(bytes(_payer).length > 0, "Payer cannot be empty.");
        require(bytes(_payee).length > 0, "Payee cannot be empty.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(bytes(payments[_paymentId].paymentId).length == 0, "Payment ID already exists.");

        payments[_paymentId] = Payment(_paymentId, _payer, _payee, _amount, "", "Pending");

        emit PaymentCreated(_paymentId, _payer, _payee, _amount, "Pending");
    }

    function completePayment(string memory _paymentId, string memory _paymentDate) public onlyOwner {
        require(bytes(_paymentId).length > 0, "Payment ID cannot be empty.");
        require(bytes(_paymentDate).length > 0, "Payment date cannot be empty.");
        require(bytes(payments[_paymentId].paymentId).length > 0, "Payment not found.");
        require(keccak256(bytes(payments[_paymentId].status)) == keccak256(bytes("Pending")), "Payment is not pending.");

        payments[_paymentId].status = "Completed";
        payments[_paymentId].paymentDate = _paymentDate;

        emit PaymentCompleted(_paymentId, _paymentDate);
    }

    function failPayment(string memory _paymentId, string memory _reason) public onlyOwner {
        require(bytes(_paymentId).length > 0, "Payment ID cannot be empty.");
        require(bytes(_reason).length > 0, "Reason cannot be empty.");
        require(bytes(payments[_paymentId].paymentId).length > 0, "Payment not found.");
        require(keccak256(bytes(payments[_paymentId].status)) == keccak256(bytes("Pending")), "Payment is not pending.");

        payments[_paymentId].status = "Failed";

        emit PaymentFailed(_paymentId, _reason);
    }

    function getPaymentDetails(string memory _paymentId)
        public
        view
        returns (
            string memory payer,
            string memory payee,
            uint256 amount,
            string memory paymentDate,
            string memory status
        )
    {
        require(bytes(_paymentId).length > 0, "Payment ID cannot be empty.");
        require(bytes(payments[_paymentId].paymentId).length > 0, "Payment not found.");

        Payment memory payment = payments[_paymentId];
        return (
            payment.payer,
            payment.payee,
            payment.amount,
            payment.paymentDate,
            payment.status
        );
    }
}

