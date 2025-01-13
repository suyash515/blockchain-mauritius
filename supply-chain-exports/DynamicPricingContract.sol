// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DynamicPricingContract {
    struct Product {
        string productId;
        string productName;
        uint256 basePrice;
        uint256 currentPrice;
        uint256 lastUpdated; // Timestamp of the last price update
        bool isActive;
    }

    mapping(string => Product) private products;
    address public owner;

    event ProductAdded(string productId, string productName, uint256 basePrice);
    event PriceUpdated(string productId, uint256 oldPrice, uint256 newPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addProduct(
        string memory _productId,
        string memory _productName,
        uint256 _basePrice
    ) public onlyOwner {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(_productName).length > 0, "Product name cannot be empty.");
        require(_basePrice > 0, "Base price must be greater than zero.");
        require(!products[_productId].isActive, "Product ID already exists.");

        products[_productId] = Product(
            _productId,
            _productName,
            _basePrice,
            _basePrice,
            block.timestamp,
            true
        );

        emit ProductAdded(_productId, _productName, _basePrice);
    }

    function updatePrice(string memory _productId, uint256 _newPrice) public onlyOwner {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(products[_productId].isActive, "Product not found or inactive.");
        require(_newPrice > 0, "New price must be greater than zero.");

        uint256 oldPrice = products[_productId].currentPrice;
        products[_productId].currentPrice = _newPrice;
        products[_productId].lastUpdated = block.timestamp;

        emit PriceUpdated(_productId, oldPrice, _newPrice);
    }

    function getProductDetails(string memory _productId)
        public
        view
        returns (
            string memory productName,
            uint256 basePrice,
            uint256 currentPrice,
            uint256 lastUpdated,
            bool isActive
        )
    {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(products[_productId].isActive, "Product not found or inactive.");

        Product memory product = products[_productId];
        return (
            product.productName,
            product.basePrice,
            product.currentPrice,
            product.lastUpdated,
            product.isActive
        );
    }

    function calculateDynamicPrice(
        string memory _productId,
        uint256 _demandFactor,
        uint256 _supplyFactor
    ) public onlyOwner returns (uint256) {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(products[_productId].isActive, "Product not found or inactive.");
        require(_demandFactor > 0 && _supplyFactor > 0, "Factors must be greater than zero.");

        Product storage product = products[_productId];
        uint256 dynamicPrice = (product.basePrice * _demandFactor) / _supplyFactor;

        updatePrice(_productId, dynamicPrice);

        return dynamicPrice;
    }
}

