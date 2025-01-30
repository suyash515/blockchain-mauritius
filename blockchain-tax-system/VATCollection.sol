// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title VATCollection
 * @dev Smart contract to automate VAT collection and remittance
 */
contract VATCollection {
    address public taxAuthority;
    uint256 public vatRate; // VAT rate in percentage (e.g., 15 for 15%)
    
    event VATCollected(address indexed buyer, address indexed seller, uint256 amount, uint256 vatAmount);
    event VATRemitted(address indexed seller, uint256 amount);

    constructor(uint256 _vatRate, address _taxAuthority) {
        require(_vatRate > 0 && _vatRate <= 100, "Invalid VAT rate");
        require(_taxAuthority != address(0), "Invalid tax authority address");
        vatRate = _vatRate;
        taxAuthority = _taxAuthority;
    }

    /**
     * @dev Processes a transaction, deducts VAT, and transfers funds
     * @param seller Address of the seller receiving payment
     */
    function processTransaction(address seller) external payable {
        require(msg.value > 0, "Transaction amount must be greater than zero");
        require(seller != address(0), "Invalid seller address");

        uint256 vatAmount = (msg.value * vatRate) / 100;
        uint256 sellerAmount = msg.value - vatAmount;

        // Transfer VAT to the tax authority
        payable(taxAuthority).transfer(vatAmount);
        // Transfer the remaining amount to the seller
        payable(seller).transfer(sellerAmount);

        emit VATCollected(msg.sender, seller, msg.value, vatAmount);
    }

    /**
     * @dev Updates the VAT rate (only callable by tax authority)
     * @param newVatRate New VAT rate in percentage
     */
    function updateVATRate(uint256 newVatRate) external {
        require(msg.sender == taxAuthority, "Only tax authority can update VAT rate");
        require(newVatRate > 0 && newVatRate <= 100, "Invalid VAT rate");
        vatRate = newVatRate;
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

