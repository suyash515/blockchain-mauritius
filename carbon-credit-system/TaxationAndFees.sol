// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TaxationAndFees {
    struct Transaction {
        address payer;
        uint256 amount; // Transaction amount in wei
        uint256 tax; // Tax amount in wei
        uint256 fee; // Fee amount in wei
        uint256 netAmount; // Net amount after tax and fees
        uint256 timestamp;
    }

    mapping(address => Transaction[]) public transactions;
    address public admin;
    uint256 public taxRate; // Tax rate as a percentage (e.g., 5 for 5%)
    uint256 public feeRate; // Fee rate as a percentage (e.g., 2 for 2%)
    uint256 public totalTaxCollected;
    uint256 public totalFeesCollected;

    event TransactionProcessed(
        address indexed payer,
        uint256 amount,
        uint256 tax,
        uint256 fee,
        uint256 netAmount,
        uint256 timestamp
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor(uint256 _taxRate, uint256 _feeRate) {
        require(_taxRate >= 0 && _taxRate <= 100, "Invalid tax rate");
        require(_feeRate >= 0 && _feeRate <= 100, "Invalid fee rate");
        admin = msg.sender;
        taxRate = _taxRate;
        feeRate = _feeRate;
    }

    function processTransaction(address _payer, uint256 _amount) public onlyAdmin {
        require(_payer != address(0), "Invalid payer address");
        require(_amount > 0, "Transaction amount must be greater than zero");

        uint256 tax = (_amount * taxRate) / 100;
        uint256 fee = (_amount * feeRate) / 100;
        uint256 netAmount = _amount - tax - fee;

        transactions[_payer].push(Transaction({
            payer: _payer,
            amount: _amount,
            tax: tax,
            fee: fee,
            netAmount: netAmount,
            timestamp: block.timestamp
        }));

        totalTaxCollected += tax;
        totalFeesCollected += fee;

        emit TransactionProcessed(_payer, _amount, tax, fee, netAmount, block.timestamp);
    }

    function getTransactions(address _payer) public view returns (Transaction[] memory) {
        return transactions[_payer];
    }

    function updateTaxRate(uint256 _newTaxRate) public onlyAdmin {
        require(_newTaxRate >= 0 && _newTaxRate <= 100, "Invalid tax rate");
        taxRate = _newTaxRate;
    }

    function updateFeeRate(uint256 _newFeeRate) public onlyAdmin {
        require(_newFeeRate >= 0 && _newFeeRate <= 100, "Invalid fee rate");
        feeRate = _newFeeRate;
    }

    function withdrawCollectedFunds(address payable _to) public onlyAdmin {
        require(_to != address(0), "Invalid address");
        uint256 totalCollected = totalTaxCollected + totalFeesCollected;
        require(totalCollected > 0, "No funds to withdraw");

        totalTaxCollected = 0;
        totalFeesCollected = 0;
        _to.transfer(totalCollected);
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }

    // Allow the contract to receive Ether
    receive() external payable {}
}
