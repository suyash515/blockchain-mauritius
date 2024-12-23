// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStablecoin {
    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract CrossBorderPayment {
    // Events
    event PaymentInitiated(
        uint256 paymentId,
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        uint256 timestamp
    );
    event PaymentCompleted(
        uint256 paymentId,
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        uint256 timestamp
    );
    event PaymentRefunded(
        uint256 paymentId,
        address indexed sender,
        uint256 amount,
        uint256 timestamp
    );

    // Struct for Payment
    struct Payment {
        uint256 paymentId;
        address sender;
        address receiver;
        uint256 amount;
        bool completed;
        bool refunded;
    }

    // Payment counter for unique IDs
    uint256 private paymentCounter;

    // Mapping of payment IDs to payment details
    mapping(uint256 => Payment) public payments;

    // Stablecoin contract address
    IStablecoin public stablecoin;

    // Fee basis points (e.g., 1% = 100 basis points)
    uint256 public feeBasisPoints = 100; // Default fee is 1%

    // Address to collect fees
    address public feeCollector;

    // Modifier to restrict actions to fee collector
    modifier onlyFeeCollector() {
        require(msg.sender == feeCollector, "Caller is not the fee collector");
        _;
    }

    // Constructor to initialize stablecoin and fee collector
    constructor(address _stablecoin, address _feeCollector) {
        stablecoin = IStablecoin(_stablecoin);
        feeCollector = _feeCollector;
    }

    // Function to update fee percentage
    function updateFeeBasisPoints(uint256 newFeeBasisPoints) external onlyFeeCollector {
        require(newFeeBasisPoints <= 1000, "Fee cannot exceed 10%");
        feeBasisPoints = newFeeBasisPoints;
    }

    // Function to initiate a payment
    function initiatePayment(address receiver, uint256 amount) external returns (uint256) {
        require(amount > 0, "Payment amount must be greater than zero");
        require(receiver != address(0), "Invalid receiver address");

        // Calculate fee and net amount
        uint256 fee = (amount * feeBasisPoints) / 10000;
        uint256 netAmount = amount - fee;

        // Transfer stablecoins from sender to this contract
        require(stablecoin.transferFrom(msg.sender, address(this), amount), "Stablecoin transfer failed");

        // Increment payment counter
        paymentCounter++;

        // Record payment details
        payments[paymentCounter] = Payment({
            paymentId: paymentCounter,
            sender: msg.sender,
            receiver: receiver,
            amount: netAmount,
            completed: false,
            refunded: false
        });

        // Transfer the fee to the fee collector
        require(stablecoin.transfer(feeCollector, fee), "Fee transfer failed");

        emit PaymentInitiated(paymentCounter, msg.sender, receiver, netAmount, block.timestamp);
        return paymentCounter;
    }

    // Function to complete a payment
    function completePayment(uint256 paymentId) external {
        Payment storage payment = payments[paymentId];
        require(msg.sender == payment.receiver, "Only the receiver can complete the payment");
        require(!payment.completed, "Payment is already completed");
        require(!payment.refunded, "Payment is refunded");

        // Transfer stablecoins to the receiver
        require(stablecoin.transfer(payment.receiver, payment.amount), "Stablecoin transfer to receiver failed");

        // Mark payment as completed
        payment.completed = true;

        emit PaymentCompleted(paymentId, payment.sender, payment.receiver, payment.amount, block.timestamp);
    }

    // Function to refund a payment
    function refundPayment(uint256 paymentId) external onlyFeeCollector {
        Payment storage payment = payments[paymentId];
        require(!payment.completed, "Cannot refund a completed payment");
        require(!payment.refunded, "Payment is already refunded");

        // Refund stablecoins to the sender
        require(stablecoin.transfer(payment.sender, payment.amount), "Refund transfer failed");

        // Mark payment as refunded
        payment.refunded = true;

        emit PaymentRefunded(paymentId, payment.sender, payment.amount, block.timestamp);
    }

    // Function to get payment details
    function getPaymentDetails(uint256 paymentId)
        external
        view
        returns (
            address sender,
            address receiver,
            uint256 amount,
            bool completed,
            bool refunded
        )
    {
        Payment memory payment = payments[paymentId];
        return (
            payment.sender,
            payment.receiver,
            payment.amount,
            payment.completed,
            payment.refunded
        );
    }
}
