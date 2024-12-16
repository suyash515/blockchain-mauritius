// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InvestmentAndFunding {
    // Struct to represent an investment project
    struct Project {
        uint256 id;
        string name;
        string description;
        address proposer;
        uint256 fundingGoal;
        uint256 fundsRaised;
        bool isFunded;
        bool isActive;
        uint256 timestamp;
    }

    // Mapping to store projects by ID
    mapping(uint256 => Project) public projects;

    // Mapping to track investments per project and investor
    mapping(uint256 => mapping(address => uint256)) public investments;

    // Counter to generate unique project IDs
    uint256 private projectIdCounter;

    // Address of the contract owner
    address public owner;

    // Events
    event ProjectCreated(uint256 indexed id, string name, address proposer, uint256 fundingGoal);
    event FundsInvested(uint256 indexed projectId, address indexed investor, uint256 amount);
    event ProjectFunded(uint256 indexed projectId, uint256 totalFunds);
    event ProjectActivated(uint256 indexed projectId);
    event FundsWithdrawn(uint256 indexed projectId, uint256 amount, address proposer);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier projectExists(uint256 _projectId) {
        require(projects[_projectId].proposer != address(0), "Project does not exist");
        _;
    }

    modifier onlyProposer(uint256 _projectId) {
        require(msg.sender == projects[_projectId].proposer, "Only the project proposer can perform this action");
        _;
    }

    modifier isActive(uint256 _projectId) {
        require(projects[_projectId].isActive, "Project is not active");
        _;
    }

    // Constructor to initialize the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to create a new investment project
    function createProject(string calldata _name, string calldata _description, uint256 _fundingGoal) external returns (uint256) {
        require(bytes(_name).length > 0, "Project name cannot be empty");
        require(bytes(_description).length > 0, "Project description cannot be empty");
        require(_fundingGoal > 0, "Funding goal must be greater than zero");

        uint256 newId = ++projectIdCounter;

        projects[newId] = Project({
            id: newId,
            name: _name,
            description: _description,
            proposer: msg.sender,
            fundingGoal: _fundingGoal,
            fundsRaised: 0,
            isFunded: false,
            isActive: false,
            timestamp: block.timestamp
        });

        emit ProjectCreated(newId, _name, msg.sender, _fundingGoal);
        return newId;
    }

    // Function to invest in a project
    function invest(uint256 _projectId) external payable projectExists(_projectId) {
        require(msg.value > 0, "Investment amount must be greater than zero");

        Project storage project = projects[_projectId];
        require(!project.isFunded, "Project funding goal already met");

        project.fundsRaised += msg.value;
        investments[_projectId][msg.sender] += msg.value;

        emit FundsInvested(_projectId, msg.sender, msg.value);

        if (project.fundsRaised >= project.fundingGoal) {
            project.isFunded = true;
            emit ProjectFunded(_projectId, project.fundsRaised);
        }
    }

    // Function to activate a project after funding is complete
    function activateProject(uint256 _projectId) external onlyProposer(_projectId) projectExists(_projectId) {
        Project storage project = projects[_projectId];
        require(project.isFunded, "Project funding goal not met");
        require(!project.isActive, "Project is already active");

        project.isActive = true;

        emit ProjectActivated(_projectId);
    }

    // Function to withdraw funds by the project proposer
    function withdrawFunds(uint256 _projectId) external onlyProposer(_projectId) isActive(_projectId) {
        Project storage project = projects[_projectId];
        uint256 funds = project.fundsRaised;

        require(funds > 0, "No funds available to withdraw");

        project.fundsRaised = 0;
        payable(project.proposer).transfer(funds);

        emit FundsWithdrawn(_projectId, funds, msg.sender);
    }

    // Function to get project details
    function getProject(uint256 _projectId) external view projectExists(_projectId) returns (
        string memory name,
        string memory description,
        address proposer,
        uint256 fundingGoal,
        uint256 fundsRaised,
        bool isFunded,
        bool isActive,
        uint256 timestamp
    ) {
        Project memory project = projects[_projectId];
        return (
            project.name,
            project.description,
            project.proposer,
            project.fundingGoal,
            project.fundsRaised,
            project.isFunded,
            project.isActive,
            project.timestamp
        );
    }

    // Function to check an investor's contribution to a project
    function getInvestment(uint256 _projectId, address _investor) external view projectExists(_projectId) returns (uint256) {
        return investments[_projectId][_investor];
    }
}
