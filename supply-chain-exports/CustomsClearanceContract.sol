// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CustomsClearanceContract {
    struct CustomsRecord {
        string recordId;
        string productId;
        string exporter;
        string importer;
        string customsOffice;
        uint256 declaredValue;
        uint256 dutyAmount;
        string clearanceStatus; // e.g., "Pending", "Approved", "Rejected"
        string clearanceDate;
        bool isFinalized;
    }

    mapping(string => CustomsRecord) private customsRecords;
    address public owner;

    event CustomsRecordCreated(
        string recordId,
        string productId,
        string exporter,
        string importer,
        string customsOffice,
        uint256 declaredValue,
        uint256 dutyAmount,
        string clearanceStatus
    );

    event CustomsStatusUpdated(string recordId, string clearanceStatus);
    event CustomsRecordFinalized(string recordId, string clearanceDate);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createCustomsRecord(
        string memory _recordId,
        string memory _productId,
        string memory _exporter,
        string memory _importer,
        string memory _customsOffice,
        uint256 _declaredValue,
        uint256 _dutyAmount
    ) public onlyOwner {
        require(bytes(_recordId).length > 0, "Record ID cannot be empty.");
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(_exporter).length > 0, "Exporter cannot be empty.");
        require(bytes(_importer).length > 0, "Importer cannot be empty.");
        require(bytes(_customsOffice).length > 0, "Customs office cannot be empty.");
        require(bytes(customsRecords[_recordId].recordId).length == 0, "Record ID already exists.");

        customsRecords[_recordId] = CustomsRecord(
            _recordId,
            _productId,
            _exporter,
            _importer,
            _customsOffice,
            _declaredValue,
            _dutyAmount,
            "Pending",
            "",
            false
        );

        emit CustomsRecordCreated(
            _recordId,
            _productId,
            _exporter,
            _importer,
            _customsOffice,
            _declaredValue,
            _dutyAmount,
            "Pending"
        );
    }

    function updateClearanceStatus(string memory _recordId, string memory _clearanceStatus) public onlyOwner {
        require(bytes(_recordId).length > 0, "Record ID cannot be empty.");
        require(bytes(customsRecords[_recordId].recordId).length > 0, "Customs record not found.");
        require(!customsRecords[_recordId].isFinalized, "Customs record is finalized and cannot be updated.");

        customsRecords[_recordId].clearanceStatus = _clearanceStatus;

        emit CustomsStatusUpdated(_recordId, _clearanceStatus);
    }

    function finalizeCustomsRecord(string memory _recordId, string memory _clearanceDate) public onlyOwner {
        require(bytes(_recordId).length > 0, "Record ID cannot be empty.");
        require(bytes(customsRecords[_recordId].recordId).length > 0, "Customs record not found.");
        require(!customsRecords[_recordId].isFinalized, "Customs record is already finalized.");
        require(bytes(_clearanceDate).length > 0, "Clearance date cannot be empty.");

        customsRecords[_recordId].clearanceDate = _clearanceDate;
        customsRecords[_recordId].isFinalized = true;

        emit CustomsRecordFinalized(_recordId, _clearanceDate);
    }

    function getCustomsRecord(string memory _recordId)
        public
        view
        returns (
            string memory productId,
            string memory exporter,
            string memory importer,
            string memory customsOffice,
            uint256 declaredValue,
            uint256 dutyAmount,
            string memory clearanceStatus,
            string memory clearanceDate,
            bool isFinalized
        )
    {
        require(bytes(_recordId).length > 0, "Record ID cannot be empty.");
        require(bytes(customsRecords[_recordId].recordId).length > 0, "Customs record not found.");

        CustomsRecord memory record = customsRecords[_recordId];
        return (
            record.productId,
            record.exporter,
            record.importer,
            record.customsOffice,
            record.declaredValue,
            record.dutyAmount,
            record.clearanceStatus,
            record.clearanceDate,
            record.isFinalized
        );
    }
}

