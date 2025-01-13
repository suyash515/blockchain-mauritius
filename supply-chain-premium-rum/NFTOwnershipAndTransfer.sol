// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTOwnershipAndTransfer is ERC721, Ownable {
    uint256 private tokenCounter;

    struct ProductDetails {
        string name;
        string batchNumber;
        string origin;
        string productionDate;
        string certifications;
    }

    mapping(uint256 => ProductDetails) private productDetails;

    event NFTMinted(uint256 tokenId, address owner, string name, string batchNumber, string origin);

    constructor() ERC721("MauritianRumNFT", "MRNFT") {
        tokenCounter = 0;
    }

    function mintNFT(
        address recipient,
        string memory name,
        string memory batchNumber,
        string memory origin,
        string memory productionDate,
        string memory certifications
    ) public onlyOwner returns (uint256) {
        tokenCounter++;
        uint256 newTokenId = tokenCounter;

        _mint(recipient, newTokenId);

        productDetails[newTokenId] = ProductDetails({
            name: name,
            batchNumber: batchNumber,
            origin: origin,
            productionDate: productionDate,
            certifications: certifications
        });

        emit NFTMinted(newTokenId, recipient, name, batchNumber, origin);
        return newTokenId;
    }

    function transferNFT(uint256 tokenId, address newOwner) public {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can transfer this NFT.");
        _transfer(msg.sender, newOwner, tokenId);
    }

    function getProductDetails(uint256 tokenId) public view returns (
        string memory name,
        string memory batchNumber,
        string memory origin,
        string memory productionDate,
        string memory certifications
    ) {
        require(_exists(tokenId), "Token does not exist.");
        ProductDetails memory details = productDetails[tokenId];
        return (
            details.name,
            details.batchNumber,
            details.origin,
            details.productionDate,
            details.certifications
        );
    }
}
