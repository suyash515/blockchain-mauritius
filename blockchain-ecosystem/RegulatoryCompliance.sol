// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RegulatoryCompliance {
    // Enum to define the status of compliance submissions
    enum ComplianceStatus { Submitted, UnderReview, Approved, Rejected }

    // Struct to represent a compliance submission
    struct ComplianceSubmission {
        uint256 id;
        address projectOwner;
        string projectName;
        string documentHash; // IPFS or other decentralized storage hash
        string remarks; // Remarks from the regulatory body
        ComplianceStatus status;
        uint256 timestamp;
    }

    // Mapping to store compliance submissions by ID
    mapping(uint256 => ComplianceSubmission) public submissions;

    // Counter to generate unique compliance submission IDs
    uint256 private submissionIdCounter;

    // Address of the contract owner (e.g., regulatory authority)
    address public owner;

    // Events
    event SubmissionCreated(uint256 indexed id, address indexed projectOwner, string projectName);
    event StatusUpdated(uint256 indexed id, ComplianceStatus status, string remarks);
    event DocumentUpdated(uint256 indexed id, string newDocumentHash);

    // Modifier to restrict actions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Modifier to ensure a submission exists
    modifier submissionExists(uint256 _submissionId) {
        require(submissions[_submissionId].projectOwner != address(0), "Submission does not exist");
        _;
    }

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to create a new compliance submission
    function createSubmission(
        string calldata _projectName,
        string calldata _documentHash
    ) external returns (uint256) {
        require(bytes(_projectName).length > 0, "Project name cannot be empty");
        require(bytes(_documentHash).length > 0, "Document hash cannot be empty");

        uint256 newId = ++submissionIdCounter;

        submissions[newId] = ComplianceSubmission({
            id: newId,
            projectOwner: msg.sender,
            projectName: _projectName,
            documentHash: _documentHash,
            remarks: "",
            status: ComplianceStatus.Submitted,
            timestamp: block.timestamp
        });

        emit SubmissionCreated(newId, msg.sender, _projectName);
        return newId;
    }

    // Function for the regulatory authority to update the status of a submission
    function updateStatus(
        uint256 _submissionId,
        ComplianceStatus _status,
        string calldata _remarks
    )
        external
        onlyOwner
        submissionExists(_submissionId)
    {
        ComplianceSubmission storage submission = submissions[_submissionId];
        require(
            _status == ComplianceStatus.UnderReview || 
            _status == ComplianceStatus.Approved || 
            _status == ComplianceStatus.Rejected,
            "Invalid status"
        );

        submission.status = _status;
        submission.remarks = _remarks;

        emit StatusUpdated(_submissionId, _status, _remarks);
    }

    // Function for the project owner to update the compliance document (if required)
    function updateDocument(uint256 _submissionId, string calldata _newDocumentHash)
        external
        submissionExists(_submissionId)
    {
        ComplianceSubmission storage submission = submissions[_submissionId];
        require(msg.sender == submission.projectOwner, "Only the project owner can update the document");
        require(bytes(_newDocumentHash).length > 0, "Document hash cannot be empty");
        require(
            submission.status == ComplianceStatus.Submitted || submission.status == ComplianceStatus.UnderReview,
            "Cannot update document at this stage"
        );

        submission.documentHash = _newDocumentHash;

        emit DocumentUpdated(_submissionId, _newDocumentHash);
    }

    // Function to retrieve submission details
    function getSubmission(uint256 _submissionId)
        external
        view
        submissionExists(_submissionId)
        returns (
            address projectOwner,
            string memory projectName,
            string memory documentHash,
            string memory remarks,
            ComplianceStatus status,
            uint256 timestamp
        )
    {
        ComplianceSubmission memory submission = submissions[_submissionId];
        return (
            submission.projectOwner,
            submission.projectName,
            submission.documentHash,
            submission.remarks,
            submission.status,
            submission.timestamp
        );
    }

    // Function to transfer ownership (e.g., new regulatory body)
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "New owner address cannot be zero");
        owner = _newOwner;
    }
}
