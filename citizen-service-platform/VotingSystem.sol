// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint256 votedCandidateId;
        bool isRegistered;
    }

    address public electionCommission;
    bool public votingOpen;
    uint256 private candidateCounter;

    mapping(uint256 => Candidate) private candidates;
    mapping(address => Voter) private voters;

    event CandidateRegistered(uint256 indexed candidateId, string name);
    event VoterRegistered(address indexed voter);
    event VoteCast(address indexed voter, uint256 indexed candidateId);
    event VotingStarted();
    event VotingEnded();

    modifier onlyElectionCommission() {
        require(msg.sender == electionCommission, "Not authorized");
        _;
    }

    modifier whenVotingOpen() {
        require(votingOpen, "Voting is not open");
        _;
    }

    modifier whenVotingClosed() {
        require(!votingOpen, "Voting is still open");
        _;
    }

    constructor() {
        electionCommission = msg.sender;
        votingOpen = false;
    }

    // Register a candidate
    function registerCandidate(string memory _name) public onlyElectionCommission whenVotingClosed {
        candidateCounter++;
        candidates[candidateCounter] = Candidate({
            id: candidateCounter,
            name: _name,
            voteCount: 0
        });

        emit CandidateRegistered(candidateCounter, _name);
    }

    // Register a voter
    function registerVoter(address _voter) public onlyElectionCommission whenVotingClosed {
        require(!voters[_voter].isRegistered, "Voter is already registered");

        voters[_voter] = Voter({
            hasVoted: false,
            votedCandidateId: 0,
            isRegistered: true
        });

        emit VoterRegistered(_voter);
    }

    // Start the voting process
    function startVoting() public onlyElectionCommission whenVotingClosed {
        votingOpen = true;
        emit VotingStarted();
    }

    // End the voting process
    function endVoting() public onlyElectionCommission whenVotingOpen {
        votingOpen = false;
        emit VotingEnded();
    }

    // Cast a vote
    function vote(uint256 _candidateId) public whenVotingOpen {
        require(voters[msg.sender].isRegistered, "Not a registered voter");
        require(!voters[msg.sender].hasVoted, "Already voted");
        require(candidates[_candidateId].id != 0, "Invalid candidate ID");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;

        candidates[_candidateId].voteCount++;

        emit VoteCast(msg.sender, _candidateId);
    }

    // View candidate details
    function getCandidate(uint256 _candidateId) public view returns (string memory name, uint256 voteCount) {
        require(candidates[_candidateId].id != 0, "Invalid candidate ID");

        Candidate memory candidate = candidates[_candidateId];
        return (candidate.name, candidate.voteCount);
    }

    // Get total votes for a candidate
    function getTotalVotes(uint256 _candidateId) public view returns (uint256) {
        require(candidates[_candidateId].id != 0, "Invalid candidate ID");
        return candidates[_candidateId].voteCount;
    }
}
