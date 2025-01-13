// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProductCreationAndRegistration {

    struct Product {
        uint256 id;
        string name;
        string batchNumber;
        string origin;
        string productionDate;
        string certifications;
        address currentOwner;
        bool exists;
    }

    uint256 private productCounter;
    mapping(uint256 => Product) private products;
    event ProductRegistered(
        uint256 id,
        string name,
        string batchNumber,
        string origin,
        string productionDate,
        string certifications,
        address currentOwner
    );

    modifier onlyOwner(uint256 productId) {
        require(products[productId].currentOwner == msg.sender, "Not the owner of this product.");
        _;
    }

    constructor() {
        productCounter = 0;
    }

    function registerProduct(
        string memory name,
        string memory batchNumber,
        string memory origin,
        string memory productionDate,
        string memory certifications
    ) public returns (uint256) {
        productCounter++;
        products[productCounter] = Product({
            id: productCounter,
            name: name,
            batchNumber: batchNumber,
            origin: origin,
            productionDate: productionDate,
            certifications: certifications,
            currentOwner: msg.sender,
            exists: true
        });

        emit ProductRegistered(
            productCounter,
            name,
            batchNumber,
            origin,
            productionDate,
            certifications,
            msg.sender
        );

        return productCounter;
    }

    function transferOwnership(uint256 productId, address newOwner) public onlyOwner(productId) {
        require(products[productId].exists, "Product does not exist.");
        products[productId].currentOwner = newOwner;
    }

    function getProductDetails(uint256 productId) public view returns (
        uint256 id,
        string memory name,
        string memory batchNumber,
        string memory origin,
        string memory productionDate,
        string memory certifications,
        address currentOwner
    ) {
        require(products[productId].exists, "Product does not exist.");
        Product memory product = products[productId];
        return (
            product.id,
            product.name,
            product.batchNumber,
            product.origin,
            product.productionDate,
            product.certifications,
            product.currentOwner
        );
    }
}
