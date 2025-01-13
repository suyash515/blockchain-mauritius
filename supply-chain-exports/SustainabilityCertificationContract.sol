// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SustainabilityCertificationContract {
    struct Certification {
        string certificateId;
        string productId;
        string certifyingBody;
        string issuedDate;
        string expiryDate;
        string certificationDetails;
        bool isValid;
    }

    mapping(string => Certification) private certifications;
    address public owner;

    event CertificationIssued(
        string certificateId,
        string productId,
        string certifyingBody,
        string issuedDate,
        string expiryDate,
        string certificationDetails
    );

    event CertificationRevoked(string certificateId, string productId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function issueCertification(
        string memory _certificateId,
        string memory _productId,
        string memory _certifyingBody,
        string memory _issuedDate,
        string memory _expiryDate,
        string memory _certificationDetails
    ) public onlyOwner {
        require(bytes(_certificateId).length > 0, "Certificate ID cannot be empty.");
        require(bytes(certifications[_certificateId].certificateId).length == 0, "Certificate ID already exists.");

        certifications[_certificateId] = Certification(
            _certificateId,
            _productId,
            _certifyingBody,
            _issuedDate,
            _expiryDate,
            _certificationDetails,
            true
        );

        emit CertificationIssued(
            _certificateId,
            _productId,
            _certifyingBody,
            _issuedDate,
            _expiryDate,
            _certificationDetails
        );
    }

    function revokeCertification(string memory _certificateId) public onlyOwner {
        require(bytes(certifications[_certificateId].certificateId).length > 0, "Certificate not found.");
        require(certifications[_certificateId].isValid, "Certificate is already revoked.");

        certifications[_certificateId].isValid = false;

        emit CertificationRevoked(_certificateId, certifications[_certificateId].productId);
    }

    function getCertification(string memory _certificateId)
        public
        view
        returns (
            string memory productId,
            string memory certifyingBody,
            string memory issuedDate,
            string memory expiryDate,
            string memory certificationDetails,
            bool isValid
        )
    {
        require(bytes(certifications[_certificateId].certificateId).length > 0, "Certificate not found.");

        Certification memory cert = certifications[_certificateId];
        return (
            cert.productId,
            cert.certifyingBody,
            cert.issuedDate,
            cert.expiryDate,
            cert.certificationDetails,
            cert.isValid
        );
    }
}

