// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingAndGovernance {
    // Enum to define the status of a proposal
    enum ProposalStatus { Pending, Active, Passed, Rejected, Executed }

    // Struct to represent a proposal
    struct Proposal {
        uint256 id;
        string description;
        address proposer;
        uint256 startTime;
        uint256 endTime;
        uint256 votesFor;
        uint256 votesAgainst;
        ProposalStatus status;
        bool executed;
    }

    // Mapping to store proposals by ID
    mapping(uint256 => Proposal) public proposals;

    // Mapping to track if an address has voted on a specific proposal
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // Counter to generate unique proposal IDs
    uint256 private proposalIdCounter;

    // Governance roles
    address public owner;
    mapping(address => bool) public stakeholders;

    // Events
    event ProposalCreated(uint256 indexed id, string description, address indexed proposer, uint256 startTime, uint256 endTime);
    event Voted(uint256 indexed id, address indexed voter, bool voteFor);
    event ProposalExecuted(uint256 indexed id);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyStakeholder() {
        require(stakeholders[msg.sender], "Only stakeholders can perform this action");
        _;
    }

    modifier proposalExists(uint256 _proposalId) {
        require(proposals[_proposalId].proposer != address(0), "Proposal does not exist");
        _;
    }

    modifier proposalActive(uint256 _proposalId) {
        Proposal memory proposal = proposals[_proposalId];
        require(block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime, "Proposal is not active");
        require(proposal.status == ProposalStatus.Active, "Proposal is not in active status");
        _;
    }

    // Constructor to initialize the owner
    constructor() {
        owner = msg.sender;
        stakeholders[msg.sender] = true; // Owner is the initial stakeholder
    }

    // Function to add a stakeholder
    function addStakeholder(address _stakeholder) external onlyOwner {
        stakeholders[_stakeholder] = true;
    }

    // Function to remove a stakeholder
    function removeStakeholder(address _stakeholder) external onlyOwner {
        stakeholders[_stakeholder] = false;
    }

    // Function to create a new proposal
    function createProposal(string calldata _description, uint256 _duration) external onlyStakeholder returns (uint256) {
        require(bytes(_description).length > 0, "Description cannot be empty");
        require(_duration > 0, "Duration must be greater than zero");

        uint256 newId = ++proposalIdCounter;
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + _duration;

        proposals[newId] = Proposal({
            id: newId,
            description: _description,
            proposer: msg.sender,
            startTime: startTime,
            endTime: endTime,
            votesFor: 0,
            votesAgainst: 0,
            status: ProposalStatus.Active,
            executed: false
        });

        emit ProposalCreated(newId, _description, msg.sender, startTime, endTime);
        return newId;
    }

    // Function to cast a vote on a proposal
    function vote(uint256 _proposalId, bool _voteFor) external onlyStakeholder proposalExists(_proposalId) proposalActive(_proposalId) {
        require(!hasVoted[_proposalId][msg.sender], "You have already voted on this proposal");

        Proposal storage proposal = proposals[_proposalId];

        if (_voteFor) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        hasVoted[_proposalId][msg.sender] = true;

        emit Voted(_proposalId, msg.sender, _voteFor);
    }

    // Function to finalize a proposal after its voting period has ended
    function finalizeProposal(uint256 _proposalId) external proposalExists(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.endTime, "Voting period has not ended");
        require(proposal.status == ProposalStatus.Active, "Proposal is not active");

        if (proposal.votesFor > proposal.votesAgainst) {
            proposal.status = ProposalStatus.Passed;
        } else {
            proposal.status = ProposalStatus.Rejected;
        }
    }

    // Function to execute a passed proposal
    function executeProposal(uint256 _proposalId) external proposalExists(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.status == ProposalStatus.Passed, "Proposal is not approved");
        require(!proposal.executed, "Proposal has already been executed");

        // Placeholder for actual execution logic
        proposal.executed = true;

        emit ProposalExecuted(_proposalId);
    }

    // Function to retrieve details of a proposal
    function getProposal(uint256 _proposalId)
        external
        view
        proposalExists(_proposalId)
        returns (
            string memory description,
            address proposer,
            uint256 startTime,
            uint256 endTime,
            uint256 votesFor,
            uint256 votesAgainst,
            ProposalStatus status,
            bool executed
        )
    {
        Proposal memory proposal = proposals[_proposalId];
        return (
            proposal.description,
            proposal.proposer,
            proposal.startTime,
            proposal.endTime,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.status,
            proposal.executed
        );
    }
}
