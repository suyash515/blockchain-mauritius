// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RegulatoryComplianceContract {
    struct ComplianceRecord {
        string recordId;
        string productId;
        string regulatoryBody;
        string complianceDetails;
        string issuedDate;
        string expiryDate;
        string status; // e.g., "Compliant", "Non-Compliant", "Pending"
    }

    mapping(string => ComplianceRecord) private complianceRecords;
    address public owner;

    event ComplianceRecordCreated(
        string recordId,
        string productId,
        string regulatoryBody,
        string complianceDetails,
        string issuedDate,
        string expiryDate,
        string status
    );

    event ComplianceStatusUpdated(string recordId, string status);
    event ComplianceRecordRevoked(string recordId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createComplianceRecord(
        string memory _recordId,
        string memory _productId,
        string memory _regulatoryBody,
        string memory _complianceDetails,
        string memory _issuedDate,
        string memory _expiryDate
    ) public onlyOwner {
        require(bytes(_recordId).length > 0, "Record ID cannot be empty.");
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(_regulatoryBody).length > 0, "Regulatory body cannot be empty.");
        require(bytes(_complianceDetails).length > 0, "Compliance details cannot be empty.");
        require(bytes(_issuedDate).length > 0, "Issued date cannot be empty.");
        require(bytes(_expiryDate).length > 0, "Expiry date cannot be empty.");
        require(bytes(complianceRecords[_recordId].recordId).length == 0, "Record ID already exists.");

        complianceRecords[_recordId] = ComplianceRecord(
            _recordId,
            _productId,
            _regulatoryBody,
            _complianceDetails,
            _issuedDate,
            _expiryDate,
            "Pending"
        );

        emit ComplianceRecordCreated(
            _recordId,
            _productId,
            _regulatoryBody,
            _complianceDetails,
            _issuedDate,
            _expiryDate,
            "Pending"
        );
    }

    function updateComplianceStatus(string memory _recordId, string memory _status) public onlyOwner {
        require(bytes(_recordId).length > 0, "Record ID cannot be empty.");
        require(bytes(complianceRecords[_recordId].recordId).length > 0, "Compliance record not found.");
        require(
            keccak256(bytes(_status)) == keccak256(bytes("Compliant")) ||
            keccak256(bytes(_status)) == keccak256(bytes("Non-Compliant")) ||
            keccak256(bytes(_status)) == keccak256(bytes("Pending")),
            "Invalid status value."
        );

        complianceRecords[_recordId].status = _status;

        emit ComplianceStatusUpdated(_recordId, _status);
    }

    function revokeComplianceRecord(string memory _recordId) public onlyOwner {
        require(bytes(_recordId).length > 0, "Record ID cannot be empty.");
        require(bytes(complianceRecords[_recordId].recordId).length > 0, "Compliance record not found.");

        delete complianceRecords[_recordId];

        emit ComplianceRecordRevoked(_recordId);
    }

    function getComplianceRecord(string memory _recordId)
        public
        view
        returns (
            string memory productId,
            string memory regulatoryBody,
            string memory complianceDetails,
            string memory issuedDate,
            string memory expiryDate,
            string memory status
        )
    {
        require(bytes(_recordId).length > 0, "Record ID cannot be empty.");
        require(bytes(complianceRecords[_recordId].recordId).length > 0, "Compliance record not found.");

        ComplianceRecord memory record = complianceRecords[_recordId];
        return (
            record.productId,
            record.regulatoryBody,
            record.complianceDetails,
            record.issuedDate,
            record.expiryDate,
            record.status
        );
    }
}

