// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract QualityMonitoringContract {
    struct QualityRecord {
        string productId;
        string monitoredBy;
        string monitoringDate;
        string parameter;
        string value;
        string status; // e.g., "Pass", "Fail", "Warning"
    }

    mapping(string => QualityRecord[]) private qualityRecords;
    address public owner;

    event QualityRecorded(
        string productId,
        string monitoredBy,
        string monitoringDate,
        string parameter,
        string value,
        string status
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addQualityRecord(
        string memory _productId,
        string memory _monitoredBy,
        string memory _monitoringDate,
        string memory _parameter,
        string memory _value,
        string memory _status
    ) public onlyOwner {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(_parameter).length > 0, "Parameter cannot be empty.");
        require(bytes(_value).length > 0, "Value cannot be empty.");
        require(bytes(_status).length > 0, "Status cannot be empty.");

        QualityRecord memory newRecord = QualityRecord(
            _productId,
            _monitoredBy,
            _monitoringDate,
            _parameter,
            _value,
            _status
        );

        qualityRecords[_productId].push(newRecord);

        emit QualityRecorded(_productId, _monitoredBy, _monitoringDate, _parameter, _value, _status);
    }

    function getQualityRecords(string memory _productId) 
        public 
        view 
        returns (QualityRecord[] memory) 
    {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        return qualityRecords[_productId];
    }
}

