// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PackagingAuthenticityContract {
    struct Package {
        string packageId;
        string productId;
        string packagingDate;
        string packedBy;
        string authenticityCode; // Unique code linked to blockchain data
        bool isVerified;
    }

    mapping(string => Package) private packages;
    address public owner;

    event PackageCreated(
        string packageId,
        string productId,
        string packagingDate,
        string packedBy,
        string authenticityCode
    );

    event PackageVerified(string packageId, string productId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createPackage(
        string memory _packageId,
        string memory _productId,
        string memory _packagingDate,
        string memory _packedBy,
        string memory _authenticityCode
    ) public onlyOwner {
        require(bytes(_packageId).length > 0, "Package ID cannot be empty.");
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(_packagingDate).length > 0, "Packaging date cannot be empty.");
        require(bytes(_packedBy).length > 0, "Packed by cannot be empty.");
        require(bytes(_authenticityCode).length > 0, "Authenticity code cannot be empty.");
        require(
            bytes(packages[_packageId].packageId).length == 0,
            "Package ID already exists."
        );

        packages[_packageId] = Package(
            _packageId,
            _productId,
            _packagingDate,
            _packedBy,
            _authenticityCode,
            false
        );

        emit PackageCreated(
            _packageId,
            _productId,
            _packagingDate,
            _packedBy,
            _authenticityCode
        );
    }

    function verifyPackage(string memory _packageId) public onlyOwner {
        require(bytes(_packageId).length > 0, "Package ID cannot be empty.");
        require(
            bytes(packages[_packageId].packageId).length > 0,
            "Package not found."
        );

        packages[_packageId].isVerified = true;

        emit PackageVerified(_packageId, packages[_packageId].productId);
    }

    function getPackageDetails(string memory _packageId)
        public
        view
        returns (
            string memory productId,
            string memory packagingDate,
            string memory packedBy,
            string memory authenticityCode,
            bool isVerified
        )
    {
        require(bytes(_packageId).length > 0, "Package ID cannot be empty.");
        require(
            bytes(packages[_packageId].packageId).length > 0,
            "Package not found."
        );

        Package memory pkg = packages[_packageId];
        return (
            pkg.productId,
            pkg.packagingDate,
            pkg.packedBy,
            pkg.authenticityCode,
            pkg.isVerified
        );
    }
}

