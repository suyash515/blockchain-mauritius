// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InsuranceClaimContract {
    struct InsuranceClaim {
        string claimId;
        string policyId;
        string insuredItemId;
        address claimant;
        string claimReason;
        uint256 claimAmount;
        string status; // e.g., "Pending", "Approved", "Rejected"
        string resolutionDetails;
        uint256 filedAt;
        uint256 resolvedAt;
    }

    mapping(string => InsuranceClaim) private claims;
    address public owner;

    event ClaimFiled(
        string claimId,
        string policyId,
        string insuredItemId,
        address claimant,
        string claimReason,
        uint256 claimAmount,
        string status,
        uint256 filedAt
    );

    event ClaimResolved(
        string claimId,
        string status,
        string resolutionDetails,
        uint256 resolvedAt
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function fileClaim(
        string memory _claimId,
        string memory _policyId,
        string memory _insuredItemId,
        string memory _claimReason,
        uint256 _claimAmount
    ) public {
        require(bytes(_claimId).length > 0, "Claim ID cannot be empty.");
        require(bytes(_policyId).length > 0, "Policy ID cannot be empty.");
        require(bytes(_insuredItemId).length > 0, "Insured Item ID cannot be empty.");
        require(bytes(_claimReason).length > 0, "Claim reason cannot be empty.");
        require(_claimAmount > 0, "Claim amount must be greater than zero.");
        require(bytes(claims[_claimId].claimId).length == 0, "Claim ID already exists.");

        claims[_claimId] = InsuranceClaim(
            _claimId,
            _policyId,
            _insuredItemId,
            msg.sender,
            _claimReason,
            _claimAmount,
            "Pending",
            "",
            block.timestamp,
            0
        );

        emit ClaimFiled(
            _claimId,
            _policyId,
            _insuredItemId,
            msg.sender,
            _claimReason,
            _claimAmount,
            "Pending",
            block.timestamp
        );
    }

    function resolveClaim(
        string memory _claimId,
        string memory _status,
        string memory _resolutionDetails
    ) public onlyOwner {
        require(bytes(_claimId).length > 0, "Claim ID cannot be empty.");
        require(bytes(claims[_claimId].claimId).length > 0, "Claim not found.");
        require(
            keccak256(bytes(_status)) == keccak256(bytes("Approved")) ||
            keccak256(bytes(_status)) == keccak256(bytes("Rejected")),
            "Invalid status value."
        );

        claims[_claimId].status = _status;
        claims[_claimId].resolutionDetails = _resolutionDetails;
        claims[_claimId].resolvedAt = block.timestamp;

        emit ClaimResolved(_claimId, _status, _resolutionDetails, block.timestamp);
    }

    function getClaimDetails(string memory _claimId)
        public
        view
        returns (
            string memory policyId,
            string memory insuredItemId,
            address claimant,
            string memory claimReason,
            uint256 claimAmount,
            string memory status,
            string memory resolutionDetails,
            uint256 filedAt,
            uint256 resolvedAt
        )
    {
        require(bytes(_claimId).length > 0, "Claim ID cannot be empty.");
        require(bytes(claims[_claimId].claimId).length > 0, "Claim not found.");

        InsuranceClaim memory claim = claims[_claimId];
        return (
            claim.policyId,
            claim.insuredItemId,
            claim.claimant,
            claim.claimReason,
            claim.claimAmount,
            claim.status,
            claim.resolutionDetails,
            claim.filedAt,
            claim.resolvedAt
        );
    }
}

