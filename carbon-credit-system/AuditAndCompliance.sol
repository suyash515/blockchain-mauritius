// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuditAndCompliance {
    struct Audit {
        uint256 timestamp;
        address business;
        string report; // Details of the audit report
        bool isCompliant;
    }

    mapping(address => Audit[]) public auditRecords;
    address public admin;

    event AuditConducted(
        address indexed business,
        uint256 timestamp,
        string report,
        bool isCompliant
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function conductAudit(
        address _business,
        string memory _report,
        bool _isCompliant
    ) public onlyAdmin {
        require(_business != address(0), "Invalid business address");

        auditRecords[_business].push(Audit({
            timestamp: block.timestamp,
            business: _business,
            report: _report,
            isCompliant: _isCompliant
        }));

        emit AuditConducted(_business, block.timestamp, _report, _isCompliant);
    }

    function getAuditReports(address _business) public view returns (Audit[] memory) {
        return auditRecords[_business];
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
}
