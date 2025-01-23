// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CarbonCreditIssuance {
    struct CarbonCredit {
        uint256 amount; // Number of credits
        uint256 timestamp;
        string description; // Description of the activity (e.g., "Solar energy production")
    }

    mapping(address => CarbonCredit[]) public carbonCredits;
    address public admin;

    event CarbonCreditIssued(
        address indexed business,
        uint256 amount,
        uint256 timestamp,
        string description
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function issueCarbonCredit(
        address _business,
        uint256 _amount,
        string memory _description
    ) public onlyAdmin {
        require(_amount > 0, "Credit amount must be greater than zero");

        carbonCredits[_business].push(CarbonCredit({
            amount: _amount,
            timestamp: block.timestamp,
            description: _description
        }));

        emit CarbonCreditIssued(_business, _amount, block.timestamp, _description);
    }

    function getCarbonCredits(address _business) public view returns (CarbonCredit[] memory) {
        return carbonCredits[_business];
    }

    function totalCredits(address _business) public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < carbonCredits[_business].length; i++) {
            total += carbonCredits[_business][i].amount;
        }
        return total;
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
}
