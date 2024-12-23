// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserIdentityManagement {
    // Events
    event IdentityCreated(address indexed user, string name, uint256 timestamp);
    event IdentityUpdated(address indexed user, string name, uint256 timestamp);
    event AccessGranted(address indexed user, address indexed requester, uint256 timestamp);
    event AccessRevoked(address indexed user, address indexed requester, uint256 timestamp);

    // Struct for user identity
    struct Identity {
        string name;
        string encryptedData; // Encrypted KYC or personal data
        bool exists;
    }

    // Mapping of user addresses to their identity details
    mapping(address => Identity) public identities;

    // Mapping for access control: user => (requester => hasAccess)
    mapping(address => mapping(address => bool)) public accessPermissions;

    // Modifier to ensure identity exists
    modifier identityExists(address user) {
        require(identities[user].exists, "Identity does not exist");
        _;
    }

    // Function to create a new identity
    function createIdentity(string calldata name, string calldata encryptedData) external {
        require(!identities[msg.sender].exists, "Identity already exists");
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(encryptedData).length > 0, "Encrypted data cannot be empty");

        identities[msg.sender] = Identity({
            name: name,
            encryptedData: encryptedData,
            exists: true
        });

        emit IdentityCreated(msg.sender, name, block.timestamp);
    }

    // Function to update an existing identity
    function updateIdentity(string calldata name, string calldata encryptedData) external identityExists(msg.sender) {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(encryptedData).length > 0, "Encrypted data cannot be empty");

        identities[msg.sender].name = name;
        identities[msg.sender].encryptedData = encryptedData;

        emit IdentityUpdated(msg.sender, name, block.timestamp);
    }

    // Function to grant access to a requester
    function grantAccess(address requester) external identityExists(msg.sender) {
        require(requester != address(0), "Invalid requester address");
        require(!accessPermissions[msg.sender][requester], "Access already granted");

        accessPermissions[msg.sender][requester] = true;

        emit AccessGranted(msg.sender, requester, block.timestamp);
    }

    // Function to revoke access from a requester
    function revokeAccess(address requester) external identityExists(msg.sender) {
        require(requester != address(0), "Invalid requester address");
        require(accessPermissions[msg.sender][requester], "Access not granted");

        accessPermissions[msg.sender][requester] = false;

        emit AccessRevoked(msg.sender, requester, block.timestamp);
    }

    // Function for a requester to view identity details
    function viewIdentity(address user) external view identityExists(user) returns (string memory name, string memory encryptedData) {
        require(accessPermissions[user][msg.sender], "Access not granted");

        Identity memory identity = identities[user];
        return (identity.name, identity.encryptedData);
    }
}
