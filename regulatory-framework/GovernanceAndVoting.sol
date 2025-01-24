// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GovernanceAndVoting {
    address public admin;

    struct Proposal {
        string description;
        uint256 voteCountFor;
        uint256 voteCountAgainst;
        uint256 startTime;
        uint256 endTime;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    uint256 public proposalCount;

    event ProposalCreated(uint256 indexed proposalId, string description, uint256 startTime, uint256 endTime);
    event VoteCast(uint256 indexed proposalId, address indexed voter, bool support);
    event ProposalExecuted(uint256 indexed proposalId, bool passed);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier validProposal(uint256 proposalId) {
        require(proposalId < proposalCount, "Invalid proposal ID");
        _;
    }

    modifier votingActive(uint256 proposalId) {
        Proposal memory proposal = proposals[proposalId];
        require(block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime, "Voting is not active");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createProposal(string calldata description, uint256 votingDuration) external onlyAdmin {
        require(votingDuration > 0, "Voting duration must be greater than zero");

        uint256 startTime = block.timestamp;
        uint256 endTime = block.timestamp + votingDuration;

        proposals[proposalCount] = Proposal({
            description: description,
            voteCountFor: 0,
            voteCountAgainst: 0,
            startTime: startTime,
            endTime: endTime,
            executed: false
        });

        emit ProposalCreated(proposalCount, description, startTime, endTime);
        proposalCount++;
    }

    function vote(uint256 proposalId, bool support) external validProposal(proposalId) votingActive(proposalId) {
        require(!hasVoted[proposalId][msg.sender], "You have already voted on this proposal");

        Proposal storage proposal = proposals[proposalId];
        if (support) {
            proposal.voteCountFor++;
        } else {
            proposal.voteCountAgainst++;
        }

        hasVoted[proposalId][msg.sender] = true;

        emit VoteCast(proposalId, msg.sender, support);
    }

    function executeProposal(uint256 proposalId) external validProposal(proposalId) {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Voting period is still active");
        require(!proposal.executed, "Proposal has already been executed");

        proposal.executed = true;
        bool passed = proposal.voteCountFor > proposal.voteCountAgainst;

        emit ProposalExecuted(proposalId, passed);
    }

    function updateAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        admin = newAdmin;
    }
}

