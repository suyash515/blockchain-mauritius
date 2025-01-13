// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ComplianceAndCertification {
    struct Certification {
        string certName;
        string issuingAuthority;
        string issueDate;
        string expiryDate;
        bool isValid;
    }

    struct Product {
        uint256 id;
        string name;
        string batchNumber;
        address owner;
        Certification[] certifications;
        bool exists;
    }

    uint256 private productCounter;
    mapping(uint256 => Product) private products;

    event ProductRegistered(uint256 productId, string name, string batchNumber, address owner);
    event CertificationAdded(uint256 productId, string certName, string issuingAuthority);
    event CertificationRevoked(uint256 productId, string certName);

    modifier onlyOwner(uint256 productId) {
        require(products[productId].exists, "Product does not exist.");
        require(products[productId].owner == msg.sender, "Not the owner of this product.");
        _;
    }

    function registerProduct(string memory name, string memory batchNumber) public returns (uint256) {
        productCounter++;
        products[productCounter] = Product({
            id: productCounter,
            name: name,
            batchNumber: batchNumber,
            owner: msg.sender,
            certifications: new Certification          exists: true
        });

        emit ProductRegistered(productCounter, name, batchNumber, msg.sender);
        return productCounter;
    }

    function addCertification(
        uint256 productId,
        string memory certName,
        string memory issuingAuthority,
        string memory issueDate,
        string memory expiryDate
    ) public onlyOwner(productId) {
        require(products[productId].exists, "Product does not exist.");
        products[productId].certifications.push(Certification({
            certName: certName,
            issuingAuthority: issuingAuthority,
            issueDate: issueDate,
            expiryDate: expiryDate,
            isValid: true
        }));

        emit CertificationAdded(productId, certName, issuingAuthority);
    }

    function revokeCertification(uint256 productId, string memory certName) public onlyOwner(productId) {
        require(products[productId].exists, "Product does not exist.");
        Certification[] storage certs = products[productId].certifications;

        for (uint256 i = 0; i < certs.length; i++) {
            if (keccak256(abi.encodePacked(certs[i].certName)) == keccak256(abi.encodePacked(certName))) {
                certs[i].isValid = false;
                emit CertificationRevoked(productId, certName);
                return;
            }
        }

        revert("Certification not found.");
    }

    function getProductCertifications(uint256 productId) public view returns (Certification[] memory) {
        require(products[productId].exists, "Product does not exist.");
        return products[productId].certifications;
    }

    function isCertificationValid(uint256 productId, string memory certName) public view returns (bool) {
        require(products[productId].exists, "Product does not exist.");
        Certification[] memory certs = products[productId].certifications;

        for (uint256 i = 0; i < certs.length; i++) {
            if (keccak256(abi.encodePacked(certs[i].certName)) == keccak256(abi.encodePacked(certName))) {
                return certs[i].isValid;
            }
        }

        return false;
    }
}
