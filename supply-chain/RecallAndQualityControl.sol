// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RecallAndQualityControl {
    struct Product {
        uint256 id;
        string name;
        string batchNumber;
        address owner;
        bool isRecalled;
        string recallReason;
        bool exists;
    }

    mapping(uint256 => Product) private products;
    event ProductRegistered(uint256 productId, string name, string batchNumber, address owner);
    event ProductRecalled(uint256 productId, string reason, address initiator);
    event RecallResolved(uint256 productId, address resolver);

    modifier onlyOwner(uint256 productId) {
        require(products[productId].exists, "Product does not exist.");
        require(products[productId].owner == msg.sender, "Only the owner can perform this action.");
        _;
    }

    modifier productExists(uint256 productId) {
        require(products[productId].exists, "Product does not exist.");
        _;
    }

    function registerProduct(string memory name, string memory batchNumber) public returns (uint256) {
        uint256 productId = uint256(keccak256(abi.encodePacked(name, batchNumber, block.timestamp)));
        require(!products[productId].exists, "Product already registered.");

        products[productId] = Product({
            id: productId,
            name: name,
            batchNumber: batchNumber,
            owner: msg.sender,
            isRecalled: false,
            recallReason: "",
            exists: true
        });

        emit ProductRegistered(productId, name, batchNumber, msg.sender);
        return productId;
    }

    function recallProduct(uint256 productId, string memory reason) public onlyOwner(productId) {
        Product storage product = products[productId];
        require(!product.isRecalled, "Product is already recalled.");

        product.isRecalled = true;
        product.recallReason = reason;

        emit ProductRecalled(productId, reason, msg.sender);
    }

    function resolveRecall(uint256 productId) public onlyOwner(productId) {
        Product storage product = products[productId];
        require(product.isRecalled, "Product is not under recall.");

        product.isRecalled = false;
        product.recallReason = "";

        emit RecallResolved(productId, msg.sender);
    }

    function getProductDetails(uint256 productId) public view productExists(productId) returns (
        uint256 id,
        string memory name,
        string memory batchNumber,
        address owner,
        bool isRecalled,
        string memory recallReason
    ) {
        Product memory product = products[productId];
        return (
            product.id,
            product.name,
            product.batchNumber,
            product.owner,
            product.isRecalled,
            product.recallReason
        );
    }
}
