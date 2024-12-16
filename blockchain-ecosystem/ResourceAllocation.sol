// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ResourceAllocation {
    // Struct to represent a resource allocation request
    struct ResourceRequest {
        uint256 id;
        address requester;
        string description;
        uint256 requestedAmount;
        uint256 approvedAmount;
        bool isApproved;
        bool isDisbursed;
        uint256 timestamp;
    }

    // Mapping to store resource requests by ID
    mapping(uint256 => ResourceRequest) public resourceRequests;

    // Counter to generate unique resource request IDs
    uint256 private requestIdCounter;

    // Mapping to track stakeholder balances (for incentivization rewards)
    mapping(address => uint256) public stakeholderBalances;

    // Address of the contract owner (e.g., governing authority)
    address public owner;

    // Events
    event ResourceRequested(
        uint256 indexed id,
        address indexed requester,
        string description,
        uint256 requestedAmount
    );
    event ResourceApproved(uint256 indexed id, uint256 approvedAmount);
    event ResourceDisbursed(uint256 indexed id, uint256 disbursedAmount, address recipient);
    event IncentiveRewarded(address indexed stakeholder, uint256 rewardAmount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier requestExists(uint256 _requestId) {
        require(resourceRequests[_requestId].requester != address(0), "Request does not exist");
        _;
    }

    modifier requestNotDisbursed(uint256 _requestId) {
        require(!resourceRequests[_requestId].isDisbursed, "Request has already been disbursed");
        _;
    }

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to create a new resource request
    function createResourceRequest(string calldata _description, uint256 _requestedAmount) external returns (uint256) {
        require(_requestedAmount > 0, "Requested amount must be greater than zero");
        require(bytes(_description).length > 0, "Description cannot be empty");

        uint256 newId = ++requestIdCounter;

        resourceRequests[newId] = ResourceRequest({
            id: newId,
            requester: msg.sender,
            description: _description,
            requestedAmount: _requestedAmount,
            approvedAmount: 0,
            isApproved: false,
            isDisbursed: false,
            timestamp: block.timestamp
        });

        emit ResourceRequested(newId, msg.sender, _description, _requestedAmount);
        return newId;
    }

    // Function to approve a resource request
    function approveResourceRequest(uint256 _requestId, uint256 _approvedAmount)
        external
        onlyOwner
        requestExists(_requestId)
    {
        require(_approvedAmount > 0, "Approved amount must be greater than zero");

        ResourceRequest storage request = resourceRequests[_requestId];
        require(!request.isApproved, "Request has already been approved");

        request.approvedAmount = _approvedAmount;
        request.isApproved = true;

        emit ResourceApproved(_requestId, _approvedAmount);
    }

    // Function to disburse resources for an approved request
    function disburseResources(uint256 _requestId)
        external
        onlyOwner
        requestExists(_requestId)
        requestNotDisbursed(_requestId)
    {
        ResourceRequest storage request = resourceRequests[_requestId];
        require(request.isApproved, "Request must be approved before disbursement");

        request.isDisbursed = true;

        // Add approved amount to the requester's balance
        stakeholderBalances[request.requester] += request.approvedAmount;

        emit ResourceDisbursed(_requestId, request.approvedAmount, request.requester);
    }

    // Function to reward stakeholders with incentives
    function rewardStakeholder(address _stakeholder, uint256 _rewardAmount) external onlyOwner {
        require(_rewardAmount > 0, "Reward amount must be greater than zero");

        stakeholderBalances[_stakeholder] += _rewardAmount;

        emit IncentiveRewarded(_stakeholder, _rewardAmount);
    }

    // Function to withdraw balance (for incentivization rewards)
    function withdrawBalance() external {
        uint256 balance = stakeholderBalances[msg.sender];
        require(balance > 0, "No balance to withdraw");

        stakeholderBalances[msg.sender] = 0;

        // Simulating token transfer - replace with actual token logic if needed
        payable(msg.sender).transfer(balance);

        // Logically, in a real-world case, you'd integrate with an ERC20 token contract for transfer
    }

    // Function to retrieve details of a resource request
    function getResourceRequest(uint256 _requestId)
        external
        view
        requestExists(_requestId)
        returns (
            address requester,
            string memory description,
            uint256 requestedAmount,
            uint256 approvedAmount,
            bool isApproved,
            bool isDisbursed,
            uint256 timestamp
        )
    {
        ResourceRequest memory request = resourceRequests[_requestId];
        return (
            request.requester,
            request.description,
            request.requestedAmount,
            request.approvedAmount,
            request.isApproved,
            request.isDisbursed,
            request.timestamp
        );
    }
}
