// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ComplianceAndAudit {
    // Events
    event TransactionRecorded(
        uint256 transactionId,
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        uint256 timestamp,
        string transactionType,
        string metadata
    );
    event AuditReportGenerated(uint256 auditId, address indexed auditor, uint256 timestamp);

    // Struct for storing transaction details
    struct Transaction {
        uint256 transactionId;
        address sender;
        address receiver;
        uint256 amount;
        uint256 timestamp;
        string transactionType; // e.g., "Payment", "Settlement"
        string metadata; // Additional information about the transaction
    }

    // Struct for storing audit report details
    struct AuditReport {
        uint256 auditId;
        address auditor;
        uint256 timestamp;
        string reportHash; // IPFS or hash of the audit report
    }

    // Counter for unique transaction and audit IDs
    uint256 private transactionCounter;
    uint256 private auditCounter;

    // Mappings for storing transactions and audit reports
    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => AuditReport) public auditReports;

    // Role management
    mapping(address => bool) public authorizedAuditors;
    mapping(address => bool) public authorizedOperators;

    // Modifiers
    modifier onlyAuditor() {
        require(authorizedAuditors[msg.sender], "Caller is not an authorized auditor");
        _;
    }

    modifier onlyOperator() {
        require(authorizedOperators[msg.sender], "Caller is not an authorized operator");
        _;
    }

    // Constructor to set initial authorized operators
    constructor(address[] memory operators, address[] memory auditors) {
        for (uint256 i = 0; i < operators.length; i++) {
            authorizedOperators[operators[i]] = true;
        }
        for (uint256 i = 0; i < auditors.length; i++) {
            authorizedAuditors[auditors[i]] = true;
        }
    }

    // Function to add a new operator
    function addOperator(address operator) external onlyOperator {
        authorizedOperators[operator] = true;
    }

    // Function to add a new auditor
    function addAuditor(address auditor) external onlyOperator {
        authorizedAuditors[auditor] = true;
    }

    // Function to record a transaction
    function recordTransaction(
        address receiver,
        uint256 amount,
        string calldata transactionType,
        string calldata metadata
    ) external onlyOperator returns (uint256) {
        require(amount > 0, "Transaction amount must be greater than zero");
        require(receiver != address(0), "Invalid receiver address");

        transactionCounter++;

        transactions[transactionCounter] = Transaction({
            transactionId: transactionCounter,
            sender: msg.sender,
            receiver: receiver,
            amount: amount,
            timestamp: block.timestamp,
            transactionType: transactionType,
            metadata: metadata
        });

        emit TransactionRecorded(
            transactionCounter,
            msg.sender,
            receiver,
            amount,
            block.timestamp,
            transactionType,
            metadata
        );

        return transactionCounter;
    }

    // Function to generate an audit report
    function generateAuditReport(string calldata reportHash) external onlyAuditor returns (uint256) {
        require(bytes(reportHash).length > 0, "Report hash cannot be empty");

        auditCounter++;

        auditReports[auditCounter] = AuditReport({
            auditId: auditCounter,
            auditor: msg.sender,
            timestamp: block.timestamp,
            reportHash: reportHash
        });

        emit AuditReportGenerated(auditCounter, msg.sender, block.timestamp);

        return auditCounter;
    }

    // Function to retrieve transaction details
    function getTransactionDetails(uint256 transactionId)
        external
        view
        returns (
            address sender,
            address receiver,
            uint256 amount,
            uint256 timestamp,
            string memory transactionType,
            string memory metadata
        )
    {
        Transaction memory txn = transactions[transactionId];
        return (
            txn.sender,
            txn.receiver,
            txn.amount,
            txn.timestamp,
            txn.transactionType,
            txn.metadata
        );
    }

    // Function to retrieve audit report details
    function getAuditReport(uint256 auditId)
        external
        view
        returns (
            address auditor,
            uint256 timestamp,
            string memory reportHash
        )
    {
        AuditReport memory report = auditReports[auditId];
        return (
            report.auditor,
            report.timestamp,
            report.reportHash
        );
    }
}
