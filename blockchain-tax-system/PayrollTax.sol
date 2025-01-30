// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title PayrollTax
 * @dev Smart contract to automate payroll tax deduction and remittance
 */
contract PayrollTax {
    address public taxAuthority;
    uint256 public taxRate; // Payroll tax rate in percentage (e.g., 15 for 15%)

    event PayrollProcessed(address indexed employer, address indexed employee, uint256 salary, uint256 taxAmount);
    event TaxRateUpdated(uint256 newTaxRate);
    event TaxRemitted(address indexed employer, uint256 amount);

    constructor(uint256 _taxRate, address _taxAuthority) {
        require(_taxRate > 0 && _taxRate <= 100, "Invalid tax rate");
        require(_taxAuthority != address(0), "Invalid tax authority address");
        taxRate = _taxRate;
        taxAuthority = _taxAuthority;
    }

    /**
     * @dev Processes payroll, deducts tax, and transfers net salary
     * @param employee Address of the employee receiving salary
     */
    function processPayroll(address employee) external payable {
        require(msg.value > 0, "Salary amount must be greater than zero");
        require(employee != address(0), "Invalid employee address");

        uint256 taxAmount = (msg.value * taxRate) / 100;
        uint256 netSalary = msg.value - taxAmount;

        // Transfer tax to the tax authority
        payable(taxAuthority).transfer(taxAmount);
        // Transfer net salary to the employee
        payable(employee).transfer(netSalary);

        emit PayrollProcessed(msg.sender, employee, msg.value, taxAmount);
    }

    /**
     * @dev Updates the payroll tax rate (only callable by tax authority)
     * @param newTaxRate New payroll tax rate in percentage
     */
    function updateTaxRate(uint256 newTaxRate) external {
        require(msg.sender == taxAuthority, "Only tax authority can update tax rate");
        require(newTaxRate > 0 && newTaxRate <= 100, "Invalid tax rate");
        taxRate = newTaxRate;

        emit TaxRateUpdated(newTaxRate);
    }

    /**
     * @dev Updates the tax authority address (only callable by current tax authority)
     * @param newTaxAuthority New tax authority address
     */
    function updateTaxAuthority(address newTaxAuthority) external {
        require(msg.sender == taxAuthority, "Only current tax authority can update address");
        require(newTaxAuthority != address(0), "Invalid tax authority address");
        taxAuthority = newTaxAuthority;
    }

    /**
     * @dev Fallback function to prevent accidental ETH transfers
     */
    receive() external payable {
        revert("Direct ETH transfers not allowed");
    }
}

