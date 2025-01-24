// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TaxationAndReporting {
    address public taxAuthority;
    uint256 public taxRate; // Tax rate as a percentage (e.g., 5 for 5%)

    struct TransactionRecord {
        address payer;
        address payee;
        uint256 amount;
        uint256 taxPaid;
        uint256 timestamp;
    }

    TransactionRecord[] public transactionHistory;

    event TaxPaid(address indexed payer, address indexed payee, uint256 amount, uint256 taxPaid, uint256 timestamp);
    event TaxRateUpdated(uint256 oldRate, uint256 newRate);
    event TaxAuthorityUpdated(address indexed oldAuthority, address indexed newAuthority);

    modifier onlyTaxAuthority() {
        require(msg.sender == taxAuthority, "Only the tax authority can perform this action");
        _;
    }

    constructor(uint256 initialTaxRate) {
        require(initialTaxRate <= 100, "Tax rate must be a percentage value");
        taxAuthority = msg.sender;
        taxRate = initialTaxRate;
    }

    function updateTaxRate(uint256 newTaxRate) external onlyTaxAuthority {
        require(newTaxRate <= 100, "Tax rate must be a percentage value");
        emit TaxRateUpdated(taxRate, newTaxRate);
        taxRate = newTaxRate;
    }

    function updateTaxAuthority(address newAuthority) external onlyTaxAuthority {
        require(newAuthority != address(0), "Invalid address for new tax authority");
        emit TaxAuthorityUpdated(taxAuthority, newAuthority);
        taxAuthority = newAuthority;
    }

    function payWithTax(address payee) external payable {
        require(msg.value > 0, "Amount must be greater than zero");
        
        uint256 taxAmount = (msg.value * taxRate) / 100;
        uint256 netAmount = msg.value - taxAmount;

        // Transfer the net amount to the payee
        payable(payee).transfer(netAmount);
        // Transfer the tax amount to the tax authority
        payable(taxAuthority).transfer(taxAmount);

        // Record the transaction
        transactionHistory.push(TransactionRecord({
            payer: msg.sender,
            payee: payee,
            amount: msg.value,
            taxPaid: taxAmount,
            timestamp: block.timestamp
        }));

        emit TaxPaid(msg.sender, payee, msg.value, taxAmount, block.timestamp);
    }

    function getTransactionHistoryLength() external view returns (uint256) {
        return transactionHistory.length;
    }

    function getTransactionRecord(uint256 index) external view returns (TransactionRecord memory) {
        require(index < transactionHistory.length, "Invalid transaction index");
        return transactionHistory[index];
    }
}

