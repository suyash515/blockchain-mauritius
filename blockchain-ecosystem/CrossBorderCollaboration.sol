// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrossBorderCollaboration {
    // Struct to represent a collaboration request
    struct Collaboration {
        uint256 id;
        string description;
        address proposer;
        address[] participants;
        bool isApproved;
        uint256 timestamp;
    }

    // Mapping to store collaborations by ID
    mapping(uint256 => Collaboration) public collaborations;

    // Counter to generate unique collaboration IDs
    uint256 private collaborationIdCounter;

    // Address of the contract owner
    address public owner;

    // Events
    event CollaborationProposed(
        uint256 indexed id,
        address indexed proposer,
        string description,
        address[] participants
    );
    event CollaborationApproved(uint256 indexed id);
    event ParticipantAdded(uint256 indexed id, address indexed participant);
    event ParticipantRemoved(uint256 indexed id, address indexed participant);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier collaborationExists(uint256 _collaborationId) {
        require(collaborations[_collaborationId].proposer != address(0), "Collaboration does not exist");
        _;
    }

    // Constructor to initialize the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to propose a new collaboration
    function proposeCollaboration(string calldata _description, address[] calldata _participants) external returns (uint256) {
        require(bytes(_description).length > 0, "Description cannot be empty");
        require(_participants.length > 0, "At least one participant is required");

        uint256 newId = ++collaborationIdCounter;

        collaborations[newId] = Collaboration({
            id: newId,
            description: _description,
            proposer: msg.sender,
            participants: _participants,
            isApproved: false,
            timestamp: block.timestamp
        });

        emit CollaborationProposed(newId, msg.sender, _description, _participants);
        return newId;
    }

    // Function to approve a collaboration
    function approveCollaboration(uint256 _collaborationId) external onlyOwner collaborationExists(_collaborationId) {
        Collaboration storage collaboration = collaborations[_collaborationId];
        require(!collaboration.isApproved, "Collaboration is already approved");

        collaboration.isApproved = true;
        emit CollaborationApproved(_collaborationId);
    }

    // Function to add a participant to a collaboration
    function addParticipant(uint256 _collaborationId, address _participant)
        external
        onlyOwner
        collaborationExists(_collaborationId)
    {
        require(_participant != address(0), "Participant address cannot be zero");

        Collaboration storage collaboration = collaborations[_collaborationId];
        collaboration.participants.push(_participant);

        emit ParticipantAdded(_collaborationId, _participant);
    }

    // Function to remove a participant from a collaboration
    function removeParticipant(uint256 _collaborationId, address _participant)
        external
        onlyOwner
        collaborationExists(_collaborationId)
    {
        Collaboration storage collaboration = collaborations[_collaborationId];
        bool found = false;

        for (uint256 i = 0; i < collaboration.participants.length; i++) {
            if (collaboration.participants[i] == _participant) {
                collaboration.participants[i] = collaboration.participants[collaboration.participants.length - 1];
                collaboration.participants.pop();
                found = true;
                break;
            }
        }

        require(found, "Participant not found in this collaboration");
        emit ParticipantRemoved(_collaborationId, _participant);
    }

    // Function to get participants of a collaboration
    function getParticipants(uint256 _collaborationId) external view collaborationExists(_collaborationId) returns (address[] memory) {
        return collaborations[_collaborationId].participants;
    }
}
