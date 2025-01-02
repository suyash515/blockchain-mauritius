// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataSharingConsent {
    struct Consent {
        address dataOwner;
        address dataReceiver;
        bool isGranted;
        uint256 timestamp;
    }

    mapping(address => mapping(address => Consent)) private consents;

    event ConsentGranted(address indexed dataOwner, address indexed dataReceiver, uint256 timestamp);
    event ConsentRevoked(address indexed dataOwner, address indexed dataReceiver, uint256 timestamp);

    modifier onlyDataOwner(address _dataOwner) {
        require(msg.sender == _dataOwner, "Not authorized");
        _;
    }

    // Grant consent to share data
    function grantConsent(address _dataReceiver) public {
        require(_dataReceiver != address(0), "Invalid data receiver address");
        require(!consents[msg.sender][_dataReceiver].isGranted, "Consent already granted");

        consents[msg.sender][_dataReceiver] = Consent({
            dataOwner: msg.sender,
            dataReceiver: _dataReceiver,
            isGranted: true,
            timestamp: block.timestamp
        });

        emit ConsentGranted(msg.sender, _dataReceiver, block.timestamp);
    }

    // Revoke consent to share data
    function revokeConsent(address _dataReceiver) public onlyDataOwner(msg.sender) {
        require(consents[msg.sender][_dataReceiver].isGranted, "Consent not granted");

        consents[msg.sender][_dataReceiver].isGranted = false;
        consents[msg.sender][_dataReceiver].timestamp = block.timestamp;

        emit ConsentRevoked(msg.sender, _dataReceiver, block.timestamp);
    }

    // Check if consent is granted
    function isConsentGranted(address _dataOwner, address _dataReceiver) public view returns (bool) {
        return consents[_dataOwner][_dataReceiver].isGranted;
    }

    // Get consent details
    function getConsentDetails(address _dataOwner, address _dataReceiver) public view returns (
        bool isGranted,
        uint256 timestamp
    ) {
        Consent memory consent = consents[_dataOwner][_dataReceiver];
        require(consent.dataOwner == _dataOwner, "No consent exists");

        return (consent.isGranted, consent.timestamp);
    }
}
