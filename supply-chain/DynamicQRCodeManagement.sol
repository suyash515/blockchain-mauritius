// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract DynamicQRCodeManagement {
    using ECDSA for bytes32;

    struct QRCode {
        uint256 productId;
        bytes32 currentHash;
        bool isActive;
    }

    mapping(uint256 => QRCode) private qrCodes;
    mapping(bytes32 => bool) private usedHashes;

    event QRCodeGenerated(uint256 productId, bytes32 hash);
    event QRCodeScanned(uint256 productId, bytes32 hash, address scanner);

    modifier onlyActive(uint256 productId) {
        require(qrCodes[productId].isActive, "QR Code is not active.");
        _;
    }

    function generateQRCode(uint256 productId, string memory data) public returns (bytes32) {
        require(!qrCodes[productId].isActive, "A QR Code is already active for this product.");
        bytes32 hash = keccak256(abi.encodePacked(data, block.timestamp, productId));
        qrCodes[productId] = QRCode({
            productId: productId,
            currentHash: hash,
            isActive: true
        });

        emit QRCodeGenerated(productId, hash);
        return hash;
    }

    function scanQRCode(uint256 productId, string memory data) public onlyActive(productId) returns (bool) {
        QRCode storage qrCode = qrCodes[productId];
        bytes32 newHash = keccak256(abi.encodePacked(data, block.timestamp, productId));

        require(!usedHashes[qrCode.currentHash], "QR Code has already been scanned.");
        require(qrCode.currentHash == keccak256(abi.encodePacked(data)), "QR Code data mismatch.");

        usedHashes[qrCode.currentHash] = true;
        qrCode.currentHash = newHash;

        emit QRCodeScanned(productId, newHash, msg.sender);
        return true;
    }

    function deactivateQRCode(uint256 productId) public onlyActive(productId) {
        qrCodes[productId].isActive = false;
    }

    function getQRCodeDetails(uint256 productId) public view returns (bytes32 currentHash, bool isActive) {
        require(qrCodes[productId].isActive, "QR Code is not active.");
        QRCode storage qrCode = qrCodes[productId];
        return (qrCode.currentHash, qrCode.isActive);
    }
}
