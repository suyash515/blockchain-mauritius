// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Governance {
    struct Proposal {
        uint256 id;
        string description;
        address proposer;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 createdAt;
        uint256 deadline;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    uint256 public proposalCounter;
    address public admin;

    event ProposalCreated(
        uint256 indexed id,
        string description,
        address indexed proposer,
        uint256 createdAt,
        uint256 deadline
    );

    event VoteCast(
        uint256 indexed proposalId,
        address indexed voter,
        bool support
    );

    event ProposalExecuted(
        uint256 indexed id,
        bool success
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier activeProposal(uint256 _proposalId) {
        require(
            proposals[_proposalId].deadline > block.timestamp,
            "Proposal voting period has ended"
        );
        require(!proposals[_proposalId].executed, "Proposal already executed");
        _;
    }

    constructor() {
        admin = msg.sender;
        proposalCounter = 0;
    }

    function createProposal(string memory _description, uint256 _votingDuration)
        public
        onlyAdmin
    {
        require(bytes(_description).length > 0, "Description cannot be empty");
        require(_votingDuration > 0, "Voting duration must be greater than zero");

        proposalCounter++;
        proposals[proposalCounter] = Proposal({
            id: proposalCounter,
            description: _description,
            proposer: msg.sender,
            yesVotes: 0,
            noVotes: 0,
            createdAt: block.timestamp,
            deadline: block.timestamp + _votingDuration,
            executed: false
        });

        emit ProposalCreated(
            proposalCounter,
            _description,
            msg.sender,
            block.timestamp,
            block.timestamp + _votingDuration
        );
    }

    function vote(uint256 _proposalId, bool _support) public activeProposal(_proposalId) {
        require(!hasVoted[_proposalId][msg.sender], "You have already voted");

        Proposal storage proposal = proposals[_proposalId];

        if (_support) {
            proposal.yesVotes++;
        } else {
            proposal.noVotes++;
        }

        hasVoted[_proposalId][msg.sender] = true;

        emit VoteCast(_proposalId, msg.sender, _support);
    }

    function executeProposal(uint256 _proposalId) public onlyAdmin {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.deadline, "Voting period has not ended");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;

        bool success = proposal.yesVotes > proposal.noVotes;
        emit ProposalExecuted(_proposalId, success);
    }

    function getProposal(uint256 _proposalId) public view returns (Proposal memory) {
        return proposals[_proposalId];
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
}
