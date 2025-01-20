// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RoyaltyDistributionContract {
    // Struct to store royalty details
    struct RoyaltyInfo {
        address payable recipient;  // Address of the recipient
        uint256 percentage;         // Royalty percentage (out of 100)
    }

    // Mapping to store royalty information for each product
    mapping(uint256 => RoyaltyInfo) private royalties;

    // Mapping to track royalty balances for each recipient
    mapping(address => uint256) private royaltyBalances;

    // Event emitted when royalties are distributed
    event RoyaltiesDistributed(uint256 indexed productId, address indexed recipient, uint256 amount);

    // Event emitted when a recipient withdraws their royalties
    event RoyaltiesWithdrawn(address indexed recipient, uint256 amount);

    // Modifier to ensure a valid royalty percentage
    modifier validPercentage(uint256 percentage) {
        require(percentage > 0 && percentage <= 100, "Invalid royalty percentage");
        _;
    }

    // Function to set royalty information for a product
    function setRoyalty(uint256 productId, address payable recipient, uint256 percentage)
        public
        validPercentage(percentage)
    {
        require(royalties[productId].recipient == address(0), "Royalty already set for this product");
        require(recipient != address(0), "Invalid recipient address");

        royalties[productId] = RoyaltyInfo({recipient: recipient, percentage: percentage});
    }

    // Function to distribute royalties when a product is sold
    function distributeRoyalty(uint256 productId, uint256 saleAmount) public payable {
        RoyaltyInfo memory royalty = royalties[productId];
        require(royalty.recipient != address(0), "No royalty information set for this product");
        require(saleAmount > 0, "Sale amount must be greater than zero");

        uint256 royaltyAmount = (saleAmount * royalty.percentage) / 100;
        require(msg.value == royaltyAmount, "Incorrect royalty amount sent");

        royaltyBalances[royalty.recipient] += royaltyAmount;

        emit RoyaltiesDistributed(productId, royalty.recipient, royaltyAmount);
    }

    // Function to allow recipients to withdraw their royalties
    function withdrawRoyalties() public {
        uint256 amount = royaltyBalances[msg.sender];
        require(amount > 0, "No royalties available for withdrawal");

        royaltyBalances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit RoyaltiesWithdrawn(msg.sender, amount);
    }

    // Function to get royalty details for a product
    function getRoyaltyInfo(uint256 productId) public view returns (address recipient, uint256 percentage) {
        RoyaltyInfo memory royalty = royalties[productId];
        return (royalty.recipient, royalty.percentage);
    }

    // Function to check the royalty balance of a recipient
    function getRoyaltyBalance(address recipient) public view returns (uint256) {
        return royaltyBalances[recipient];
    }
}

