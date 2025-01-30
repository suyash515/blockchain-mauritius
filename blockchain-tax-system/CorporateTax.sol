// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title CorporateTax
 * @dev Smart contract to automate corporate tax deductions and remittance
 */
contract CorporateTax {
    address public taxAuthority;
    uint256 public taxRate; // Corporate tax rate in percentage (e.g., 10 for 10%)

    event CorporateTaxPaid(address indexed company, uint256 profit, uint256 taxAmount);
    event TaxRateUpdated(uint256 newTaxRate);
    event TaxRemitted(address indexed company, uint256 amount);

    constructor(uint256 _taxRate, address _taxAuthority) {
        require(_taxRate > 0 && _taxRate <= 100, "Invalid tax rate");
        require(_taxAuthority != address(0), "Invalid tax authority address");
        taxRate = _taxRate;
        taxAuthority = _taxAuthority;
    }

    /**
     * @dev Pays corporate tax based on declared profit
     */
    function payCorporateTax() external payable {
        require(msg.value > 0, "Profit amount must be greater than zero");

        uint256 taxAmount = (msg.value * taxRate) / 100;
        uint256 remainingProfit = msg.value - taxAmount;

        // Transfer tax to the tax authority
        payable(taxAuthority).transfer(taxAmount);

        emit CorporateTaxPaid(msg.sender, msg.value, taxAmount);
    }

    /**
     * @dev Updates the corporate tax rate (only callable by tax authority)
     * @param newTaxRate New corporate tax rate in percentage
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

