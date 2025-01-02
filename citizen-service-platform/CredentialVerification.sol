// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CredentialVerification {
    struct Credential {
        string credentialHash;
        string institutionName;
        string recipientName;
        uint256 issueDate;
        bool isRevoked;
    }

    mapping(address => mapping(string => Credential)) private credentials; // Address to credential ID to Credential
    mapping(address => string[]) private issuedCredentials; // Address to list of credential IDs

    event CredentialIssued(address indexed recipient, string credentialId, string institutionName, uint256 issueDate);
    event CredentialRevoked(address indexed recipient, string credentialId, uint256 revokeDate);

    modifier onlyIssuer(address _issuer, string memory _credentialId) {
        require(
            keccak256(abi.encodePacked(credentials[_issuer][_credentialId].institutionName)) != keccak256(abi.encodePacked("")),
            "Not authorized to revoke"
        );
        _;
    }

    // Issue a new credential
    function issueCredential(
        address _recipient,
        string memory _credentialId,
        string memory _credentialHash,
        string memory _institutionName,
        string memory _recipientName
    ) public {
        require(bytes(credentials[msg.sender][_credentialId].credentialHash).length == 0, "Credential already exists");

        credentials[msg.sender][_credentialId] = Credential({
            credentialHash: _credentialHash,
            institutionName: _institutionName,
            recipientName: _recipientName,
            issueDate: block.timestamp,
            isRevoked: false
        });

        issuedCredentials[msg.sender].push(_credentialId);

        emit CredentialIssued(_recipient, _credentialId, _institutionName, block.timestamp);
    }

    // Revoke a credential
    function revokeCredential(address _recipient, string memory _credentialId) public onlyIssuer(msg.sender, _credentialId) {
        require(!credentials[msg.sender][_credentialId].isRevoked, "Credential already revoked");

        credentials[msg.sender][_credentialId].isRevoked = true;

        emit CredentialRevoked(_recipient, _credentialId, block.timestamp);
    }

    // Verify a credential
    function verifyCredential(
        address _issuer,
        string memory _credentialId,
        string memory _credentialHash
    ) public view returns (bool isValid, string memory institutionName, string memory recipientName, uint256 issueDate) {
        Credential memory credential = credentials[_issuer][_credentialId];
        require(bytes(credential.credentialHash).length > 0, "Credential does not exist");
        require(!credential.isRevoked, "Credential has been revoked");

        bool hashMatches = keccak256(abi.encodePacked(credential.credentialHash)) == keccak256(abi.encodePacked(_credentialHash));

        return (hashMatches, credential.institutionName, credential.recipientName, credential.issueDate);
    }

    // Get all credentials issued by an institution
    function getIssuedCredentials(address _issuer) public view returns (string[] memory) {
        return issuedCredentials[_issuer];
    }
}
