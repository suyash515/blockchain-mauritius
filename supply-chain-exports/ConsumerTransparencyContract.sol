// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ConsumerTransparencyContract {
    struct Product {
        string productId;
        string productName;
        string origin;
        string productionDate;
        string expiryDate;
        string certifications; // e.g., "Organic, Fair Trade"
        string additionalInfo; // e.g., "Nutritional value, farming methods"
        string status; // e.g., "Available", "Sold", "Recalled"
    }

    mapping(string => Product) private products;
    address public owner;

    event ProductRegistered(
        string productId,
        string productName,
        string origin,
        string productionDate,
        string expiryDate,
        string certifications,
        string additionalInfo
    );

    event ProductStatusUpdated(string productId, string status);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerProduct(
        string memory _productId,
        string memory _productName,
        string memory _origin,
        string memory _productionDate,
        string memory _expiryDate,
        string memory _certifications,
        string memory _additionalInfo
    ) public onlyOwner {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(_productName).length > 0, "Product name cannot be empty.");
        require(bytes(_origin).length > 0, "Origin cannot be empty.");
        require(bytes(_productionDate).length > 0, "Production date cannot be empty.");
        require(bytes(_expiryDate).length > 0, "Expiry date cannot be empty.");
        require(bytes(products[_productId].productId).length == 0, "Product ID already exists.");

        products[_productId] = Product(
            _productId,
            _productName,
            _origin,
            _productionDate,
            _expiryDate,
            _certifications,
            _additionalInfo,
            "Available"
        );

        emit ProductRegistered(
            _productId,
            _productName,
            _origin,
            _productionDate,
            _expiryDate,
            _certifications,
            _additionalInfo
        );
    }

    function updateProductStatus(string memory _productId, string memory _status) public onlyOwner {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(products[_productId].productId).length > 0, "Product not found.");
        require(
            keccak256(bytes(_status)) == keccak256(bytes("Available")) ||
            keccak256(bytes(_status)) == keccak256(bytes("Sold")) ||
            keccak256(bytes(_status)) == keccak256(bytes("Recalled")),
            "Invalid status value."
        );

        products[_productId].status = _status;

        emit ProductStatusUpdated(_productId, _status);
    }

    function getProductDetails(string memory _productId)
        public
        view
        returns (
            string memory productName,
            string memory origin,
            string memory productionDate,
            string memory expiryDate,
            string memory certifications,
            string memory additionalInfo,
            string memory status
        )
    {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(products[_productId].productId).length > 0, "Product not found.");

        Product memory product = products[_productId];
        return (
            product.productName,
            product.origin,
            product.productionDate,
            product.expiryDate,
            product.certifications,
            product.additionalInfo,
            product.status
        );
    }
}

