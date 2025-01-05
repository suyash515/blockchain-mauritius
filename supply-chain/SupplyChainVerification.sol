// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChainVerification {
    struct SupplyChainEvent {
        uint256 timestamp;
        string location;
        string description;
        address actor;
    }

    struct Product {
        uint256 id;
        string name;
        string batchNumber;
        address currentOwner;
        bool exists;
        SupplyChainEvent[] events;
    }

    uint256 private productCounter;
    mapping(uint256 => Product) private products;
    event ProductRegistered(uint256 productId, string name, string batchNumber, address owner);
    event SupplyChainEventAdded(uint256 productId, string location, string description, address actor);

    modifier onlyOwner(uint256 productId) {
        require(products[productId].exists, "Product does not exist.");
        require(products[productId].currentOwner == msg.sender, "Not the owner of this product.");
        _;
    }

    function registerProduct(string memory name, string memory batchNumber) public returns (uint256) {
        productCounter++;
        products[productCounter] = Product({
            id: productCounter,
            name: name,
            batchNumber: batchNumber,
            currentOwner: msg.sender,
            exists: true,
            events: new SupplyChainEvent     });

        emit ProductRegistered(productCounter, name, batchNumber, msg.sender);
        return productCounter;
    }

    function addSupplyChainEvent(
        uint256 productId,
        string memory location,
        string memory description
    ) public onlyOwner(productId) {
        require(products[productId].exists, "Product does not exist.");

        products[productId].events.push(SupplyChainEvent({
            timestamp: block.timestamp,
            location: location,
            description: description,
            actor: msg.sender
        }));

        emit SupplyChainEventAdded(productId, location, description, msg.sender);
    }

    function transferOwnership(uint256 productId, address newOwner) public onlyOwner(productId) {
        require(products[productId].exists, "Product does not exist.");
        products[productId].currentOwner = newOwner;
    }

    function getProductDetails(uint256 productId) public view returns (
        uint256 id,
        string memory name,
        string memory batchNumber,
        address currentOwner
    ) {
        require(products[productId].exists, "Product does not exist.");
        Product memory product = products[productId];
        return (product.id, product.name, product.batchNumber, product.currentOwner);
    }

    function getSupplyChainEvents(uint256 productId) public view returns (SupplyChainEvent[] memory) {
        require(products[productId].exists, "Product does not exist.");
        return products[productId].events;
    }
}
