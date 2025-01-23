// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnergyOffset {
    struct Offset {
        uint256 timestamp;
        uint256 energyGenerated; // Amount of energy generated in kWh
        string source; // Source of renewable energy (e.g., "Solar", "Wind")
        uint256 carbonCreditsEarned; // Carbon credits earned for the offset
    }

    mapping(address => Offset[]) public offsets;
    mapping(address => uint256) public totalCarbonCredits; // Total carbon credits earned by each business
    address public admin;

    event OffsetRecorded(
        address indexed business,
        uint256 energyGenerated,
        string source,
        uint256 carbonCreditsEarned,
        uint256 timestamp
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function recordOffset(
        address _business,
        uint256 _energyGenerated,
        string memory _source,
        uint256 _carbonCreditsEarned
    ) public onlyAdmin {
        require(_business != address(0), "Invalid business address");
        require(_energyGenerated > 0, "Energy generated must be greater than zero");
        require(_carbonCreditsEarned > 0, "Carbon credits must be greater than zero");

        offsets[_business].push(Offset({
            timestamp: block.timestamp,
            energyGenerated: _energyGenerated,
            source: _source,
            carbonCreditsEarned: _carbonCreditsEarned
        }));

        totalCarbonCredits[_business] += _carbonCreditsEarned;

        emit OffsetRecorded(_business, _energyGenerated, _source, _carbonCreditsEarned, block.timestamp);
    }

    function getOffsets(address _business) public view returns (Offset[] memory) {
        return offsets[_business];
    }

    function getTotalCarbonCredits(address _business) public view returns (uint256) {
        return totalCarbonCredits[_business];
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
}
