// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SustainabilityMetrics {
    struct Metric {
        string metricName;
        string description;
        uint256 value;
        string unit;
        uint256 timestamp;
    }

    struct Product {
        uint256 id;
        string name;
        string batchNumber;
        address owner;
        Metric[] metrics;
        bool exists;
    }

    uint256 private productCounter;
    mapping(uint256 => Product) private products;

    event ProductRegistered(uint256 productId, string name, string batchNumber, address owner);
    event MetricAdded(uint256 productId, string metricName, uint256 value, string unit, uint256 timestamp);

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
        productCounter++;
        products[productCounter] = Product({
            id: productCounter,
            name: name,
            batchNumber: batchNumber,
            owner: msg.sender,
            metrics: new Metric          exists: true
        });

        emit ProductRegistered(productCounter, name, batchNumber, msg.sender);
        return productCounter;
    }

    function addSustainabilityMetric(
        uint256 productId,
        string memory metricName,
        string memory description,
        uint256 value,
        string memory unit
    ) public onlyOwner(productId) {
        require(products[productId].exists, "Product does not exist.");
        Metric memory newMetric = Metric({
            metricName: metricName,
            description: description,
            value: value,
            unit: unit,
            timestamp: block.timestamp
        });

        products[productId].metrics.push(newMetric);

        emit MetricAdded(productId, metricName, value, unit, block.timestamp);
    }

    function getProductMetrics(uint256 productId) public view productExists(productId) returns (Metric[] memory) {
        return products[productId].metrics;
    }

    function getProductDetails(uint256 productId) public view productExists(productId) returns (
        uint256 id,
        string memory name,
        string memory batchNumber,
        address owner
    ) {
        Product memory product = products[productId];
        return (product.id, product.name, product.batchNumber, product.owner);
    }
}
