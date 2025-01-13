// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ColdChainComplianceContract {
    struct Shipment {
        string shipmentId;
        string productId;
        string origin;
        string destination;
        string carrier;
        string departureDate;
        string expectedArrivalDate;
        bool isCompliant;
    }

    struct TemperatureLog {
        uint256 timestamp;
        int256 temperature; // Temperature in Celsius
    }

    mapping(string => Shipment) private shipments;
    mapping(string => TemperatureLog[]) private temperatureLogs;

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

    event TemperatureLogged(string shipmentId, uint256 timestamp, int256 temperature);
    event ComplianceStatusUpdated(string shipmentId, bool isCompliant);

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
            true // Assume compliant initially
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

    function logTemperature(
        string memory _shipmentId,
        int256 _temperature
    ) public onlyOwner {
        require(bytes(_shipmentId).length > 0, "Shipment ID cannot be empty.");
        require(bytes(shipments[_shipmentId].shipmentId).length > 0, "Shipment not found.");

        uint256 currentTimestamp = block.timestamp;
        temperatureLogs[_shipmentId].push(TemperatureLog(currentTimestamp, _temperature));

        emit TemperatureLogged(_shipmentId, currentTimestamp, _temperature);

        if (_temperature < -10 || _temperature > 25) {
            shipments[_shipmentId].isCompliant = false;
            emit ComplianceStatusUpdated(_shipmentId, false);
        }
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
            bool isCompliant
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
            shipment.isCompliant
        );
    }

    function getTemperatureLogs(string memory _shipmentId)
        public
        view
        returns (TemperatureLog[] memory)
    {
        require(bytes(_shipmentId).length > 0, "Shipment ID cannot be empty.");
        require(bytes(shipments[_shipmentId].shipmentId).length > 0, "Shipment not found.");

        return temperatureLogs[_shipmentId];
    }
}

