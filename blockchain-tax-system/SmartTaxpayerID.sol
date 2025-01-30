// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SmartTaxpayerID
 * @dev Smart contract to assign taxpayer IDs and track compliance scores
 */
contract SmartTaxpayerID {
    address public taxAuthority;

    struct Taxpayer {
        string taxID;
        uint256 complianceScore; // Score based on tax payment history
        uint256 lastUpdated;
        bool registered;
    }

    mapping(address => Taxpayer) public taxpayers;

    event TaxpayerRegistered(address indexed taxpayer, string taxID);
    event ComplianceScoreUpdated(address indexed taxpayer, uint256 newScore);
    event TaxAuthorityUpdated(address newTaxAuthority);

    constructor(address _taxAuthority) {
        require(_taxAuthority != address(0), "Invalid tax authority address");
        taxAuthority = _taxAuthority;
    }

    /**
     * @dev Registers a taxpayer and assigns a unique tax ID
     * @param taxpayer Address of the taxpayer
     * @param taxID Unique tax ID assigned by the tax authority
     */
    function registerTaxpayer(address taxpayer, string memory taxID) external {
        require(msg.sender == taxAuthority, "Only tax authority can register taxpayers");
        require(taxpayer != address(0), "Invalid taxpayer address");
        require(bytes(taxID).length > 0, "Invalid tax ID");
        require(!taxpayers[taxpayer].registered, "Taxpayer already registered");

        taxpayers[taxpayer] = Taxpayer({
            taxID: taxID,
            complianceScore: 100, // Default score
            lastUpdated: block.timestamp,
            registered: true
        });

        emit TaxpayerRegistered(taxpayer, taxID);
    }

    /**
     * @dev Updates the compliance score of a taxpayer
     * @param taxpayer Address of the taxpayer
     * @param newScore New compliance score
     */
    function updateComplianceScore(address taxpayer, uint256 newScore) external {
        require(msg.sender == taxAuthority, "Only tax authority can update scores");
        require(taxpayers[taxpayer].registered, "Taxpayer not registered");
        require(newScore <= 100, "Score cannot exceed 100");

        taxpayers[taxpayer].complianceScore = newScore;
        taxpayers[taxpayer].lastUpdated = block.timestamp;

        emit ComplianceScoreUpdated(taxpayer, newScore);
    }

    /**
     * @dev Retrieves taxpayer details
     * @param taxpayer Address of the taxpayer
     * @return taxID Taxpayer ID
     * @return complianceScore Current compliance score
     * @return lastUpdated Last updated timestamp
     */
    function getTaxpayerInfo(address taxpayer)
        external
        view
        returns (string memory taxID, uint256 complianceScore, uint256 lastUpdated)
    {
        require(taxpayers[taxpayer].registered, "Taxpayer not registered");
        Taxpayer memory taxInfo = taxpayers[taxpayer];
        return (taxInfo.taxID, taxInfo.complianceScore, taxInfo.lastUpdated);
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
}

