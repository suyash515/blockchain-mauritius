// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartContractCertification {
    address public certifyingAuthority;
    uint256 public certificationFee;

    struct Certification {
        bool isCertified;
        string auditHash; // Hash of the audit report
        uint256 certificationDate;
        uint256 expirationDate;
    }

    mapping(address => Certification) public certifiedContracts;

    event ContractCertified(address indexed contractAddress, string auditHash, uint256 expirationDate);
    event ContractDecertified(address indexed contractAddress);
    event CertificationFeeUpdated(uint256 oldFee, uint256 newFee);
    event CertifyingAuthorityUpdated(address indexed oldAuthority, address indexed newAuthority);

    modifier onlyCertifyingAuthority() {
        require(msg.sender == certifyingAuthority, "Only the certifying authority can perform this action");
        _;
    }

    constructor(uint256 _certificationFee) {
        certifyingAuthority = msg.sender;
        certificationFee = _certificationFee;
    }

    function updateCertifyingAuthority(address newAuthority) external onlyCertifyingAuthority {
        require(newAuthority != address(0), "Invalid address for new authority");
        emit CertifyingAuthorityUpdated(certifyingAuthority, newAuthority);
        certifyingAuthority = newAuthority;
    }

    function updateCertificationFee(uint256 newFee) external onlyCertifyingAuthority {
        emit CertificationFeeUpdated(certificationFee, newFee);
        certificationFee = newFee;
    }

    function certifyContract(
        address contractAddress,
        string calldata auditHash,
        uint256 validityDuration
    ) external payable {
        require(msg.value >= certificationFee, "Insufficient certification fee");
        require(contractAddress != address(0), "Invalid contract address");
        require(validityDuration > 0, "Validity duration must be greater than zero");

        certifiedContracts[contractAddress] = Certification({
            isCertified: true,
            auditHash: auditHash,
            certificationDate: block.timestamp,
            expirationDate: block.timestamp + validityDuration
        });

        emit ContractCertified(contractAddress, auditHash, block.timestamp + validityDuration);
    }

    function decertifyContract(address contractAddress) external onlyCertifyingAuthority {
        require(certifiedContracts[contractAddress].isCertified, "Contract is not certified");

        certifiedContracts[contractAddress].isCertified = false;
        emit ContractDecertified(contractAddress);
    }

    function isContractCertified(address contractAddress) external view returns (bool) {
        Certification memory certification = certifiedContracts[contractAddress];
        return certification.isCertified && block.timestamp <= certification.expirationDate;
    }

    function withdrawFees() external onlyCertifyingAuthority {
        payable(certifyingAuthority).transfer(address(this).balance);
    }
}

