// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DigitalIdentity {
    struct Identity {
        string fullName;
        string dateOfBirth;
        string nationalID;
        string email;
        bool exists;
    }

    mapping(address => Identity) private identities;
    mapping(address => mapping(address => bool)) private accessPermissions;

    event IdentityCreated(address indexed user, string fullName, string dateOfBirth, string nationalID);
    event AccessGranted(address indexed user, address indexed authorizedParty);
    event AccessRevoked(address indexed user, address indexed authorizedParty);

    modifier onlyOwner(address user) {
        require(msg.sender == user, "Not authorized");
        _;
    }

    // Create a new digital identity
    function createIdentity(
        string memory _fullName,
        string memory _dateOfBirth,
        string memory _nationalID,
        string memory _email
    ) public {
        require(!identities[msg.sender].exists, "Identity already exists");

        identities[msg.sender] = Identity({
            fullName: _fullName,
            dateOfBirth: _dateOfBirth,
            nationalID: _nationalID,
            email: _email,
            exists: true
        });

        emit IdentityCreated(msg.sender, _fullName, _dateOfBirth, _nationalID);
    }

    // Grant access to another address
    function grantAccess(address _authorizedParty) public onlyOwner(msg.sender) {
        require(identities[msg.sender].exists, "Identity does not exist");
        accessPermissions[msg.sender][_authorizedParty] = true;

        emit AccessGranted(msg.sender, _authorizedParty);
    }

    // Revoke access from another address
    function revokeAccess(address _authorizedParty) public onlyOwner(msg.sender) {
        require(accessPermissions[msg.sender][_authorizedParty], "Access not granted");
        accessPermissions[msg.sender][_authorizedParty] = false;

        emit AccessRevoked(msg.sender, _authorizedParty);
    }

    // View identity details
    function viewIdentity(address _user) public view returns (
        string memory fullName,
        string memory dateOfBirth,
        string memory nationalID,
        string memory email
    ) {
        require(
            msg.sender == _user || accessPermissions[_user][msg.sender],
            "Access denied"
        );
        Identity memory identity = identities[_user];
        require(identity.exists, "Identity does not exist");

        return (identity.fullName, identity.dateOfBirth, identity.nationalID, identity.email);
    }
}
