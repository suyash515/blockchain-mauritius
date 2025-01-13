// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TraceabilityContract {
    struct Product {
        string productId;
        string origin;
        string farmer;
        string harvestDate;
        string farmingMethod;
        bool isCertifiedSustainable;
        string currentLocation;
    }

    mapping(string => Product) private products;
    address public owner;

    event ProductRegistered(
        string productId,
        string origin,
        string farmer,
        string harvestDate,
        string farmingMethod,
        bool isCertifiedSustainable
    );

    event LocationUpdated(string productId, string newLocation);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerProduct(
        string memory _productId,
        string memory _origin,
        string memory _farmer,
        string memory _harvestDate,
        string memory _farmingMethod,
        bool _isCertifiedSustainable
    ) public onlyOwner {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(products[_productId].productId).length == 0, "Product ID already exists.");

        products[_productId] = Product(
            _productId,
            _origin,
            _farmer,
            _harvestDate,
            _farmingMethod,
            _isCertifiedSustainable,
            _origin
        );

        emit ProductRegistered(
            _productId,
            _origin,
            _farmer,
            _harvestDate,
            _farmingMethod,
            _isCertifiedSustainable
        );
    }

    function updateLocation(string memory _productId, string memory _newLocation) public onlyOwner {
        require(bytes(products[_productId].productId).length > 0, "Product not registered.");
        require(bytes(_newLocation).length > 0, "New location cannot be empty.");

        products[_productId].currentLocation = _newLocation;

        emit LocationUpdated(_productId, _newLocation);
    }

    function getProduct(string memory _productId)
        public
        view
        returns (
            string memory origin,
            string memory farmer,
            string memory harvestDate,
            string memory farmingMethod,
            bool isCertifiedSustainable,
            string memory currentLocation
        )
    {
        require(bytes(products[_productId].productId).length > 0, "Product not registered.");

        Product memory product = products[_productId];
        return (
            product.origin,
            product.farmer,
            product.harvestDate,
            product.farmingMethod,
            product.isCertifiedSustainable,
            product.currentLocation
        );
    }
}
