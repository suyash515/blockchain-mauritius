// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IntellectualPropertyAndLicensing {
    address public admin;

    struct IntellectualProperty {
        string name;
        string description;
        address owner;
        uint256 creationDate;
        uint256 licenseFee;
        bool isLicensed;
    }

    struct License {
        address licensee;
        uint256 licenseStartDate;
        uint256 licenseEndDate;
        bool isActive;
    }

    uint256 public ipCount;
    mapping(uint256 => IntellectualProperty) public intellectualProperties;
    mapping(uint256 => License[]) public licenses;

    event IntellectualPropertyRegistered(uint256 indexed ipId, string name, address indexed owner, uint256 licenseFee);
    event LicenseGranted(uint256 indexed ipId, address indexed licensee, uint256 licenseStartDate, uint256 licenseEndDate);
    event OwnershipTransferred(uint256 indexed ipId, address indexed oldOwner, address indexed newOwner);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier onlyOwner(uint256 ipId) {
        require(intellectualProperties[ipId].owner == msg.sender, "Only the owner can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerIntellectualProperty(
        string calldata name,
        string calldata description,
        uint256 licenseFee
    ) external {
        require(bytes(name).length > 0, "Name is required");
        require(licenseFee > 0, "License fee must be greater than zero");

        intellectualProperties[ipCount] = IntellectualProperty({
            name: name,
            description: description,
            owner: msg.sender,
            creationDate: block.timestamp,
            licenseFee: licenseFee,
            isLicensed: false
        });

        emit IntellectualPropertyRegistered(ipCount, name, msg.sender, licenseFee);
        ipCount++;
    }

    function grantLicense(
        uint256 ipId,
        address licensee,
        uint256 licenseDuration
    ) external payable onlyOwner(ipId) {
        require(licensee != address(0), "Invalid licensee address");
        require(licenseDuration > 0, "License duration must be greater than zero");
        require(msg.value >= intellectualProperties[ipId].licenseFee, "Insufficient license fee");

        intellectualProperties[ipId].isLicensed = true;

        licenses[ipId].push(License({
            licensee: licensee,
            licenseStartDate: block.timestamp,
            licenseEndDate: block.timestamp + licenseDuration,
            isActive: true
        }));

        payable(intellectualProperties[ipId].owner).transfer(msg.value);

        emit LicenseGranted(ipId, licensee, block.timestamp, block.timestamp + licenseDuration);
    }

    function transferOwnership(uint256 ipId, address newOwner) external onlyOwner(ipId) {
        require(newOwner != address(0), "Invalid new owner address");

        address oldOwner = intellectualProperties[ipId].owner;
        intellectualProperties[ipId].owner = newOwner;

        emit OwnershipTransferred(ipId, oldOwner, newOwner);
    }

    function getLicenses(uint256 ipId) external view returns (License[] memory) {
        return licenses[ipId];
    }

    function updateAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        admin = newAdmin;
    }
}

