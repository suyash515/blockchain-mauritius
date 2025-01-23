// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ConsumerVerification {
    struct GreenCertificate {
        string certificationDetails;
        uint256 issuedDate;
        address issuer;
        bool isValid;
    }

    mapping(uint256 => GreenCertificate) public certificates; // Mapping certificate ID to details
    uint256 public certificateCounter;
    address public admin;

    event CertificateIssued(
        uint256 certificateId,
        address indexed issuer,
        string certificationDetails,
        uint256 issuedDate
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
        certificateCounter = 0;
    }

    function issueCertificate(
        string memory _certificationDetails,
        address _issuer
    ) public onlyAdmin {
        require(_issuer != address(0), "Invalid issuer address");

        certificateCounter++;
        certificates[certificateCounter] = GreenCertificate({
            certificationDetails: _certificationDetails,
            issuedDate: block.timestamp,
            issuer: _issuer,
            isValid: true
        });

        emit CertificateIssued(certificateCounter, _issuer, _certificationDetails, block.timestamp);
    }

    function verifyCertificate(uint256 _certificateId) public view returns (GreenCertificate memory) {
        require(certificates[_certificateId].isValid, "Certificate is invalid or does not exist");
        return certificates[_certificateId];
    }

    function invalidateCertificate(uint256 _certificateId) public onlyAdmin {
        require(certificates[_certificateId].isValid, "Certificate is already invalid");
        certificates[_certificateId].isValid = false;
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
}
