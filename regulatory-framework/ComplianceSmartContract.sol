// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ComplianceSmartContract {
    address public regulator;
    mapping(address => bool) public verifiedUsers;
    mapping(address => bool) public flaggedAddresses;

    event UserVerified(address indexed user);
    event UserFlagged(address indexed user);
    event SuspiciousTransactionReported(address indexed from, address indexed to, uint256 amount);
    event RegulatorUpdated(address indexed oldRegulator, address indexed newRegulator);

    modifier onlyRegulator() {
        require(msg.sender == regulator, "Only the regulator can perform this action");
        _;
    }

    constructor() {
        regulator = msg.sender;
    }

    function updateRegulator(address newRegulator) external onlyRegulator {
        require(newRegulator != address(0), "Invalid address for new regulator");
        emit RegulatorUpdated(regulator, newRegulator);
        regulator = newRegulator;
    }

    function verifyUser(address user) external onlyRegulator {
        verifiedUsers[user] = true;
        emit UserVerified(user);
    }

    function flagUser(address user) external onlyRegulator {
        flaggedAddresses[user] = true;
        emit UserFlagged(user);
    }

    function reportTransaction(address from, address to, uint256 amount) external {
        require(flaggedAddresses[from] || flaggedAddresses[to], "No flagged users involved in this transaction");
        emit SuspiciousTransactionReported(from, to, amount);
    }

    function isUserVerified(address user) external view returns (bool) {
        return verifiedUsers[user];
    }

    function isAddressFlagged(address user) external view returns (bool) {
        return flaggedAddresses[user];
    }
}

