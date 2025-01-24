// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataPrivacyAndProtection {
    address public admin;

    struct UserData {
        string encryptedData;
        bool consentGiven;
    }

    mapping(address => UserData) private userRecords;
    mapping(address => bool) public authorizedProcessors;

    event DataStored(address indexed user, string encryptedData);
    event ConsentUpdated(address indexed user, bool consentGiven);
    event DataDeleted(address indexed user);
    event ProcessorAuthorized(address indexed processor);
    event ProcessorRevoked(address indexed processor);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier onlyAuthorizedProcessor() {
        require(authorizedProcessors[msg.sender], "Only authorized processors can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function storeData(string calldata encryptedData) external {
        userRecords[msg.sender] = UserData({
            encryptedData: encryptedData,
            consentGiven: true
        });

        emit DataStored(msg.sender, encryptedData);
    }

    function updateConsent(bool consent) external {
        require(bytes(userRecords[msg.sender].encryptedData).length > 0, "No data found for the user");
        userRecords[msg.sender].consentGiven = consent;

        emit ConsentUpdated(msg.sender, consent);
    }

    function deleteData() external {
        require(bytes(userRecords[msg.sender].encryptedData).length > 0, "No data found for the user");

        delete userRecords[msg.sender];
        emit DataDeleted(msg.sender);
    }

    function getUserData(address user) external view onlyAuthorizedProcessor returns (string memory, bool) {
        require(bytes(userRecords[user].encryptedData).length > 0, "No data found for the user");
        return (userRecords[user].encryptedData, userRecords[user].consentGiven);
    }

    function authorizeProcessor(address processor) external onlyAdmin {
        require(processor != address(0), "Invalid processor address");
        authorizedProcessors[processor] = true;

        emit ProcessorAuthorized(processor);
    }

    function revokeProcessor(address processor) external onlyAdmin {
        require(authorizedProcessors[processor], "Processor is not authorized");
        authorizedProcessors[processor] = false;

        emit ProcessorRevoked(processor);
    }

    function updateAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        admin = newAdmin;
    }
}

