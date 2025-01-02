// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InterServicePayment {
    struct Payment {
        uint256 amount;
        address payer;
        address recipient;
        uint256 timestamp;
        bool settled;
    }

    uint256 private paymentCounter;
    mapping(uint256 => Payment) private payments;
    mapping(address => uint256) private balances;

    event PaymentInitiated(uint256 indexed paymentId, address indexed payer, address indexed recipient, uint256 amount, uint256 timestamp);
    event PaymentSettled(uint256 indexed paymentId, uint256 timestamp);

    // Initiate a payment
    function initiatePayment(address _recipient) public payable {
        require(_recipient != address(0), "Invalid recipient address");
        require(msg.value > 0, "Payment amount must be greater than zero");

        paymentCounter++;
        payments[paymentCounter] = Payment({
            amount: msg.value,
            payer: msg.sender,
            recipient: _recipient,
            timestamp: block.timestamp,
            settled: false
        });

        balances[_recipient] += msg.value;

        emit PaymentInitiated(paymentCounter, msg.sender, _recipient, msg.value, block.timestamp);
    }

    // Settle a payment
    function settlePayment(uint256 _paymentId) public {
        Payment storage payment = payments[_paymentId];
        require(payment.recipient == msg.sender, "Not authorized to settle this payment");
        require(!payment.settled, "Payment already settled");

        payment.settled = true;

        emit PaymentSettled(_paymentId, block.timestamp);
    }

    // View payment details
    function getPaymentDetails(uint256 _paymentId) public view returns (
        uint256 amount,
        address payer,
        address recipient,
        uint256 timestamp,
        bool settled
    ) {
        Payment memory payment = payments[_paymentId];
        require(payment.amount > 0, "Payment does not exist");

        return (payment.amount, payment.payer, payment.recipient, payment.timestamp, payment.settled);
    }

    // View balance of a recipient
    function getBalance(address _recipient) public view returns (uint256) {
        return balances[_recipient];
    }

    // Withdraw balance
    function withdrawBalance() public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No funds available for withdrawal");

        balances[msg.sender] = 0;
        payable(msg.sender).transfer(balance);
    }
}
