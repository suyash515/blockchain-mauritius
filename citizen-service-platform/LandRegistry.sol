// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LandRegistry {
    struct Property {
        uint256 id;
        string location;
        uint256 area; // in square meters
        address owner;
        bool exists;
    }

    uint256 private propertyCounter;
    mapping(uint256 => Property) private properties;
    mapping(uint256 => address[]) private ownershipHistory;

    event PropertyRegistered(uint256 indexed propertyId, string location, uint256 area, address indexed owner);
    event OwnershipTransferred(uint256 indexed propertyId, address indexed oldOwner, address indexed newOwner);

    modifier onlyOwner(uint256 _propertyId) {
        require(properties[_propertyId].exists, "Property does not exist");
        require(msg.sender == properties[_propertyId].owner, "Not the property owner");
        _;
    }

    // Register a new property
    function registerProperty(string memory _location, uint256 _area) public {
        propertyCounter++;
        uint256 propertyId = propertyCounter;

        properties[propertyId] = Property({
            id: propertyId,
            location: _location,
            area: _area,
            owner: msg.sender,
            exists: true
        });

        ownershipHistory[propertyId].push(msg.sender);

        emit PropertyRegistered(propertyId, _location, _area, msg.sender);
    }

    // Transfer property ownership
    function transferOwnership(uint256 _propertyId, address _newOwner) public onlyOwner(_propertyId) {
        require(_newOwner != address(0), "Invalid new owner address");

        address oldOwner = properties[_propertyId].owner;
        properties[_propertyId].owner = _newOwner;

        ownershipHistory[_propertyId].push(_newOwner);

        emit OwnershipTransferred(_propertyId, oldOwner, _newOwner);
    }

    // View property details
    function viewProperty(uint256 _propertyId) public view returns (
        uint256 id,
        string memory location,
        uint256 area,
        address owner
    ) {
        require(properties[_propertyId].exists, "Property does not exist");

        Property memory property = properties[_propertyId];
        return (property.id, property.location, property.area, property.owner);
    }

    // Get ownership history
    function getOwnershipHistory(uint256 _propertyId) public view returns (address[] memory) {
        require(properties[_propertyId].exists, "Property does not exist");
        return ownershipHistory[_propertyId];
    }
}
