// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TreasuryManagement {
    // Events
    event FundsDeposited(address indexed sender, uint256 amount, uint256 timestamp);
    event FundsWithdrawn(address indexed recipient, uint256 amount, uint256 timestamp);
    event AllocationSet(address indexed recipient, uint256 amount, uint256 timestamp);

    // Owner of the treasury
    address public owner;

    // Mapping of allocated funds for specific purposes
    mapping(address => uint256) public allocations;

    // Modifier to restrict functions to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // Constructor to set the owner
    constructor() {
        owner = msg.sender;
    }

    // Function to deposit funds into the treasury
    function depositFunds() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        emit FundsDeposited(msg.sender, msg.value, block.timestamp);
    }

    // Function to set allocations for specific addresses
    function setAllocation(address recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Allocation amount must be greater than zero");
        allocations[recipient] = amount;
        emit AllocationSet(recipient, amount, block.timestamp);
    }

    // Function to withdraw allocated funds
    function withdrawFunds(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(allocations[msg.sender] >= amount, "Insufficient allocated funds");
        require(address(this).balance >= amount, "Insufficient treasury balance");

        allocations[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit FundsWithdrawn(msg.sender, amount, block.timestamp);
    }

    // Function to check the balance of the treasury
    function getTreasuryBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
