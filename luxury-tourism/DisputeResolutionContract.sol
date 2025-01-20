// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DisputeResolutionContract {
    // Enum to represent dispute status
    enum DisputeStatus {
        Open,
        Resolved,
        Rejected
    }

    // Struct to store dispute details
    struct Dispute {
        uint256 id;                 // Unique dispute ID
        address complainant;        // Address of the complainant
        address respondent;         // Address of the respondent
        string description;         // Description of the dispute
        DisputeStatus status;       // Current status of the dispute
        string resolution;          // Resolution details
    }

    // Mapping to store disputes by their ID
    mapping(uint256 => Dispute) private disputes;

    // Counter for dispute IDs
    uint256 private disputeCounter;

    // Event emitted when a dispute is filed
    event DisputeFiled(
        uint256 indexed disputeId,
        address indexed complainant,
        address indexed respondent,
        string description
    );

    // Event emitted when a dispute is resolved
    event DisputeResolved(uint256 indexed disputeId, string resolution);

    // Event emitted when a dispute is rejected
    event DisputeRejected(uint256 indexed disputeId, string reason);

    // Modifier to check if a dispute exists
    modifier disputeExists(uint256 disputeId) {
        require(disputes[disputeId].id != 0, "Dispute does not exist");
        _;
    }

    // Function to file a new dispute
    function fileDispute(address respondent, string memory description) public {
        require(respondent != address(0), "Invalid respondent address");
        require(bytes(description).length > 0, "Dispute description cannot be empty");

        disputeCounter++;

        disputes[disputeCounter] = Dispute({
            id: disputeCounter,
            complainant: msg.sender,
            respondent: respondent,
            description: description,
            status: DisputeStatus.Open,
            resolution: ""
        });

        emit DisputeFiled(disputeCounter, msg.sender, respondent, description);
    }

    // Function to resolve a dispute
    function resolveDispute(uint256 disputeId, string memory resolution)
        public
        disputeExists(disputeId)
    {
        Dispute storage dispute = disputes[disputeId];
        require(dispute.status == DisputeStatus.Open, "Dispute is not open for resolution");

        dispute.status = DisputeStatus.Resolved;
        dispute.resolution = resolution;

        emit DisputeResolved(disputeId, resolution);
    }

    // Function to reject a dispute
    function rejectDispute(uint256 disputeId, string memory reason)
        public
        disputeExists(disputeId)
    {
        Dispute storage dispute = disputes[disputeId];
        require(dispute.status == DisputeStatus.Open, "Dispute is not open for rejection");

        dispute.status = DisputeStatus.Rejected;
        dispute.resolution = reason;

        emit DisputeRejected(disputeId, reason);
    }

    // Function to get details of a dispute
    function getDispute(uint256 disputeId)
        public
        view
        disputeExists(disputeId)
        returns (
            address complainant,
            address respondent,
            string memory description,
            DisputeStatus status,
            string memory resolution
        )
    {
        Dispute memory dispute = disputes[disputeId];
        return (
            dispute.complainant,
            dispute.respondent,
            dispute.description,
            dispute.status,
            dispute.resolution
        );
    }

    // Function to get the total number of disputes filed
    function getTotalDisputes() public view returns (uint256) {
        return disputeCounter;
    }
}

