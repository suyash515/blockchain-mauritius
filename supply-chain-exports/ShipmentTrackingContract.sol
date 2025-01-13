// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShipmentTrackingContract {
    struct Shipment {
        string shipmentId;
        string productId;
        string origin;
        string destination;
        string carrier;
        string departureDate;
        string expectedArrivalDate;
        string currentLocation;
        string status; // e.g., "In Transit", "Delayed", "Delivered"
        bool isDelivered;
    }

    mapping(string => Shipment) private shipments;
    address public owner;

    event ShipmentCreated(
        string shipmentId,
        string productId,
        string origin,
        string destination,
        string carrier,
        string departureDate,
        string expectedArrivalDate
    );

    event LocationUpdated(string shipmentId, string currentLocation);
    event StatusUpdated(string shipmentId, string status);
    event ShipmentDelivered(string shipmentId, string deliveryDate);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createShipment(
        string memory _shipmentId,
        string memory _productId,
        string memory _origin,
        string memory _destination,
        string memory _carrier,
        string memory _departureDate,
        string memory _expectedArrivalDate
    ) public onlyOwner {
        require(bytes(_shipmentId).length > 0, "Shipment ID cannot be empty.");
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(_origin).length > 0, "Origin cannot be empty.");
        require(bytes(_destination).length > 0, "Destination cannot be empty.");
        require(bytes(_carrier).length > 0, "Carrier cannot be empty.");
        require(bytes(_departureDate).length > 0, "Departure date cannot be empty.");
        require(bytes(_expectedArrivalDate).length > 0, "Expected arrival date cannot be empty.");
        require(bytes(shipments[_shipmentId].shipmentId).length == 0, "Shipment ID already exists.");

        shipments[_shipmentId] = Shipment(
            _shipmentId,
            _productId,
            _origin,
            _destination,
            _carrier,
            _departureDate,
            _expectedArrivalDate,
            _origin,
            "Pending",
            false
        );

        emit ShipmentCreated(
            _shipmentId,
            _productId,
            _origin,
            _destination,
            _carrier,
            _departureDate,
            _expectedArrivalDate
        );
    }

    function updateLocation(string memory _shipmentId, string memory _currentLocation) public onlyOwner {
        require(bytes(_shipmentId).length > 0, "Shipment ID cannot be empty.");
        require(bytes(shipments[_shipmentId].shipmentId).length > 0, "Shipment not found.");
        require(!shipments[_shipmentId].isDelivered, "Shipment is already delivered.");

        shipments[_shipmentId].currentLocation = _currentLocation;

        emit LocationUpdated(_shipmentId, _currentLocation);
    }

    function updateStatus(string memory _shipmentId, string memory _status) public onlyOwner {
        require(bytes(_shipmentId).length > 0, "Shipment ID cannot be empty.");
        require(bytes(shipments[_shipmentId].shipmentId).length > 0, "Shipment not found.");
        require(!shipments[_shipmentId].isDelivered, "Shipment is already delivered.");

        shipments[_shipmentId].status = _status;

        emit StatusUpdated(_shipmentId, _status);
    }

    function markAsDelivered(string memory _shipmentId, string memory _deliveryDate) public onlyOwner {
        require(bytes(_shipmentId).length > 0, "Shipment ID cannot be empty.");
        require(bytes(shipments[_shipmentId].shipmentId).length > 0, "Shipment not found.");
        require(!shipments[_shipmentId].isDelivered, "Shipment is already marked as delivered.");
        require(bytes(_deliveryDate).length > 0, "Delivery date cannot be empty.");

        shipments[_shipmentId].status = "Delivered";
        shipments[_shipmentId].isDelivered = true;

        emit ShipmentDelivered(_shipmentId, _deliveryDate);
    }

    function getShipmentDetails(string memory _shipmentId)
        public
        view
        returns (
            string memory productId,
            string memory origin,
            string memory destination,
            string memory carrier,
            string memory departureDate,
            string memory expectedArrivalDate,
            string memory currentLocation,
            string memory status,
            bool isDelivered
        )
    {
        require(bytes(_shipmentId).length > 0, "Shipment ID cannot be empty.");
        require(bytes(shipments[_shipmentId].shipmentId).length > 0, "Shipment not found.");

        Shipment memory shipment = shipments[_shipmentId];
        return (
            shipment.productId,
            shipment.origin,
            shipment.destination,
            shipment.carrier,
            shipment.departureDate,
            shipment.expectedArrivalDate,
            shipment.currentLocation,
            shipment.status,
            shipment.isDelivered
        );
    }
}

