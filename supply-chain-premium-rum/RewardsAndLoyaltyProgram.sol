// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RewardsAndLoyaltyProgram {
    struct Consumer {
        address consumerAddress;
        uint256 points;
        bool isRegistered;
    }

    struct Reward {
        uint256 id;
        string name;
        uint256 pointsRequired;
        bool isActive;
    }

    uint256 private rewardCounter;
    mapping(address => Consumer) private consumers;
    mapping(uint256 => Reward) private rewards;

    event ConsumerRegistered(address consumer);
    event PointsAwarded(address consumer, uint256 points);
    event RewardRedeemed(address consumer, uint256 rewardId);
    event RewardCreated(uint256 rewardId, string name, uint256 pointsRequired);

    modifier onlyRegisteredConsumer() {
        require(consumers[msg.sender].isRegistered, "Consumer is not registered.");
        _;
    }

    function registerConsumer() public {
        require(!consumers[msg.sender].isRegistered, "Consumer already registered.");
        consumers[msg.sender] = Consumer({
            consumerAddress: msg.sender,
            points: 0,
            isRegistered: true
        });

        emit ConsumerRegistered(msg.sender);
    }

    function awardPoints(address consumer, uint256 points) public {
        require(consumers[consumer].isRegistered, "Consumer is not registered.");
        consumers[consumer].points += points;

        emit PointsAwarded(consumer, points);
    }

    function createReward(string memory name, uint256 pointsRequired) public returns (uint256) {
        rewardCounter++;
        rewards[rewardCounter] = Reward({
            id: rewardCounter,
            name: name,
            pointsRequired: pointsRequired,
            isActive: true
        });

        emit RewardCreated(rewardCounter, name, pointsRequired);
        return rewardCounter;
    }

    function redeemReward(uint256 rewardId) public onlyRegisteredConsumer {
        require(rewards[rewardId].isActive, "Reward is not active.");
        require(consumers[msg.sender].points >= rewards[rewardId].pointsRequired, "Insufficient points.");

        consumers[msg.sender].points -= rewards[rewardId].pointsRequired;

        emit RewardRedeemed(msg.sender, rewardId);
    }

    function getConsumerDetails(address consumer) public view returns (uint256 points, bool isRegistered) {
        Consumer memory c = consumers[consumer];
        return (c.points, c.isRegistered);
    }

    function getRewardDetails(uint256 rewardId) public view returns (
        uint256 id,
        string memory name,
        uint256 pointsRequired,
        bool isActive
    ) {
        Reward memory reward = rewards[rewardId];
        return (reward.id, reward.name, reward.pointsRequired, reward.isActive);
    }
}
