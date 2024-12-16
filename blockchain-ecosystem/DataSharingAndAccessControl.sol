// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataSharingAndAccessControl {
    // Struct to represent shared data
    struct DataRecord {
        uint256 id;
        address owner;
        string dataHash; // Hash of the data stored off-chain (e.g., IPFS)
        string description;
        address[] authorizedUsers;
        bool isPublic;
        uint256 timestamp;
    }

    // Mapping to store data records by ID
    mapping(uint256 => DataRecord) public dataRecords;

    // Counter to generate unique data record IDs
    uint256 private dataIdCounter;

    // Events
    event DataShared(uint256 indexed id, address indexed owner, string description, bool isPublic);
    event AccessGranted(uint256 indexed id, address indexed user);
    event AccessRevoked(uint256 indexed id, address indexed user);

    // Modifier to check if a data record exists
    modifier dataExists(uint256 _dataId) {
        require(dataRecords[_dataId].owner != address(0), "Data record does not exist");
        _;
    }

    // Modifier to ensure only the owner can perform certain actions
    modifier onlyOwner(uint256 _dataId) {
        require(msg.sender == dataRecords[_dataId].owner, "Only the owner can perform this action");
        _;
    }

    // Function to share data
    function shareData(string calldata _dataHash, string calldata _description, bool _isPublic) external returns (uint256) {
        require(bytes(_dataHash).length > 0, "Data hash cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");

        uint256 newId = ++dataIdCounter;

        dataRecords[newId] = DataRecord({
            id: newId,
            owner: msg.sender,
            dataHash: _dataHash,
            description: _description,
            authorizedUsers: new address          isPublic: _isPublic,
            timestamp: block.timestamp
        });

        emit DataShared(newId, msg.sender, _description, _isPublic);
        return newId;
    }

    // Function to grant access to a user
    function grantAccess(uint256 _dataId, address _user) external dataExists(_dataId) onlyOwner(_dataId) {
        require(_user != address(0), "User address cannot be zero");

        DataRecord storage record = dataRecords[_dataId];
        record.authorizedUsers.push(_user);

        emit AccessGranted(_dataId, _user);
    }

    // Function to revoke access from a user
    function revokeAccess(uint256 _dataId, address _user) external dataExists(_dataId) onlyOwner(_dataId) {
        DataRecord storage record = dataRecords[_dataId];
        bool found = false;

        for (uint256 i = 0; i < record.authorizedUsers.length; i++) {
            if (record.authorizedUsers[i] == _user) {
                record.authorizedUsers[i] = record.authorizedUsers[record.authorizedUsers.length - 1];
                record.authorizedUsers.pop();
                found = true;
                break;
            }
        }

        require(found, "User not authorized for this data record");
        emit AccessRevoked(_dataId, _user);
    }

    // Function to retrieve data record details
    function getDataRecord(uint256 _dataId) external view dataExists(_dataId) returns (
        address owner,
        string memory dataHash,
        string memory description,
        address[] memory authorizedUsers,
        bool isPublic,
        uint256 timestamp
    ) {
        DataRecord memory record = dataRecords[_dataId];
        return (
            record.owner,
            record.dataHash,
            record.description,
            record.authorizedUsers,
            record.isPublic,
            record.timestamp
        );
    }

    // Function to check if a user has access to a specific data record
    function hasAccess(uint256 _dataId, address _user) external view dataExists(_dataId) returns (bool) {
        DataRecord memory record = dataRecords[_dataId];

        if (record.isPublic || record.owner == _user) {
            return true;
        }

        for (uint256 i = 0; i < record.authorizedUsers.length; i++) {
            if (record.authorizedUsers[i] == _user) {
                return true;
            }
        }

        return false;
    }
}
