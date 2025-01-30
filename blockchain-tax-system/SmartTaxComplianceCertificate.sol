// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SmartTaxComplianceCertificate
 * @dev Smart contract to issue blockchain-based tax compliance certificates
 */
contract SmartTaxComplianceCertificate {
    address public taxAuthority;

    struct Taxpayer {
        bool isCompliant;
        uint256 lastUpdated;
        string certificateHash; // Hash of the compliance certificate stored off-chain
    }

    mapping(address => Taxpayer) public taxpayers;

    event CertificateIssued(address indexed taxpayer, string certificateHash, uint256 timestamp);
    event ComplianceStatusUpdated(address indexed taxpayer, bool isCompliant);
    event TaxAuthorityUpdated(address newTaxAuthority);

    constructor(address _taxAuthority) {
        require(_taxAuthority != address(0), "Invalid tax authority address");
        taxAuthority = _taxAuthority;
    }

    /**
     * @dev Issues a tax compliance certificate to a taxpayer
     * @param taxpayer Address of the taxpayer receiving the certificate
     * @param certificateHash Hash of the off-chain stored certificate
     */
    function issueCertificate(address taxpayer, string memory certificateHash) external {
        require(msg.sender == taxAuthority, "Only tax authority can issue certificates");
        require(taxpayer != address(0), "Invalid taxpayer address");
        require(bytes(certificateHash).length > 0, "Invalid certificate hash");

        taxpayers[taxpayer] = Taxpayer({
            isCompliant: true,
            lastUpdated: block.timestamp,
            certificateHash: certificateHash
        });

        emit CertificateIssued(taxpayer, certificateHash, block.timestamp);
    }

    /**
     * @dev Updates the compliance status of a taxpayer
     * @param taxpayer Address of the taxpayer
     * @param status True if compliant, false if non-compliant
     */
    function updateComplianceStatus(address taxpayer, bool status) external {
        require(msg.sender == taxAuthority, "Only tax authority can update compliance status");
        require(taxpayer != address(0), "Invalid taxpayer address");

        taxpayers[taxpayer].isCompliant = status;
        taxpayers[taxpayer].lastUpdated = block.timestamp;

        emit ComplianceStatusUpdated(taxpayer, status);
    }

    /**
     * @dev Retrieves the tax compliance certificate details
     * @param taxpayer Address of the taxpayer
     * @return isCompliant Compliance status
     * @return lastUpdated Timestamp of last compliance update
     * @return certificateHash Hash of the compliance certificate
     */
    function getCertificate(address taxpayer)
        external
        view
        returns (bool isCompliant, uint256 lastUpdated, string memory certificateHash)
    {
        Taxpayer memory taxInfo = taxpayers[taxpayer];
        return (taxInfo.isCompliant, taxInfo.lastUpdated, taxInfo.certificateHash);
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

