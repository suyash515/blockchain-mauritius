// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title CrossBorderTradeTax
 * @dev Smart contract to automate customs duties and VAT for cross-border trade
 */
contract CrossBorderTradeTax {
    address public customsAuthority;
    uint256 public customsDutyRate; // Customs duty rate in percentage (e.g., 10 for 10%)
    uint256 public vatRate; // VAT rate in percentage (e.g., 15 for 15%)

    event TaxCollected(
        address indexed importer,
        uint256 goodsValue,
        uint256 customsDuty,
        uint256 vatAmount,
        uint256 totalTax
    );
    event TaxRatesUpdated(uint256 newCustomsDutyRate, uint256 newVatRate);
    event CustomsAuthorityUpdated(address newAuthority);

    constructor(uint256 _customsDutyRate, uint256 _vatRate, address _customsAuthority) {
        require(_customsDutyRate >= 0 && _customsDutyRate <= 100, "Invalid customs duty rate");
        require(_vatRate >= 0 && _vatRate <= 100, "Invalid VAT rate");
        require(_customsAuthority != address(0), "Invalid customs authority address");

        customsDutyRate = _customsDutyRate;
        vatRate = _vatRate;
        customsAuthority = _customsAuthority;
    }

    /**
     * @dev Processes a cross-border trade transaction, deducts customs duty and VAT
     */
    function processImportTransaction() external payable {
        require(msg.value > 0, "Transaction amount must be greater than zero");

        uint256 customsDuty = (msg.value * customsDutyRate) / 100;
        uint256 vatAmount = (msg.value * vatRate) / 100;
        uint256 totalTax = customsDuty + vatAmount;

        // Transfer total tax to the customs authority
        payable(customsAuthority).transfer(totalTax);

        emit TaxCollected(msg.sender, msg.value, customsDuty, vatAmount, totalTax);
    }

    /**
     * @dev Updates customs duty and VAT rates (only callable by customs authority)
     * @param newCustomsDutyRate New customs duty rate in percentage
     * @param newVatRate New VAT rate in percentage
     */
    function updateTaxRates(uint256 newCustomsDutyRate, uint256 newVatRate) external {
        require(msg.sender == customsAuthority, "Only customs authority can update tax rates");
        require(newCustomsDutyRate >= 0 && newCustomsDutyRate <= 100, "Invalid customs duty rate");
        require(newVatRate >= 0 && newVatRate <= 100, "Invalid VAT rate");

        customsDutyRate = newCustomsDutyRate;
        vatRate = newVatRate;

        emit TaxRatesUpdated(newCustomsDutyRate, newVatRate);
    }

    /**
     * @dev Updates the customs authority address (only callable by current authority)
     * @param newAuthority New customs authority address
     */
    function updateCustomsAuthority(address newAuthority) external {
        require(msg.sender == customsAuthority, "Only current customs authority can update address");
        require(newAuthority != address(0), "Invalid customs authority address");
        customsAuthority = newAuthority;

        emit CustomsAuthorityUpdated(newAuthority);
    }

    /**
     * @dev Fallback function to prevent accidental ETH transfers
     */
    receive() external payable {
        revert("Direct ETH transfers not allowed");
    }
}

