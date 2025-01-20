// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChainContract {
    // Struct to represent a supply chain checkpoint
    struct Checkpoint {
        uint256 timestamp;      // Time of the checkpoint
        string location;        // Location of the checkpoint
        string description;     // Description of the checkpoint (e.g., "Manufactured", "Shipped")
        address handler;        // Address of the entity handling the product at this stage
    }

    // Struct to represent a product's supply chain data
    struct Product {
        uint256 id;                         // Unique product ID
        string name;                        // Name of the product
        bool isInSupplyChain;               // Flag indicating if the product is active in the supply chain
        Checkpoint[] checkpoints;          // Array of checkpoints for the product
    }

    // Mapping to store product supply chain data by product ID
    mapping(uint256 => Product) private products;

    // Event emitted when a product is added to the supply chain
    event ProductAdded(uint256 indexed productId, string name);

    // Event emitted when a new checkpoint is added for a product
    event CheckpointAdded(
        uint256 indexed productId,
        string location,
        string description,
        address indexed handler,
        uint256 timestamp
    );

    // Modifier to ensure a product exists in the supply chain
    modifier productExists(uint256 productId) {
        require(products[productId].isInSupplyChain, "Product does not exist in the supply chain");
        _;
    }

    // Function to add a new product to the supply chain
    function addProduct(uint256 productId, string memory name) public {
        require(!products[productId].isInSupplyChain, "Product already exists in the supply chain");

        products[productId] = Product({
            id: productId,
            name: name,
            isInSupplyChain: true,
            checkpoints: new Checkpoint     });

        emit ProductAdded(productId, name);
    }

    // Function to add a new checkpoint to a product's supply chain
    function addCheckpoint(
        uint256 productId,
        string memory location,
        string memory description
    ) public productExists(productId) {
        Product storage product = products[productId];
        product.checkpoints.push(
            Checkpoint({
                timestamp: block.timestamp,
                location: location,
                description: description,
                handler: msg.sender
            })
        );

        emit CheckpointAdded(productId, location, description, msg.sender, block.timestamp);
    }

    // Function to get the details of a product
    function getProduct(uint256 productId)
        public
        view
        productExists(productId)
        returns (string memory name, uint256 checkpointCount)
    {
        Product memory product = products[productId];
        return (product.name, product.checkpoints.length);
    }

    // Function to get all checkpoints for a product
    function getCheckpoints(uint256 productId)
        public
        view
        productExists(productId)
        returns (Checkpoint[] memory)
    {
        return products[productId].checkpoints;
    }
}

