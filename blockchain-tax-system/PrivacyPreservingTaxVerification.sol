// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title PrivacyPreservingTaxVerification
 * @dev Smart contract to verify tax compliance using Zero-Knowledge Proofs (ZKPs)
 */
contract PrivacyPreservingTaxVerification {
    address public taxAuthority;

    struct ComplianceRecord {
        bool isCompliant;
        uint256 lastVerified;
        bytes32 zkProof; // Zero-Knowledge Proof hash
    }

    mapping(address => ComplianceRecord) public complianceRecords;

    event ComplianceVerified(address indexed taxpayer, uint256 timestamp, bytes32 zkProof);
    event TaxAuthorityUpdated(address newTaxAuthority);

    constructor(address _taxAuthority) {
        require(_taxAuthority != address(0), "Invalid tax authority address");
        taxAuthority = _taxAuthority;
    }

    /**
     * @dev Submits a Zero-Knowledge Proof (ZKP) for tax compliance verification
     * @param taxpayer Address of the taxpayer
     * @param zkProof Hash of the Zero-Knowledge Proof verifying compliance
     */
    function submitComplianceProof(address taxpayer, bytes32 zkProof) external {
        require(msg.sender == taxAuthority, "Only tax authority can verify compliance");
        require(taxpayer != address(0), "Invalid taxpayer address");
        require(zkProof != bytes32(0), "Invalid ZK proof");

        complianceRecords[taxpayer] = ComplianceRecord({
            isCompliant: true,
            lastVerified: block.timestamp,
            zkProof: zkProof
        });

        emit ComplianceVerified(taxpayer, block.timestamp, zkProof);
    }

    /**
     * @dev Retrieves the compliance verification record for a taxpayer
     * @param taxpayer Address of the taxpayer
     * @return isCompliant Compliance status
     * @return lastVerified Timestamp of last verification
     * @return zkProof Zero-Knowledge Proof hash
     */
    function getComplianceRecord(address taxpayer)
        external
        view
        returns (bool isCompliant, uint256 lastVerified, bytes32 zkProof)
    {
        ComplianceRecord memory record = complianceRecords[taxpayer];
        return (record.isCompliant, record.lastVerified, record.zkProof);
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

