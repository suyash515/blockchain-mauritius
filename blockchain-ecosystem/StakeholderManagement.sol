// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakeholderManagement {
    // Enum to define the roles for stakeholders
    enum Role { 
        None, // Default role
        Government, 
        Regulator, 
        IndustryAssociation, 
        PrivateCompany, 
        EducationalInstitution, 
        InternationalPartner, 
        Investor, 
        Entrepreneur, 
        BlockchainProfessional 
    }

    // Struct to store stakeholder details
    struct Stakeholder {
        string name;
        Role role;
        bool isRegistered;
    }

    // Mapping to store stakeholders based on their address
    mapping(address => Stakeholder) private stakeholders;

    // Address of the contract owner
    address public owner;

    // Events
    event StakeholderRegistered(address indexed stakeholderAddress, string name, Role role);
    event RoleUpdated(address indexed stakeholderAddress, Role oldRole, Role newRole);
    event StakeholderRemoved(address indexed stakeholderAddress);

    // Modifier to restrict actions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Modifier to ensure a stakeholder is registered
    modifier onlyRegistered() {
        require(stakeholders[msg.sender].isRegistered, "You must be a registered stakeholder");
        _;
    }

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to register a stakeholder
    function registerStakeholder(address _stakeholderAddress, string calldata _name, Role _role) external onlyOwner {
        require(!stakeholders[_stakeholderAddress].isRegistered, "Stakeholder is already registered");
        require(_role != Role.None, "Invalid role");

        stakeholders[_stakeholderAddress] = Stakeholder({
            name: _name,
            role: _role,
            isRegistered: true
        });

        emit StakeholderRegistered(_stakeholderAddress, _name, _role);
    }

    // Function to update the role of a stakeholder
    function updateRole(address _stakeholderAddress, Role _newRole) external onlyOwner {
        require(stakeholders[_stakeholderAddress].isRegistered, "Stakeholder is not registered");
        require(_newRole != Role.None, "Invalid role");

        Role oldRole = stakeholders[_stakeholderAddress].role;
        stakeholders[_stakeholderAddress].role = _newRole;

        emit RoleUpdated(_stakeholderAddress, oldRole, _newRole);
    }

    // Function to remove a stakeholder
    function removeStakeholder(address _stakeholderAddress) external onlyOwner {
        require(stakeholders[_stakeholderAddress].isRegistered, "Stakeholder is not registered");

        delete stakeholders[_stakeholderAddress];

        emit StakeholderRemoved(_stakeholderAddress);
    }

    // Function to get stakeholder details
    function getStakeholder(address _stakeholderAddress) external view returns (string memory name, Role role, bool isRegistered) {
        Stakeholder memory stakeholder = stakeholders[_stakeholderAddress];
        return (stakeholder.name, stakeholder.role, stakeholder.isRegistered);
    }

    // Function to check the role of the caller
    function getMyRole() external view onlyRegistered returns (Role) {
        return stakeholders[msg.sender].role;
    }
}
