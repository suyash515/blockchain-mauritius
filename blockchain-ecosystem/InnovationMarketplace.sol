
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InnovationMarketplace {
    // Enum to define project statuses
    enum ProjectStatus { Submitted, Approved, Funded, InProgress, Completed, Cancelled }

    // Struct to represent a project
    struct Project {
        uint256 id;
        string name;
        string description;
        address proposer;
        uint256 fundingGoal;
        uint256 fundsRaised;
        ProjectStatus status;
    }

    // Mapping to store projects by ID
    mapping(uint256 => Project) public projects;

    // Counter to generate unique project IDs
    uint256 private projectIdCounter;

    // Mapping to track funders and their contributions for each project
    mapping(uint256 => mapping(address => uint256)) public contributions;

    // Address of the contract owner
    address public owner;

    // Events
    event ProjectSubmitted(uint256 indexed projectId, string name, address proposer, uint256 fundingGoal);
    event ProjectApproved(uint256 indexed projectId, address approver);
    event FundsContributed(uint256 indexed projectId, address contributor, uint256 amount);
    event ProjectStatusUpdated(uint256 indexed projectId, ProjectStatus newStatus);

    // Modifier to restrict actions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Modifier to ensure project exists
    modifier projectExists(uint256 _projectId) {
        require(projects[_projectId].proposer != address(0), "Project does not exist");
        _;
    }

    // Modifier to check project status
    modifier checkStatus(uint256 _projectId, ProjectStatus _requiredStatus) {
        require(projects[_projectId].status == _requiredStatus, "Invalid project status for this action");
        _;
    }

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to submit a new project
    function submitProject(
        string calldata _name,
        string calldata _description,
        uint256 _fundingGoal
    ) external returns (uint256) {
        require(_fundingGoal > 0, "Funding goal must be greater than zero");

        uint256 newId = ++projectIdCounter;

        projects[newId] = Project({
            id: newId,
            name: _name,
            description: _description,
            proposer: msg.sender,
            fundingGoal: _fundingGoal,
            fundsRaised: 0,
            status: ProjectStatus.Submitted
        });

        emit ProjectSubmitted(newId, _name, msg.sender, _fundingGoal);
        return newId;
    }

    // Function to approve a project
    function approveProject(uint256 _projectId)
        external
        onlyOwner
        projectExists(_projectId)
        checkStatus(_projectId, ProjectStatus.Submitted)
    {
        projects[_projectId].status = ProjectStatus.Approved;
        emit ProjectApproved(_projectId, msg.sender);
    }

    // Function to contribute funds to a project
    function contributeFunds(uint256 _projectId)
        external
        payable
        projectExists(_projectId)
        checkStatus(_projectId, ProjectStatus.Approved)
    {
        require(msg.value > 0, "Contribution must be greater than zero");

        Project storage project = projects[_projectId];
        project.fundsRaised += msg.value;
        contributions[_projectId][msg.sender] += msg.value;

        // Automatically move to Funded status if funding goal is reached
        if (project.fundsRaised >= project.fundingGoal) {
            project.status = ProjectStatus.Funded;
            emit ProjectStatusUpdated(_projectId, ProjectStatus.Funded);
        }

        emit FundsContributed(_projectId, msg.sender, msg.value);
    }

    // Function to start a project
    function startProject(uint256 _projectId)
        external
        projectExists(_projectId)
        checkStatus(_projectId, ProjectStatus.Funded)
    {
        require(msg.sender == projects[_projectId].proposer, "Only the proposer can start the project");

        projects[_projectId].status = ProjectStatus.InProgress;
        emit ProjectStatusUpdated(_projectId, ProjectStatus.InProgress);
    }

    // Function to mark a project as completed
    function completeProject(uint256 _projectId)
        external
        projectExists(_projectId)
        checkStatus(_projectId, ProjectStatus.InProgress)
    {
        require(msg.sender == projects[_projectId].proposer, "Only the proposer can mark the project as completed");

        projects[_projectId].status = ProjectStatus.Completed;
        emit ProjectStatusUpdated(_projectId, ProjectStatus.Completed);
    }

    // Function to cancel a project
    function cancelProject(uint256 _projectId)
        external
        projectExists(_projectId)
    {
        Project storage project = projects[_projectId];
        require(
            msg.sender == owner || msg.sender == project.proposer,
            "Only the owner or proposer can cancel the project"
        );
        require(
            project.status != ProjectStatus.Completed && project.status != ProjectStatus.Cancelled,
            "Project cannot be cancelled"
        );

        project.status = ProjectStatus.Cancelled;
        emit ProjectStatusUpdated(_projectId, ProjectStatus.Cancelled);
    }

    // Function to get details of a project
    function getProjectDetails(uint256 _projectId)
        external
        view
        projectExists(_projectId)
        returns (
            string memory name,
            string memory description,
            address proposer,
            uint256 fundingGoal,
            uint256 fundsRaised,
            ProjectStatus status
        )
    {
        Project memory project = projects[_projectId];
        return (
            project.name,
            project.description,
            project.proposer,
            project.fundingGoal,
            project.fundsRaised,
            project.status
        );
    }
}
