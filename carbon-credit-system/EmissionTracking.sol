// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EmissionTracking {
    struct EmissionData {
        uint256 timestamp;
        uint256 emissionAmount; // Measured in metric tons
        string source; // Source of emissions (e.g., production, transport)
    }

    mapping(address => EmissionData[]) public emissions;
    address public admin;

    event EmissionRecorded(
        address indexed business,
        uint256 timestamp,
        uint256 emissionAmount,
        string source
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function recordEmission(
        address _business,
        uint256 _emissionAmount,
        string memory _source
    ) public onlyAdmin {
        emissions[_business].push(EmissionData({
            timestamp: block.timestamp,
            emissionAmount: _emissionAmount,
            source: _source
        }));

        emit EmissionRecorded(_business, block.timestamp, _emissionAmount, _source);
    }

    function getEmissions(address _business) public view returns (EmissionData[] memory) {
        return emissions[_business];
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
}

