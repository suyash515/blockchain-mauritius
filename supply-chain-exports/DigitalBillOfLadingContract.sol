// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DigitalBillOfLadingContract {
    struct BillOfLading {
        string billId;
        string productId;
        string exporter;
        string importer;
        string carrier;
        string departurePort;
        string destinationPort;
        string shipmentDate;
        string deliveryDate;
        string currentStatus; // e.g., "In Transit", "Delivered", "Pending"
        bool isFinalized;
    }

    mapping(string => BillOfLading) private billsOfLading;
    address public owner;

    event BillOfLadingCreated(
        string billId,
        string productId,
        string exporter,
        string importer,
        string carrier,
        string departurePort,
        string destinationPort,
        string shipmentDate
    );

    event StatusUpdated(string billId, string currentStatus);
    event BillOfLadingFinalized(string billId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createBillOfLading(
        string memory _billId,
        string memory _productId,
        string memory _exporter,
        string memory _importer,
        string memory _carrier,
        string memory _departurePort,
        string memory _destinationPort,
        string memory _shipmentDate
    ) public onlyOwner {
        require(bytes(_billId).length > 0, "Bill ID cannot be empty.");
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(_exporter).length > 0, "Exporter cannot be empty.");
        require(bytes(_importer).length > 0, "Importer cannot be empty.");
        require(bytes(_carrier).length > 0, "Carrier cannot be empty.");
        require(bytes(_departurePort).length > 0, "Departure port cannot be empty.");
        require(bytes(_destinationPort).length > 0, "Destination port cannot be empty.");
        require(bytes(_shipmentDate).length > 0, "Shipment date cannot be empty.");
        require(bytes(billsOfLading[_billId].billId).length == 0, "Bill ID already exists.");

        billsOfLading[_billId] = BillOfLading(
            _billId,
            _productId,
            _exporter,
            _importer,
            _carrier,
            _departurePort,
            _destinationPort,
            _shipmentDate,
            "",
            "Pending",
            false
        );

        emit BillOfLadingCreated(
            _billId,
            _productId,
            _exporter,
            _importer,
            _carrier,
            _departurePort,
            _destinationPort,
            _shipmentDate
        );
    }

    function updateStatus(string memory _billId, string memory _currentStatus) public onlyOwner {
        require(bytes(_billId).length > 0, "Bill ID cannot be empty.");
        require(bytes(billsOfLading[_billId].billId).length > 0, "Bill of Lading not found.");
        require(!billsOfLading[_billId].isFinalized, "Bill of Lading is finalized and cannot be updated.");

        billsOfLading[_billId].currentStatus = _currentStatus;

        emit StatusUpdated(_billId, _currentStatus);
    }

    function finalizeBillOfLading(string memory _billId, string memory _deliveryDate) public onlyOwner {
        require(bytes(_billId).length > 0, "Bill ID cannot be empty.");
        require(bytes(billsOfLading[_billId].billId).length > 0, "Bill of Lading not found.");
        require(!billsOfLading[_billId].isFinalized, "Bill of Lading is already finalized.");
        require(bytes(_deliveryDate).length > 0, "Delivery date cannot be empty.");

        billsOfLading[_billId].deliveryDate = _deliveryDate;
        billsOfLading[_billId].isFinalized = true;

        emit BillOfLadingFinalized(_billId);
    }

    function getBillOfLading(string memory _billId)
        public
        view
        returns (
            string memory productId,
            string memory exporter,
            string memory importer,
            string memory carrier,
            string memory departurePort,
            string memory destinationPort,
            string memory shipmentDate,
            string memory deliveryDate,
            string memory currentStatus,
            bool isFinalized
        )
    {
        require(bytes(_billId).length > 0, "Bill ID cannot be empty.");
        require(bytes(billsOfLading[_billId].billId).length > 0, "Bill of Lading not found.");

        BillOfLading memory bill = billsOfLading[_billId];
        return (
            bill.productId,
            bill.exporter,
            bill.importer,
            bill.carrier,
            bill.departurePort,
            bill.destinationPort,
            bill.shipmentDate,
            bill.deliveryDate,
            bill.currentStatus,
            bill.isFinalized
        );
    }
}

