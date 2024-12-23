// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InterbankSettlement {
    // Events for logging transactions
    event TransactionInitiated(
        uint256 transactionId,
        address senderBank,
        address receiverBank,
        uint256 amount,
        uint256 timestamp
    );
    event TransactionSettled(
        uint256 transactionId,
        uint256 timestamp
    );

    // Struct to hold transaction details
    struct Transaction {
        uint256 transactionId;
        address senderBank;
        address receiverBank;
        uint256 amount;
        bool settled;
        uint256 timestamp;
    }

    // Mapping of transaction ID to transaction details
    mapping(uint256 => Transaction) public transactions;

    // Counter for transaction IDs
    uint256 private transactionCounter;

    // Only registered banks can interact with the contract
    mapping(address => bool) public registeredBanks;

    // Modifier to check if the caller is a registered bank
    modifier onlyRegisteredBank() {
        require(registeredBanks[msg.sender], "Caller is not a registered bank");
        _;
    }

    // Constructor to initialize the contract
    constructor(address[] memory initialBanks) {
        for (uint256 i = 0; i < initialBanks.length; i++) {
            registeredBanks[initialBanks[i]] = true;
        }
    }

    // Function to register a new bank
    function registerBank(address bank) external onlyRegisteredBank {
        registeredBanks[bank] = true;
    }

    // Function to initiate a transaction
    function initiateTransaction(address receiverBank, uint256 amount)
        external
        onlyRegisteredBank
        returns (uint256)
    {
        require(registeredBanks[receiverBank], "Receiver bank is not registered");
        require(amount > 0, "Amount must be greater than zero");

        // Increment transaction counter
        transactionCounter++;

        // Record transaction details
        transactions[transactionCounter] = Transaction({
            transactionId: transactionCounter,
            senderBank: msg.sender,
            receiverBank: receiverBank,
            amount: amount,
            settled: false,
            timestamp: block.timestamp
        });

        // Emit event
        emit TransactionInitiated(
            transactionCounter,
            msg.sender,
            receiverBank,
            amount,
            block.timestamp
        );

        return transactionCounter;
    }

    // Function to settle a transaction
    function settleTransaction(uint256 transactionId) external onlyRegisteredBank {
        Transaction storage txn = transactions[transactionId];

        require(!txn.settled, "Transaction is already settled");
        require(
            msg.sender == txn.receiverBank,
            "Only the receiving bank can settle this transaction"
        );

        // Mark the transaction as settled
        txn.settled = true;

        // Emit event
        emit TransactionSettled(transactionId, block.timestamp);
    }

    // Function to get transaction details
    function getTransactionDetails(uint256 transactionId)
        external
        view
        returns (
            address senderBank,
            address receiverBank,
            uint256 amount,
            bool settled,
            uint256 timestamp
        )
    {
        Transaction memory txn = transactions[transactionId];
        return (
            txn.senderBank,
            txn.receiverBank,
            txn.amount,
            txn.settled,
            txn.timestamp
        );
    }
}
