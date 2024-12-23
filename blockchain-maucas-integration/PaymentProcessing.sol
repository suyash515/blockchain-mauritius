// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentProcessing {
    // Events
    event PaymentInitiated(
        uint256 paymentId,
        address indexed payer,
        address indexed payee,
        uint256 amount,
        uint256 timestamp
    );
    event PaymentCompleted(
        uint256 paymentId,
        address indexed payer,
        address indexed payee,
        uint256 amount,
        uint256 timestamp
    );
    event DisputeRaised(
        uint256 paymentId,
        address indexed payer,
        address indexed payee,
        string reason,
        uint256 timestamp
    );
    event DisputeResolved(
        uint256 paymentId,
        bool favorPayer,
        string resolutionDetails,
        uint256 timestamp
    );

    // Struct for Payment
    struct Payment {
        uint256 paymentId;
        address payer;
        address payee;
        uint256 amount;
        bool isCompleted;
        bool isDisputed;
    }

    // Counter for unique payment IDs
    uint256 private paymentCounter;

    // Mapping of payment IDs to payment details
    mapping(uint256 => Payment) public payments;

    // Fee percentage (e.g., 2% as 200 basis points)
    uint256 public feeBasisPoints = 200; // Default fee is 2%

    // Address to collect fees
    address public feeCollector;

    // Modifier to restrict access to feeCollector for certain actions
    modifier onlyFeeCollector() {
        require(msg.sender == feeCollector, "Caller is not the fee collector");
        _;
    }

    // Constructor to set the fee collector
    constructor(address _feeCollector) {
        feeCollector = _feeCollector;
    }

    // Function to update fee percentage (only by fee collector)
    function updateFeeBasisPoints(uint256 newFeeBasisPoints) external onlyFeeCollector {
        require(newFeeBasisPoints <= 1000, "Fee cannot exceed 10%");
        feeBasisPoints = newFeeBasisPoints;
    }

    // Function to initiate a payment
    function initiatePayment(address payee) external payable returns (uint256) {
        require(msg.value > 0, "Payment amount must be greater than zero");
        require(payee != address(0), "Invalid payee address");

        // Increment payment counter
        paymentCounter++;

        // Record payment details
        payments[paymentCounter] = Payment({
            paymentId: paymentCounter,
            payer: msg.sender,
            payee: payee,
            amount: msg.value,
            isCompleted: false,
            isDisputed: false
        });

        // Emit payment initiated event
        emit PaymentInitiated(paymentCounter, msg.sender, payee, msg.value, block.timestamp);

        return paymentCounter;
    }

    // Function to complete a payment
    function completePayment(uint256 paymentId) external {
        Payment storage payment = payments[paymentId];
        require(msg.sender == payment.payee, "Only the payee can complete the payment");
        require(!payment.isCompleted, "Payment is already completed");
        require(!payment.isDisputed, "Payment is under dispute");

        uint256 fee = (payment.amount * feeBasisPoints) / 10000;
        uint256 netAmount = payment.amount - fee;

        // Transfer the net amount to the payee
        payable(payment.payee).transfer(netAmount);

        // Transfer the fee to the fee collector
        payable(feeCollector).transfer(fee);

        // Mark the payment as completed
        payment.isCompleted = true;

        // Emit payment completed event
        emit PaymentCompleted(paymentId, payment.payer, payment.payee, netAmount, block.timestamp);
    }

    // Function to raise a dispute
    function raiseDispute(uint256 paymentId, string calldata reason) external {
        Payment storage payment = payments[paymentId];
        require(msg.sender == payment.payer, "Only the payer can raise a dispute");
        require(!payment.isCompleted, "Cannot dispute a completed payment");
        require(!payment.isDisputed, "Payment is already under dispute");

        // Mark the payment as disputed
        payment.isDisputed = true;

        // Emit dispute raised event
        emit DisputeRaised(paymentId, payment.payer, payment.payee, reason, block.timestamp);
    }

    // Function to resolve a dispute (only fee collector)
    function resolveDispute(
        uint256 paymentId,
        bool favorPayer,
        string calldata resolutionDetails
    ) external onlyFeeCollector {
        Payment storage payment = payments[paymentId];
        require(payment.isDisputed, "Payment is not under dispute");

        if (favorPayer) {
            // Refund the amount to the payer
            payable(payment.payer).transfer(payment.amount);
        } else {
            uint256 fee = (payment.amount * feeBasisPoints) / 10000;
            uint256 netAmount = payment.amount - fee;

            // Transfer the net amount to the payee
            payable(payment.payee).transfer(netAmount);

            // Transfer the fee to the fee collector
            payable(feeCollector).transfer(fee);
        }

        // Mark the payment as completed
        payment.isCompleted = true;
        payment.isDisputed = false;

        // Emit dispute resolved event
        emit DisputeResolved(paymentId, favorPayer, resolutionDetails, block.timestamp);
    }
}
