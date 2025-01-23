// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BusinessRegistration {
    struct Business {
        string name;
        string sector;
        string location;
        string sustainabilityGoals;
        address owner;
        bool isRegistered;
    }

    mapping(address => Business) public businesses;
    address public admin;

    event BusinessRegistered(
        address indexed owner,
        string name,
        string sector,
        string location,
        string sustainabilityGoals
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier notRegistered(address owner) {
        require(!businesses[owner].isRegistered, "Business already registered");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerBusiness(
        string memory _name,
        string memory _sector,
        string memory _location,
        string memory _sustainabilityGoals
    ) public notRegistered(msg.sender) {
        businesses[msg.sender] = Business({
            name: _name,
            sector: _sector,
            location: _location,
            sustainabilityGoals: _sustainabilityGoals,
            owner: msg.sender,
            isRegistered: true
        });

        emit BusinessRegistered(msg.sender, _name, _sector, _location, _sustainabilityGoals);
    }

    function getBusiness(address _owner) public view returns (Business memory) {
        require(businesses[_owner].isRegistered, "Business not found");
        return businesses[_owner];
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
}
