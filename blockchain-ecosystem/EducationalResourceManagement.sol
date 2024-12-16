// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EducationalResourceManagement {
    // Struct to define an educational resource
    struct Resource {
        uint256 id;
        string title;
        string description;
        string contentHash; // IPFS or other decentralized storage hash
        address contributor;
        uint256 timestamp;
        uint256 upvotes;
    }

    // Mapping to store resources by ID
    mapping(uint256 => Resource) public resources;

    // Counter to generate unique resource IDs
    uint256 private resourceIdCounter;

    // Mapping to track user upvotes for resources
    mapping(uint256 => mapping(address => bool)) private hasUpvoted;

    // Address of the contract owner
    address public owner;

    // Token balance mapping for incentivization (for simplicity, not tied to ERC20 here)
    mapping(address => uint256) public tokenBalance;

    // Reward amount for contributing resources
    uint256 public contributionReward = 10; // Example fixed token reward
    uint256 public upvoteReward = 2; // Example reward for content contributors per upvote

    // Events
    event ResourceSubmitted(uint256 indexed id, string title, address indexed contributor);
    event ResourceUpvoted(uint256 indexed id, address indexed voter);
    event TokensRewarded(address indexed recipient, uint256 amount);

    // Modifier to restrict actions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to submit a new resource
    function submitResource(
        string calldata _title,
        string calldata _description,
        string calldata _contentHash
    ) external returns (uint256) {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_contentHash).length > 0, "Content hash cannot be empty");

        uint256 newId = ++resourceIdCounter;

        resources[newId] = Resource({
            id: newId,
            title: _title,
            description: _description,
            contentHash: _contentHash,
            contributor: msg.sender,
            timestamp: block.timestamp,
            upvotes: 0
        });

        // Reward the contributor with tokens
        tokenBalance[msg.sender] += contributionReward;

        emit ResourceSubmitted(newId, _title, msg.sender);
        emit TokensRewarded(msg.sender, contributionReward);
        return newId;
    }

    // Function to upvote a resource
    function upvoteResource(uint256 _resourceId) external {
        require(resources[_resourceId].contributor != address(0), "Resource does not exist");
        require(!hasUpvoted[_resourceId][msg.sender], "You have already upvoted this resource");

        Resource storage resource = resources[_resourceId];
        resource.upvotes += 1;
        hasUpvoted[_resourceId][msg.sender] = true;

        // Reward the contributor for the upvote
        tokenBalance[resource.contributor] += upvoteReward;

        emit ResourceUpvoted(_resourceId, msg.sender);
        emit TokensRewarded(resource.contributor, upvoteReward);
    }

    // Function to retrieve a resource by ID
    function getResource(uint256 _resourceId)
        external
        view
        returns (
            string memory title,
            string memory description,
            string memory contentHash,
            address contributor,
            uint256 timestamp,
            uint256 upvotes
        )
    {
        Resource memory resource = resources[_resourceId];
        require(resource.contributor != address(0), "Resource does not exist");
        return (
            resource.title,
            resource.description,
            resource.contentHash,
            resource.contributor,
            resource.timestamp,
            resource.upvotes
        );
    }

    // Function to adjust token reward values (owner only)
    function setRewards(uint256 _contributionReward, uint256 _upvoteReward) external onlyOwner {
        contributionReward = _contributionReward;
        upvoteReward = _upvoteReward;
    }

    // Function to withdraw tokens (for simplicity, this is just a placeholder for future token transfers)
    function withdrawTokens() external {
        uint256 balance = tokenBalance[msg.sender];
        require(balance > 0, "No tokens to withdraw");

        // Simulate token transfer (in actual implementation, integrate with an ERC20 token contract)
        tokenBalance[msg.sender] = 0;

        // Emit an event or handle actual transfer
        // This is just a simulation step for educational use cases
    }
}
