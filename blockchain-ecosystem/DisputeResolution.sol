// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DisputeResolution {
    // Enum to define the status of a dispute
    enum DisputeStatus { Open, UnderReview, Resolved, Rejected }

    // Struct to represent a dispute
    struct Dispute {
        uint256 id;
        address complainant;
        address respondent;
        string description;
        DisputeStatus status;
        string resolution;
        uint256 timestamp;
    }

    // Mapping to store disputes by ID
    mapping(uint256 => Dispute) public disputes;

    // Counter to generate unique dispute IDs
    uint256 private disputeIdCounter;

    // Address of the arbitrator
    address public arbitrator;

    // Events
    event DisputeFiled(uint256 indexed id, address indexed complainant, address indexed respondent, string description);
    event DisputeUnderReview(uint256 indexed id, address arbitrator);
    event DisputeResolved(uint256 indexed id, string resolution);
    event DisputeRejected(uint256 indexed id, string reason);

    // Modifier to check if a dispute exists
    modifier disputeExists(uint256 _disputeId) {
        require(disputes[_disputeId].complainant != address(0), "Dispute does not exist");
        _;
    }

    // Modifier to ensure only the arbitrator can act on a dispute
    modifier onlyArbitrator() {
        require(msg.sender == arbitrator, "Only the arbitrator can perform this action");
        _;
    }

    // Constructor to set the arbitrator
    constructor(address _arbitrator) {
        require(_arbitrator != address(0), "Arbitrator address cannot be zero");
        arbitrator = _arbitrator;
    }

    // Function to file a dispute
    function fileDispute(address _respondent, string calldata _description) external returns (uint256) {
        require(_respondent != address(0), "Respondent address cannot be zero");
        require(bytes(_description).length > 0, "Description cannot be empty");

        uint256 newId = ++disputeIdCounter;

        disputes[newId] = Dispute({
            id: newId,
            complainant: msg.sender,
            respondent: _respondent,
            description: _description,
            status: DisputeStatus.Open,
            resolution: "",
            timestamp: block.timestamp
        });

        emit DisputeFiled(newId, msg.sender, _respondent, _description);
        return newId;
    }

    // Function for the arbitrator to mark a dispute as under review
    function reviewDispute(uint256 _disputeId) external onlyArbitrator disputeExists(_disputeId) {
        Dispute storage dispute = disputes[_disputeId];
        require(dispute.status == DisputeStatus.Open, "Dispute is not open for review");

        dispute.status = DisputeStatus.UnderReview;

        emit DisputeUnderReview(_disputeId, msg.sender);
    }

    // Function for the arbitrator to resolve a dispute
    function resolveDispute(uint256 _disputeId, string calldata _resolution) external onlyArbitrator disputeExists(_disputeId) {
        require(bytes(_resolution).length > 0, "Resolution cannot be empty");

        Dispute storage dispute = disputes[_disputeId];
        require(dispute.status == DisputeStatus.UnderReview, "Dispute must be under review");

        dispute.status = DisputeStatus.Resolved;
        dispute.resolution = _resolution;

        emit DisputeResolved(_disputeId, _resolution);
    }

    // Function for the arbitrator to reject a dispute
    function rejectDispute(uint256 _disputeId, string calldata _reason) external onlyArbitrator disputeExists(_disputeId) {
        require(bytes(_reason).length > 0, "Reason cannot be empty");

        Dispute storage dispute = disputes[_disputeId];
        require(dispute.status == DisputeStatus.Open || dispute.status == DisputeStatus.UnderReview, "Dispute cannot be rejected");

        dispute.status = DisputeStatus.Rejected;
        dispute.resolution = _reason;

        emit DisputeRejected(_disputeId, _reason);
    }

    // Function to get details of a dispute
    function getDispute(uint256 _disputeId)
        external
        view
        disputeExists(_disputeId)
        returns (
            address complainant,
            address respondent,
            string memory description,
            DisputeStatus status,
            string memory resolution,
            uint256 timestamp
        )
    {
        Dispute memory dispute = disputes[_disputeId];
        return (
            dispute.complainant,
            dispute.respondent,
            dispute.description,
            dispute.status,
            dispute.resolution,
            dispute.timestamp
        );
    }
}
