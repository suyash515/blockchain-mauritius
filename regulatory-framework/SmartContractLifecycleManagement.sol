// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartContractLifecycleManagement {
    address public admin;

    enum ContractStatus { Active, Deprecated, Archived }

    struct ContractInfo {
        address contractAddress;
        string description;
        ContractStatus status;
        uint256 deployedAt;
        uint256 updatedAt;
    }

    mapping(address => ContractInfo) public managedContracts;
    address[] public allContracts;

    event ContractAdded(address indexed contractAddress, string description, uint256 deployedAt);
    event ContractStatusUpdated(address indexed contractAddress, ContractStatus newStatus, uint256 updatedAt);
    event ContractDescriptionUpdated(address indexed contractAddress, string newDescription, uint256 updatedAt);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function addContract(address contractAddress, string calldata description) external onlyAdmin {
        require(contractAddress != address(0), "Invalid contract address");
        require(managedContracts[contractAddress].contractAddress == address(0), "Contract is already managed");

        managedContracts[contractAddress] = ContractInfo({
            contractAddress: contractAddress,
            description: description,
            status: ContractStatus.Active,
            deployedAt: block.timestamp,
            updatedAt: block.timestamp
        });

        allContracts.push(contractAddress);

        emit ContractAdded(contractAddress, description, block.timestamp);
    }

    function updateContractStatus(address contractAddress, ContractStatus newStatus) external onlyAdmin {
        require(managedContracts[contractAddress].contractAddress != address(0), "Contract is not managed");

        managedContracts[contractAddress].status = newStatus;
        managedContracts[contractAddress].updatedAt = block.timestamp;

        emit ContractStatusUpdated(contractAddress, newStatus, block.timestamp);
    }

    function updateContractDescription(address contractAddress, string calldata newDescription) external onlyAdmin {
        require(managedContracts[contractAddress].contractAddress != address(0), "Contract is not managed");

        managedContracts[contractAddress].description = newDescription;
        managedContracts[contractAddress].updatedAt = block.timestamp;

        emit ContractDescriptionUpdated(contractAddress, newDescription, block.timestamp);
    }

    function getAllManagedContracts() external view returns (address[] memory) {
        return allContracts;
    }

    function getContractInfo(address contractAddress) external view returns (ContractInfo memory) {
        require(managedContracts[contractAddress].contractAddress != address(0), "Contract is not managed");
        return managedContracts[contractAddress];
    }

    function updateAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        admin = newAdmin;
    }
}

