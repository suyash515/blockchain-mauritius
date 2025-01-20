// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OwnershipContract {
    // Struct to store ownership details
    struct OwnershipRecord {
        address owner;       // Address of the current or previous owner
        uint256 timestamp;   // Time of ownership transfer
    }

    // Mapping to track the history of ownership for each product ID
    mapping(uint256 => OwnershipRecord[]) private ownershipHistory;

    // Mapping to store the current owner of each product
    mapping(uint256 => address) private currentOwner;

    // Event emitted when ownership is transferred
    event OwnershipTransferred(
        uint256 indexed productId,
        address indexed previousOwner,
        address indexed newOwner,
        uint256 timestamp
    );

    // Modifier to ensure the caller is the current owner of the product
    modifier onlyOwner(uint256 productId) {
        require(
            msg.sender == currentOwner[productId],
            "Caller is not the current owner"
        );
        _;
    }

    // Modifier to ensure the product has an owner
    modifier productExists(uint256 productId) {
        require(
            currentOwner[productId] != address(0),
            "Product does not exist or has no owner"
        );
        _;
    }

    // Function to initialize the ownership of a product (only once)
    function initializeOwnership(uint256 productId, address initialOwner) public {
        require(
            currentOwner[productId] == address(0),
            "Ownership already initialized for this product"
        );
        require(initialOwner != address(0), "Invalid initial owner address");

        // Set the initial owner
        currentOwner[productId] = initialOwner;

        // Record the initial ownership
        ownershipHistory[productId].push(
            OwnershipRecord({owner: initialOwner, timestamp: block.timestamp})
        );
    }

    // Function to transfer ownership of a product
    function transferOwnership(uint256 productId, address newOwner)
        public
        productExists(productId)
        onlyOwner(productId)
    {
        require(newOwner != address(0), "Invalid new owner address");

        // Log the current owner
        address previousOwner = currentOwner[productId];

        // Update the current owner
        currentOwner[productId] = newOwner;

        // Add a new ownership record
        ownershipHistory[productId].push(
            OwnershipRecord({owner: newOwner, timestamp: block.timestamp})
        );

        // Emit an event for the transfer
        emit OwnershipTransferred(productId, previousOwner, newOwner, block.timestamp);
    }

    // Function to get the current owner of a product
    function getCurrentOwner(uint256 productId)
        public
        view
        productExists(productId)
        returns (address)
    {
        return currentOwner[productId];
    }

    // Function to retrieve ownership history of a product
    function getOwnershipHistory(uint256 productId)
        public
        view
        productExists(productId)
        returns (OwnershipRecord[] memory)
    {
        return ownershipHistory[productId];
    }

    // Function to check if an address has ever owned a specific product
    function hasEverOwned(uint256 productId, address ownerAddress)
        public
        view
        productExists(productId)
        returns (bool)
    {
        OwnershipRecord[] memory history = ownershipHistory[productId];
        for (uint256 i = 0; i < history.length; i++) {
            if (history[i].owner == ownerAddress) {
                return true;
            }
        }
        return false;
    }
}

