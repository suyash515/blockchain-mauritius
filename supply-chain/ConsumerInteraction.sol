// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ConsumerInteraction {
    struct Product {
        uint256 id;
        string name;
        string batchNumber;
        string origin;
        string productionDate;
        string certifications;
        string description;
        bool exists;
    }

    mapping(uint256 => Product) private products;
    mapping(uint256 => uint256) private scanCounts;
    mapping(address => bool) private registeredConsumers;

    event ProductScanned(uint256 productId, address consumer);
    event ConsumerRegistered(address consumer);

    modifier productExists(uint256 productId) {
        require(products[productId].exists, "Product does not exist.");
        _;
    }

    function registerConsumer() public {
        require(!registeredConsumers[msg.sender], "Consumer already registered.");
        registeredConsumers[msg.sender] = true;
        emit ConsumerRegistered(msg.sender);
    }

    function isConsumerRegistered(address consumer) public view returns (bool) {
        return registeredConsumers[consumer];
    }

    function addProduct(
        uint256 productId,
        string memory name,
        string memory batchNumber,
        string memory origin,
        string memory productionDate,
        string memory certifications,
        string memory description
    ) public {
        require(!products[productId].exists, "Product already exists.");
        products[productId] = Product({
            id: productId,
            name: name,
            batchNumber: batchNumber,
            origin: origin,
            productionDate: productionDate,
            certifications: certifications,
            description: description,
            exists: true
        });
    }

    function scanProduct(uint256 productId) public productExists(productId) {
        require(registeredConsumers[msg.sender], "Consumer not registered.");
        scanCounts[productId]++;
        emit ProductScanned(productId, msg.sender);
    }

    function getProductDetails(uint256 productId) public view productExists(productId) returns (
        uint256 id,
        string memory name,
        string memory batchNumber,
        string memory origin,
        string memory productionDate,
        string memory certifications,
        string memory description,
        uint256 scanCount
    ) {
        Product memory product = products[productId];
        return (
            product.id,
            product.name,
            product.batchNumber,
            product.origin,
            product.productionDate,
            product.certifications,
            product.description,
            scanCounts[productId]
        );
    }
}
