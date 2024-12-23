// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InvoiceTokenization {
    // Events
    event InvoiceTokenized(
        uint256 invoiceId,
        address indexed business,
        uint256 amount,
        uint256 dueDate,
        uint256 timestamp
    );
    event FinancingProvided(
        uint256 invoiceId,
        address indexed financier,
        uint256 amount,
        uint256 timestamp
    );
    event InvoiceSettled(
        uint256 invoiceId,
        address indexed business,
        address indexed financier,
        uint256 amount,
        uint256 timestamp
    );

    // Struct for storing invoice details
    struct Invoice {
        uint256 invoiceId;
        address business;
        uint256 amount;
        uint256 dueDate;
        bool isFinanced;
        address financier;
        bool isSettled;
    }

    // Invoice counter for unique IDs
    uint256 private invoiceCounter;

    // Mapping of invoice ID to Invoice details
    mapping(uint256 => Invoice) public invoices;

    // Mapping to check if a financier is registered
    mapping(address => bool) public registeredFinanciers;

    // Modifier to restrict actions to registered financiers
    modifier onlyRegisteredFinancier() {
        require(
            registeredFinanciers[msg.sender],
            "Caller is not a registered financier"
        );
        _;
    }

    // Modifier to check if an invoice exists
    modifier invoiceExists(uint256 invoiceId) {
        require(invoices[invoiceId].business != address(0), "Invoice does not exist");
        _;
    }

    // Function to register a financier
    function registerFinancier(address financier) external {
        registeredFinanciers[financier] = true;
    }

    // Function to tokenize an invoice
    function tokenizeInvoice(uint256 amount, uint256 dueDate)
        external
        returns (uint256)
    {
        require(amount > 0, "Amount must be greater than zero");
        require(dueDate > block.timestamp, "Due date must be in the future");

        invoiceCounter++;

        invoices[invoiceCounter] = Invoice({
            invoiceId: invoiceCounter,
            business: msg.sender,
            amount: amount,
            dueDate: dueDate,
            isFinanced: false,
            financier: address(0),
            isSettled: false
        });

        emit InvoiceTokenized(invoiceCounter, msg.sender, amount, dueDate, block.timestamp);
        return invoiceCounter;
    }

    // Function for financiers to provide financing
    function provideFinancing(uint256 invoiceId)
        external
        onlyRegisteredFinancier
        invoiceExists(invoiceId)
    {
        Invoice storage invoice = invoices[invoiceId];
        require(!invoice.isFinanced, "Invoice is already financed");
        require(!invoice.isSettled, "Invoice is already settled");

        invoice.isFinanced = true;
        invoice.financier = msg.sender;

        // Transfer the financed amount to the business
        payable(invoice.business).transfer(invoice.amount);

        emit FinancingProvided(invoiceId, msg.sender, invoice.amount, block.timestamp);
    }

    // Function to settle an invoice
    function settleInvoice(uint256 invoiceId)
        external
        payable
        invoiceExists(invoiceId)
    {
        Invoice storage invoice = invoices[invoiceId];
        require(invoice.isFinanced, "Invoice is not financed");
        require(!invoice.isSettled, "Invoice is already settled");
        require(msg.value == invoice.amount, "Incorrect settlement amount");

        // Mark the invoice as settled
        invoice.isSettled = true;

        // Transfer funds to the financier
        payable(invoice.financier).transfer(msg.value);

        emit InvoiceSettled(invoiceId, invoice.business, invoice.financier, msg.value, block.timestamp);
    }

    // Function to get invoice details
    function getInvoiceDetails(uint256 invoiceId)
        external
        view
        returns (
            address business,
            uint256 amount,
            uint256 dueDate,
            bool isFinanced,
            address financier,
            bool isSettled
        )
    {
        Invoice memory invoice = invoices[invoiceId];
        return (
            invoice.business,
            invoice.amount,
            invoice.dueDate,
            invoice.isFinanced,
            invoice.financier,
            invoice.isSettled
        );
    }
}
