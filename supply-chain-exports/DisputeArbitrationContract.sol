// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DisputeArbitrationContract {
    struct Dispute {
        string disputeId;
        string transactionId;
        address complainant;
        address respondent;
        string description;
        string status; // e.g., "Pending", "Resolved", "Rejected"
        string resolutionDetails;
        uint256 createdAt;
        uint256 resolvedAt;
    }

    mapping(string => Dispute) private disputes;
    address public owner;

    event DisputeFiled(
        string disputeId,
        string transactionId,
        address complainant,
        address respondent,
        string description,
        string status,
        uint256 createdAt
    );

    event DisputeResolved(
        string disputeId,
        string resolutionDetails,
        string status,
        uint256 resolvedAt
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function fileDispute(
        string memory _disputeId,
        string memory _transactionId,
        address _respondent,
        string memory _description
    ) public {
        require(bytes(_disputeId).length > 0, "Dispute ID cannot be empty.");
        require(bytes(_transactionId).length > 0, "Transaction ID cannot be empty.");
        require(_respondent != address(0), "Respondent address cannot be zero.");
        require(bytes(_description).length > 0, "Description cannot be empty.");
        require(bytes(disputes[_disputeId].disputeId).length == 0, "Dispute ID already exists.");

        disputes[_disputeId] = Dispute(
            _disputeId,
            _transactionId,
            msg.sender,
            _respondent,
            _description,
            "Pending",
            "",
            block.timestamp,
            0
        );

        emit DisputeFiled(
            _disputeId,
            _transactionId,
            msg.sender,
            _respondent,
            _description,
            "Pending",
            block.timestamp
        );
    }

    function resolveDispute(
        string memory _disputeId,
        string memory _resolutionDetails,
        string memory _status
    ) public onlyOwner {
        require(bytes(_disputeId).length > 0, "Dispute ID cannot be empty.");
        require(bytes(disputes[_disputeId].disputeId).length > 0, "Dispute not found.");
        require(
            keccak256(bytes(_status)) == keccak256(bytes("Resolved")) ||
            keccak256(bytes(_status)) == keccak256(bytes("Rejected")),
            "Invalid status value."
        );

        disputes[_disputeId].status = _status;
        disputes[_disputeId].resolutionDetails = _resolutionDetails;
        disputes[_disputeId].resolvedAt = block.timestamp;

        emit DisputeResolved(_disputeId, _resolutionDetails, _status, block.timestamp);
    }

    function getDisputeDetails(string memory _disputeId)
        public
        view
        returns (
            string memory transactionId,
            address complainant,
            address respondent,
            string memory description,
            string memory status,
            string memory resolutionDetails,
            uint256 createdAt,
            uint256 resolvedAt
        )
    {
        require(bytes(_disputeId).length > 0, "Dispute ID cannot be empty.");
        require(bytes(disputes[_disputeId].disputeId).length > 0, "Dispute not found.");

        Dispute memory dispute = disputes[_disputeId];
        return (
            dispute.transactionId,
            dispute.complainant,
            dispute.respondent,
            dispute.description,
            dispute.status,
            dispute.resolutionDetails,
            dispute.createdAt,
            dispute.resolvedAt
        );
    }
}

