// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuthenticationContract {
    // Struct to store product details for authentication
    struct Product {
        uint256 id;                // Unique product ID
        string name;               // Product name
        string artisan;            // Artisan or manufacturer name
        string origin;             // Product origin (e.g., location, materials used)
        string details;            // Additional details about the product
        bool isAuthentic;          // Authenticity flag
    }

    // Mapping to store products by ID
    mapping(uint256 => Product) private products;

    // Event emitted when a product is registered for authentication
    event ProductRegistered(uint256 indexed id, string name, string artisan, string origin);

    // Event emitted when product authenticity is updated
    event ProductAuthenticityUpdated(uint256 indexed id, bool isAuthentic);

    // Modifier to check if a product exists
    modifier productExists(uint256 productId) {
        require(products[productId].id != 0, "Product does not exist");
        _;
    }

    // Function to register a product for authentication
    function registerProduct(
        uint256 productId,
        string memory name,
        string memory artisan,
        string memory origin,
        string memory details
    ) public {
        require(products[productId].id == 0, "Product already registered");

        products[productId] = Product({
            id: productId,
            name: name,
            artisan: artisan,
            origin: origin,
            details: details,
            isAuthentic: true
        });

        emit ProductRegistered(productId, name, artisan, origin);
    }

    // Function to verify a product's authenticity
    function verifyProduct(uint256 productId)
        public
        view
        productExists(productId)
        returns (
            string memory name,
            string memory artisan,
            string memory origin,
            string memory details,
            bool isAuthentic
        )
    {
        Product memory product = products[productId];
        return (product.name, product.artisan, product.origin, product.details, product.isAuthentic);
    }

    // Function to update a product's authenticity status
    function updateAuthenticity(uint256 productId, bool isAuthentic)
        public
        productExists(productId)
    {
        products[productId].isAuthentic = isAuthentic;
        emit ProductAuthenticityUpdated(productId, isAuthentic);
    }
}

