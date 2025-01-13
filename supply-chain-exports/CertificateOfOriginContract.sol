// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificateOfOriginContract {
    struct Certificate {
        string certificateId;
        string productId;
        string exporter;
        string issuingAuthority;
        string issuedDate;
        string expiryDate;
        string originCountry;
        string details; // Additional information about the certificate
        bool isValid;
    }

    mapping(string => Certificate) private certificates;
    address public owner;

    event CertificateIssued(
        string certificateId,
        string productId,
        string exporter,
        string issuingAuthority,
        string issuedDate,
        string expiryDate,
        string originCountry
    );

    event CertificateRevoked(string certificateId, string productId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function issueCertificate(
        string memory _certificateId,
        string memory _productId,
        string memory _exporter,
        string memory _issuingAuthority,
        string memory _issuedDate,
        string memory _expiryDate,
        string memory _originCountry,
        string memory _details
    ) public onlyOwner {
        require(bytes(_certificateId).length > 0, "Certificate ID cannot be empty.");
        require(bytes(certificates[_certificateId].certificateId).length == 0, "Certificate ID already exists.");

        certificates[_certificateId] = Certificate(
            _certificateId,
            _productId,
            _exporter,
            _issuingAuthority,
            _issuedDate,
            _expiryDate,
            _originCountry,
            _details,
            true
        );

        emit CertificateIssued(
            _certificateId,
            _productId,
            _exporter,
            _issuingAuthority,
            _issuedDate,
            _expiryDate,
            _originCountry
        );
    }

    function revokeCertificate(string memory _certificateId) public onlyOwner {
        require(bytes(_certificateId).length > 0, "Certificate ID cannot be empty.");
        require(bytes(certificates[_certificateId].certificateId).length > 0, "Certificate not found.");
        require(certificates[_certificateId].isValid, "Certificate is already revoked.");

        certificates[_certificateId].isValid = false;

        emit CertificateRevoked(_certificateId, certificates[_certificateId].productId);
    }

    function getCertificate(string memory _certificateId)
        public
        view
        returns (
            string memory productId,
            string memory exporter,
            string memory issuingAuthority,
            string memory issuedDate,
            string memory expiryDate,
            string memory originCountry,
            string memory details,
            bool isValid
        )
    {
        require(bytes(_certificateId).length > 0, "Certificate ID cannot be empty.");
        require(bytes(certificates[_certificateId].certificateId).length > 0, "Certificate not found.");

        Certificate memory cert = certificates[_certificateId];
        return (
            cert.productId,
            cert.exporter,
            cert.issuingAuthority,
            cert.issuedDate,
            cert.expiryDate,
            cert.originCountry,
            cert.details,
            cert.isValid
        );
    }
}

