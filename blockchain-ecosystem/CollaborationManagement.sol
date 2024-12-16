// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CollaborationManagement {
    // Enum to define project status
    enum ProjectStatus { Proposed, Approved, Active, Completed, Cancelled }

    // Struct to define a collaboration project
    struct Collaboration {
        uint256 id;
        string name;
        string description;
        address proposer;
        address[] collaborators;
        ProjectStatus status;
        uint256 milestoneCount;
        uint256 completedMilestones;
    }

    // Struct to define project milestones
    struct Milestone {
        uint256 id;
        string description;
        bool isCompleted;
    }

    // Mapping to store collaborations by ID
    mapping(uint256 => Collaboration) public collaborations;

    // Nested mapping to store milestones for each project
    mapping(uint256 => Milestone[]) public milestones;

    // Counter to generate unique project IDs
    uint256 private collaborationIdCounter;

    // Events
    event CollaborationProposed(uint256 indexed id, string name, address proposer);
    event CollaborationApproved(uint256 indexed id, address approver);
    event MilestoneCompleted(uint256 indexed collaborationId, uint256 milestoneId);
    event CollaborationStatusUpdated(uint256 indexed id, ProjectStatus status);

    // Modifier to ensure only collaborators can act on a project
    modifier onlyCollaborators(uint256 _collaborationId) {
        Collaboration memory collaboration = collaborations[_collaborationId];
        bool isCollaborator = false;

        for (uint256 i = 0; i < collaboration.collaborators.length; i++) {
            if (msg.sender == collaboration.collaborators[i]) {
                isCollaborator = true;
                break;
            }
        }
        require(isCollaborator, "Only collaborators can perform this action");
        _;
    }

    // Function to propose a new collaboration
    function proposeCollaboration(
        string calldata _name,
        string calldata _description,
        address[] calldata _collaborators
    ) external returns (uint256) {
        require(_collaborators.length > 0, "At least one collaborator is required");

        uint256 newId = ++collaborationIdCounter;

        collaborations[newId] = Collaboration({
            id: newId,
            name: _name,
            description: _description,
            proposer: msg.sender,
            collaborators: _collaborators,
            status: ProjectStatus.Proposed,
            milestoneCount: 0,
            completedMilestones: 0
        });

        emit CollaborationProposed(newId, _name, msg.sender);
        return newId;
    }

    // Function to approve a collaboration
    function approveCollaboration(uint256 _collaborationId) external {
        Collaboration storage collaboration = collaborations[_collaborationId];
        require(collaboration.status == ProjectStatus.Proposed, "Collaboration is not in the proposed state");

        collaboration.status = ProjectStatus.Approved;
        emit CollaborationApproved(_collaborationId, msg.sender);
    }

    // Function to add milestones to a collaboration
    function addMilestones(uint256 _collaborationId, string[] calldata _milestoneDescriptions)
        external
        onlyCollaborators(_collaborationId)
    {
        Collaboration storage collaboration = collaborations[_collaborationId];
        require(collaboration.status == ProjectStatus.Approved || collaboration.status == ProjectStatus.Active, 
                "Collaboration must be approved or active");

        for (uint256 i = 0; i < _milestoneDescriptions.length; i++) {
            milestones[_collaborationId].push(Milestone({
                id: collaboration.milestoneCount + 1,
                description: _milestoneDescriptions[i],
                isCompleted: false
            }));
            collaboration.milestoneCount++;
        }
    }

    // Function to mark a milestone as completed
    function completeMilestone(uint256 _collaborationId, uint256 _milestoneId)
        external
        onlyCollaborators(_collaborationId)
    {
        Milestone storage milestone = milestones[_collaborationId][_milestoneId - 1];
        require(!milestone.isCompleted, "Milestone is already completed");

        milestone.isCompleted = true;
        collaborations[_collaborationId].completedMilestones++;

        emit MilestoneCompleted(_collaborationId, _milestoneId);
    }

    // Function to update collaboration status
    function updateCollaborationStatus(uint256 _collaborationId, ProjectStatus _newStatus)
        external
        onlyCollaborators(_collaborationId)
    {
        Collaboration storage collaboration = collaborations[_collaborationId];
        require(_newStatus != ProjectStatus.Proposed, "Cannot revert to Proposed status");

        collaboration.status = _newStatus;
        emit CollaborationStatusUpdated(_collaborationId, _newStatus);
    }

    // Function to get a list of collaborators for a project
    function getCollaborators(uint256 _collaborationId) external view returns (address[] memory) {
        return collaborations[_collaborationId].collaborators;
    }

    // Function to get all milestones for a project
    function getMilestones(uint256 _collaborationId) external view returns (Milestone[] memory) {
        return milestones[_collaborationId];
    }
}
