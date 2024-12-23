// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeeAndRewardDistribution {
    // Events
    event FeeCollected(address indexed payer, uint256 amount, uint256 timestamp);
    event RewardDistributed(address indexed recipient, uint256 amount, uint256 timestamp);
    event StakeholderAdded(address indexed stakeholder, uint256 sharePercentage, uint256 timestamp);
    event StakeholderUpdated(address indexed stakeholder, uint256 newSharePercentage, uint256 timestamp);

    // Struct for stakeholders
    struct Stakeholder {
        uint256 sharePercentage; // Percentage of the total fees/rewards (in basis points, 1% = 100)
        bool exists;
    }

    // Mapping of stakeholders and their share percentages
    mapping(address => Stakeholder) public stakeholders;

    // Total collected fees
    uint256 public totalFees;

    // Modifier to ensure the caller is an existing stakeholder
    modifier onlyStakeholder() {
        require(stakeholders[msg.sender].exists, "Caller is not a stakeholder");
        _;
    }

    // Modifier to ensure valid share percentages
    modifier validShare(uint256 sharePercentage) {
        require(sharePercentage > 0 && sharePercentage <= 10000, "Invalid share percentage");
        _;
    }

    // Owner of the contract
    address public owner;

    // Modifier to restrict access to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to add a new stakeholder
    function addStakeholder(address stakeholder, uint256 sharePercentage) external onlyOwner validShare(sharePercentage) {
        require(stakeholder != address(0), "Invalid stakeholder address");
        require(!stakeholders[stakeholder].exists, "Stakeholder already exists");

        stakeholders[stakeholder] = Stakeholder({
            sharePercentage: sharePercentage,
            exists: true
        });

        emit StakeholderAdded(stakeholder, sharePercentage, block.timestamp);
    }

    // Function to update a stakeholder's share percentage
    function updateStakeholder(address stakeholder, uint256 newSharePercentage)
        external
        onlyOwner
        validShare(newSharePercentage)
    {
        require(stakeholders[stakeholder].exists, "Stakeholder does not exist");

        stakeholders[stakeholder].sharePercentage = newSharePercentage;

        emit StakeholderUpdated(stakeholder, newSharePercentage, block.timestamp);
    }

    // Function to collect fees
    function collectFee() external payable {
        require(msg.value > 0, "Fee amount must be greater than zero");

        totalFees += msg.value;

        emit FeeCollected(msg.sender, msg.value, block.timestamp);
    }

    // Function to distribute rewards to stakeholders
    function distributeRewards() external onlyOwner {
        require(totalFees > 0, "No fees to distribute");

        uint256 totalDistributed = 0;

        // Distribute fees based on share percentages
        for (uint256 i = 0; i < address(this).balance; i++) {
            address stakeholder = address(i);
            Stakeholder memory stakeholderInfo = stakeholders[stakeholder];

            if (stakeholderInfo.exists) {
                uint256 reward = (totalFees * stakeholderInfo.sharePercentage) / 10000;
                totalDistributed += reward;

                payable(stakeholder).transfer(reward);

                emit RewardDistributed(stakeholder, reward, block.timestamp);
            }
        }

        // Reset total fees after distribution
        totalFees -= totalDistributed;
    }

    // Function to view a stakeholder's share percentage
    function getStakeholderShare(address stakeholder) external view returns (uint256) {
        require(stakeholders[stakeholder].exists, "Stakeholder does not exist");
        return stakeholders[stakeholder].sharePercentage;
    }

    // Function to get the contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
