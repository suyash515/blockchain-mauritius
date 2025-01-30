// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title TaxWallet
 * @dev Smart contract to manage and distribute tax collections for the government
 */
contract TaxWallet {
    address public taxAuthority;

    event TaxReceived(address indexed payer, uint256 amount);
    event FundsDistributed(address indexed recipient, uint256 amount);
    event TaxAuthorityUpdated(address newTaxAuthority);

    constructor(address _taxAuthority) {
        require(_taxAuthority != address(0), "Invalid tax authority address");
        taxAuthority = _taxAuthority;
    }

    /**
     * @dev Receives tax payments from various tax collection smart contracts
     */
    function receiveTax() external payable {
        require(msg.value > 0, "Tax amount must be greater than zero");
        emit TaxReceived(msg.sender, msg.value);
    }

    /**
     * @dev Distributes collected tax funds to government departments
     * @param recipient Address of the government department receiving funds
     * @param amount Amount to be transferred
     */
    function distributeFunds(address payable recipient, uint256 amount) external {
        require(msg.sender == taxAuthority, "Only tax authority can distribute funds");
        require(address(this).balance >= amount, "Insufficient balance");
        require(recipient != address(0), "Invalid recipient address");

        recipient.transfer(amount);
        emit FundsDistributed(recipient, amount);
    }

    /**
     * @dev Updates the tax authority address (only callable by current tax authority)
     * @param newTaxAuthority New tax authority address
     */
    function updateTaxAuthority(address newTaxAuthority) external {
        require(msg.sender == taxAuthority, "Only current tax authority can update address");
        require(newTaxAuthority != address(0), "Invalid tax authority address");
        taxAuthority = newTaxAuthority;

        emit TaxAuthorityUpdated(newTaxAuthority);
    }

    /**
     * @dev Fallback function to allow receiving tax payments
     */
    receive() external payable {
        emit TaxReceived(msg.sender, msg.value);
    }
}

