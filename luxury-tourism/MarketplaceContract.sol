// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MarketplaceContract {
    // Struct to store product details
    struct Product {
        uint256 id;                 // Unique product ID
        string name;                // Name of the product
        address payable seller;     // Address of the product's seller
        uint256 price;              // Price of the product in wei
        bool isAvailable;           // Availability status of the product
    }

    // Mapping to store products by their ID
    mapping(uint256 => Product) private products;

    // Event emitted when a product is listed
    event ProductListed(uint256 indexed productId, string name, address indexed seller, uint256 price);

    // Event emitted when a product is purchased
    event ProductPurchased(
        uint256 indexed productId,
        string name,
        address indexed seller,
        address indexed buyer,
        uint256 price
    );

    // Modifier to check if a product exists
    modifier productExists(uint256 productId) {
        require(products[productId].id != 0, "Product does not exist");
        _;
    }

    // Modifier to check if the caller is the product's seller
    modifier onlySeller(uint256 productId) {
        require(products[productId].seller == msg.sender, "Caller is not the product's seller");
        _;
    }

    // Function to list a product on the marketplace
    function listProduct(uint256 productId, string memory name, uint256 price) public {
        require(products[productId].id == 0, "Product is already listed");
        require(price > 0, "Price must be greater than zero");

        products[productId] = Product({
            id: productId,
            name: name,
            seller: payable(msg.sender),
            price: price,
            isAvailable: true
        });

        emit ProductListed(productId, name, msg.sender, price);
    }

    // Function to purchase a product
    function purchaseProduct(uint256 productId) public payable productExists(productId) {
        Product storage product = products[productId];
        require(product.isAvailable, "Product is no longer available");
        require(msg.value == product.price, "Incorrect payment amount");

        // Transfer payment to the seller
        product.seller.transfer(msg.value);

        // Mark the product as no longer available
        product.isAvailable = false;

        emit ProductPurchased(productId, product.name, product.seller, msg.sender, product.price);
    }

    // Function to get product details
    function getProduct(uint256 productId)
        public
        view
        productExists(productId)
        returns (string memory name, address seller, uint256 price, bool isAvailable)
    {
        Product memory product = products[productId];
        return (product.name, product.seller, product.price, product.isAvailable);
    }

    // Function to remove a listed product (only the seller can remove)
    function removeProduct(uint256 productId) public productExists(productId) onlySeller(productId) {
        delete products[productId];
    }
}

