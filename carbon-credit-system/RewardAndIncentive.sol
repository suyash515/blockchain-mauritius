// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RewardAndIncentive {
    struct Reward {
        uint256 timestamp;
        uint256 amount; // Reward amount (e.g., tokens or credits)
        string reason; // Reason for the reward (e.g., "Exceeded sustainability goals")
    }

    mapping(address => Reward[]) public rewards;
    mapping(address => uint256) public totalRewards; // Track total rewards for each business
    address public admin;

    event RewardIssued(
        address indexed business,
        uint256 amount,
        string reason,
        uint256 timestamp
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function issueReward(
        address _business,
        uint256 _amount,
        string memory _reason
    ) public onlyAdmin {
        require(_business != address(0), "Invalid business address");
        require(_amount > 0, "Reward amount must be greater than zero");

        rewards[_business].push(Reward({
            timestamp: block.timestamp,
            amount: _amount,
            reason: _reason
        }));

        totalRewards[_business] += _amount;

        emit RewardIssued(_business, _amount, _reason, block.timestamp);
    }

    function getRewards(address _business) public view returns (Reward[] memory) {
        return rewards[_business];
    }

    function getTotalRewards(address _business) public view returns (uint256) {
        return totalRewards[_business];
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
}
