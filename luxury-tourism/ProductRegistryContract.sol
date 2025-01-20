// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProductRegistryContract {
    // Struct to store product details
    struct Product {
        uint256 id;                // Unique product ID
        string name;               // Product name
        string artisan;            // Artisan or manufacturer name
        string origin;             // Product origin (e.g., location, materials used)
        string details;            // Additional details about the product
        address owner;             // Current owner of the product
        uint256 timestamp;         // Registration timestamp
        bool isAuthentic;          // Authenticity flag
    }

    // Mapping to store products by ID
    mapping(uint256 => Product) private products;

    // Event emitted when a new product is registered
    event ProductRegistered(
        uint256 indexed id,
        string name,
        string artisan,
        address indexed owner,
        uint256 timestamp
    );

    // Event emitted when product ownership is transferred
    event OwnershipTransferred(
        uint256 indexed id,
        address indexed previousOwner,
        address indexed newOwner
    );

    // Modifier to check if a product exists
    modifier productExists(uint256 _id) {
        require(products[_id].id != 0, "Product does not exist");
        _;
    }

    // Modifier to check if the caller is the product's current owner
    modifier onlyOwner(uint256 _id) {
        require(products[_id].owner == msg.sender, "Caller is not the product owner");
        _;
    }

    // Function to register a new product
    function registerProduct(
        uint256 _id,
        string memory _name,
        string memory _artisan,
        string memory _origin,
        string memory _details
    ) public {
        require(products[_id].id == 0, "Product with this ID already exists");

        // Create a new product
        products[_id] = Product({
            id: _id,
            name: _name,
            artisan: _artisan,
            origin: _origin,
            details: _details,
            owner: msg.sender,
            timestamp: block.timestamp,
            isAuthentic: true
        });

        // Emit the ProductRegistered event
        emit ProductRegistered(_id, _name, _artisan, msg.sender, block.timestamp);
    }

    // Function to transfer ownership of a product
    function transferOwnership(uint256 _id, address _newOwner)
        public
        productExists(_id)
        onlyOwner(_id)
    {
        require(_newOwner != address(0), "Invalid new owner address");

        address previousOwner = products[_id].owner;
        products[_id].owner = _newOwner;

        // Emit the OwnershipTransferred event
        emit OwnershipTransferred(_id, previousOwner, _newOwner);
    }

    // Function to verify a product's authenticity and details
    function verifyProduct(uint256 _id)
        public
        view
        productExists(_id)
        returns (
            string memory name,
            string memory artisan,
            string memory origin,
            string memory details,
            address owner,
            uint256 timestamp,
            bool isAuthentic
        )
    {
        Product memory product = products[_id];
        return (
            product.name,
            product.artisan,
            product.origin,
            product.details,
            product.owner,
            product.timestamp,
            product.isAuthentic
        );
    }

    // Function to invalidate a product's authenticity (admin-level action)
    function invalidateProduct(uint256 _id)
        public
        productExists(_id)
        onlyOwner(_id)
    {
        products[_id].isAuthentic = false;
    }
}

