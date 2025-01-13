// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DeliveryConfirmationContract {
    struct Delivery {
        string deliveryId;
        string shipmentId;
        string productId;
        string recipient;
        string deliveryAddress;
        string deliveryDate;
        string status; // e.g., "Pending", "Delivered", "Failed"
        string confirmationBy;
        bool isConfirmed;
    }

    mapping(string => Delivery) private deliveries;
    address public owner;

    event DeliveryCreated(
        string deliveryId,
        string shipmentId,
        string productId,
        string recipient,
        string deliveryAddress,
        string status
    );

    event DeliveryConfirmed(string deliveryId, string confirmationBy, string deliveryDate);
    event DeliveryFailed(string deliveryId, string reason);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createDelivery(
        string memory _deliveryId,
        string memory _shipmentId,
        string memory _productId,
        string memory _recipient,
        string memory _deliveryAddress
    ) public onlyOwner {
        require(bytes(_deliveryId).length > 0, "Delivery ID cannot be empty.");
        require(bytes(_shipmentId).length > 0, "Shipment ID cannot be empty.");
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(_recipient).length > 0, "Recipient cannot be empty.");
        require(bytes(_deliveryAddress).length > 0, "Delivery address cannot be empty.");
        require(bytes(deliveries[_deliveryId].deliveryId).length == 0, "Delivery ID already exists.");

        deliveries[_deliveryId] = Delivery(
            _deliveryId,
            _shipmentId,
            _productId,
            _recipient,
            _deliveryAddress,
            "",
            "Pending",
            "",
            false
        );

        emit DeliveryCreated(
            _deliveryId,
            _shipmentId,
            _productId,
            _recipient,
            _deliveryAddress,
            "Pending"
        );
    }

    function confirmDelivery(
        string memory _deliveryId,
        string memory _confirmationBy,
        string memory _deliveryDate
    ) public onlyOwner {
        require(bytes(_deliveryId).length > 0, "Delivery ID cannot be empty.");
        require(bytes(_confirmationBy).length > 0, "Confirmation by cannot be empty.");
        require(bytes(_deliveryDate).length > 0, "Delivery date cannot be empty.");
        require(bytes(deliveries[_deliveryId].deliveryId).length > 0, "Delivery not found.");
        require(!deliveries[_deliveryId].isConfirmed, "Delivery is already confirmed.");

        deliveries[_deliveryId].status = "Delivered";
        deliveries[_deliveryId].deliveryDate = _deliveryDate;
        deliveries[_deliveryId].confirmationBy = _confirmationBy;
        deliveries[_deliveryId].isConfirmed = true;

        emit DeliveryConfirmed(_deliveryId, _confirmationBy, _deliveryDate);
    }

    function failDelivery(string memory _deliveryId, string memory _reason) public onlyOwner {
        require(bytes(_deliveryId).length > 0, "Delivery ID cannot be empty.");
        require(bytes(_reason).length > 0, "Reason cannot be empty.");
        require(bytes(deliveries[_deliveryId].deliveryId).length > 0, "Delivery not found.");
        require(!deliveries[_deliveryId].isConfirmed, "Cannot fail a confirmed delivery.");

        deliveries[_deliveryId].status = "Failed";

        emit DeliveryFailed(_deliveryId, _reason);
    }

    function getDeliveryDetails(string memory _deliveryId)
        public
        view
        returns (
            string memory shipmentId,
            string memory productId,
            string memory recipient,
            string memory deliveryAddress,
            string memory deliveryDate,
            string memory status,
            string memory confirmationBy,
            bool isConfirmed
        )
    {
        require(bytes(_deliveryId).length > 0, "Delivery ID cannot be empty.");
        require(bytes(deliveries[_deliveryId].deliveryId).length > 0, "Delivery not found.");

        Delivery memory delivery = deliveries[_deliveryId];
        return (
            delivery.shipmentId,
            delivery.productId,
            delivery.recipient,
            delivery.deliveryAddress,
            delivery.deliveryDate,
            delivery.status,
            delivery.confirmationBy,
            delivery.isConfirmed
        );
    }
}

