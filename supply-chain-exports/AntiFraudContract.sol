// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AntiFraudContract {
    struct FraudCheck {
        string checkId;
        string productId;
        string submittedBy;
        string timestamp;
        string fraudType; // e.g., "Counterfeit", "Misrepresentation", "Tampering"
        string status; // e.g., "Pending", "Verified", "Fraudulent", "Cleared"
        string resolutionDetails;
    }

    mapping(string => FraudCheck) private fraudChecks;
    address public owner;

    event FraudCheckSubmitted(
        string checkId,
        string productId,
        string submittedBy,
        string timestamp,
        string fraudType,
        string status
    );

    event FraudStatusUpdated(string checkId, string status, string resolutionDetails);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function submitFraudCheck(
        string memory _checkId,
        string memory _productId,
        string memory _submittedBy,
        string memory _timestamp,
        string memory _fraudType
    ) public onlyOwner {
        require(bytes(_checkId).length > 0, "Check ID cannot be empty.");
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(_submittedBy).length > 0, "Submitted by cannot be empty.");
        require(bytes(_timestamp).length > 0, "Timestamp cannot be empty.");
        require(bytes(_fraudType).length > 0, "Fraud type cannot be empty.");
        require(bytes(fraudChecks[_checkId].checkId).length == 0, "Fraud check ID already exists.");

        fraudChecks[_checkId] = FraudCheck(
            _checkId,
            _productId,
            _submittedBy,
            _timestamp,
            _fraudType,
            "Pending",
            ""
        );

        emit FraudCheckSubmitted(_checkId, _productId, _submittedBy, _timestamp, _fraudType, "Pending");
    }

    function updateFraudStatus(
        string memory _checkId,
        string memory _status,
        string memory _resolutionDetails
    ) public onlyOwner {
        require(bytes(_checkId).length > 0, "Check ID cannot be empty.");
        require(bytes(fraudChecks[_checkId].checkId).length > 0, "Fraud check not found.");
        require(
            keccak256(bytes(_status)) == keccak256(bytes("Verified")) ||
            keccak256(bytes(_status)) == keccak256(bytes("Fraudulent")) ||
            keccak256(bytes(_status)) == keccak256(bytes("Cleared")),
            "Invalid status value."
        );

        fraudChecks[_checkId].status = _status;
        fraudChecks[_checkId].resolutionDetails = _resolutionDetails;

        emit FraudStatusUpdated(_checkId, _status, _resolutionDetails);
    }

    function getFraudCheckDetails(string memory _checkId)
        public
        view
        returns (
            string memory productId,
            string memory submittedBy,
            string memory timestamp,
            string memory fraudType,
            string memory status,
            string memory resolutionDetails
        )
    {
        require(bytes(_checkId).length > 0, "Check ID cannot be empty.");
        require(bytes(fraudChecks[_checkId].checkId).length > 0, "Fraud check not found.");

        FraudCheck memory check = fraudChecks[_checkId];
        return (
            check.productId,
            check.submittedBy,
            check.timestamp,
            check.fraudType,
            check.status,
            check.resolutionDetails
        );
    }
}

