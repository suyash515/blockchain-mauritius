// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title DigitalVATRefund
 * @dev Smart contract to automate VAT refunds for eligible tourists and foreign buyers
 */
contract DigitalVATRefund {
    address public taxAuthority;
    uint256 public vatRate; // VAT rate in percentage (e.g., 15 for 15%)

    struct Purchase {
        uint256 amount;
        uint256 vatPaid;
        bool refunded;
    }

    mapping(address => Purchase[]) public purchaseRecords;
    mapping(address => bool) public verifiedTourists;

    event PurchaseRecorded(address indexed buyer, uint256 amount, uint256 vatPaid);
    event VATRefundIssued(address indexed buyer, uint256 refundAmount);
    event TouristVerified(address indexed tourist, bool status);

    constructor(uint256 _vatRate, address _taxAuthority) {
        require(_vatRate > 0 && _vatRate <= 100, "Invalid VAT rate");
        require(_taxAuthority != address(0), "Invalid tax authority address");

        vatRate = _vatRate;
        taxAuthority = _taxAuthority;
    }

    /**
     * @dev Records a VAT-paid purchase for a buyer (called by registered merchants)
     * @param buyer Address of the buyer (tourist)
     */
    function recordPurchase(address buyer) external payable {
        require(msg.value > 0, "Purchase amount must be greater than zero");
        require(buyer != address(0), "Invalid buyer address");

        uint256 vatPaid = (msg.value * vatRate) / 100;
        
        purchaseRecords[buyer].push(Purchase({
            amount: msg.value,
            vatPaid: vatPaid,
            refunded: false
        }));

        emit PurchaseRecorded(buyer, msg.value, vatPaid);
    }

    /**
     * @dev Approves and processes VAT refund for a verified tourist upon departure
     */
    function processVATRefund() external {
        require(verifiedTourists[msg.sender], "Tourist not verified for VAT refund");

        uint256 totalRefund = 0;
        Purchase[] storage purchases = purchaseRecords[msg.sender];

        for (uint256 i = 0; i < purchases.length; i++) {
            if (!purchases[i].refunded) {
                totalRefund += purchases[i].vatPaid;
                purchases[i].refunded = true;
            }
        }

        require(totalRefund > 0, "No refundable VAT available");

        // Transfer VAT refund to the tourist
        payable(msg.sender).transfer(totalRefund);

        emit VATRefundIssued(msg.sender, totalRefund);
    }

    /**
     * @dev Verifies tourist eligibility for VAT refund (only callable by tax authority)
     * @param tourist Address of the tourist to verify
     * @param status True if verified, false if not
     */
    function verifyTourist(address tourist, bool status) external {
        require(msg.sender == taxAuthority, "Only tax authority can verify tourists");
        require(tourist != address(0), "Invalid tourist address");

        verifiedTourists[tourist] = status;

        emit TouristVerified(tourist, status);
    }

    /**
     * @dev Updates the tax authority address (only callable by current tax authority)
     * @param newTaxAuthority New tax authority address
     */
    function updateTaxAuthority(address newTaxAuthority) external {
        require(msg.sender == taxAuthority, "Only current tax authority can update address");
        require(newTaxAuthority != address(0), "Invalid tax authority address");
        taxAuthority = newTaxAuthority;
    }

    /**
     * @dev Fallback function to prevent accidental ETH transfers
     */
    receive() external payable {
        revert("Direct ETH transfers not allowed");
    }
}

