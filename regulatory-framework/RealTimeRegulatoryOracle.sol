// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RealTimeRegulatoryOracle {
    address public admin;
    mapping(string => string) public regulatoryData;
    mapping(address => bool) public authorizedConsumers;

    event RegulatoryDataUpdated(string key, string value, uint256 timestamp);
    event ConsumerAuthorized(address indexed consumer);
    event ConsumerRevoked(address indexed consumer);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier onlyAuthorizedConsumer() {
        require(authorizedConsumers[msg.sender], "Only authorized consumers can access this data");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function updateRegulatoryData(string calldata key, string calldata value) external onlyAdmin {
        regulatoryData[key] = value;
        emit RegulatoryDataUpdated(key, value, block.timestamp);
    }

    function authorizeConsumer(address consumer) external onlyAdmin {
        require(consumer != address(0), "Invalid consumer address");
        authorizedConsumers[consumer] = true;
        emit ConsumerAuthorized(consumer);
    }

    function revokeConsumer(address consumer) external onlyAdmin {
        require(authorizedConsumers[consumer], "Consumer is not authorized");
        authorizedConsumers[consumer] = false;
        emit ConsumerRevoked(consumer);
    }

    function getRegulatoryData(string calldata key) external view onlyAuthorizedConsumer returns (string memory) {
        return regulatoryData[key];
    }

    function updateAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        admin = newAdmin;
    }
}

