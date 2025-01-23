// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GreenCertification {
    struct Certification {
        uint256 issuedDate;
        string certificationDetails; // Description of the certification (e.g., "100% Renewable Energy Usage")
        bool isValid;
    }

    mapping(address => Certification[]) public certifications;
    address public admin;
    uint256 public requiredCredits; // Number of carbon credits needed for certification

    event CertificationIssued(
        address indexed business,
        string certificationDetails,
        uint256 issuedDate
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor(uint256 _requiredCredits) {
        admin = msg.sender;
        requiredCredits = _requiredCredits;
    }

    function issueCertification(
        address _business,
        uint256 _availableCredits,
        string memory _certificationDetails
    ) public onlyAdmin {
        require(_availableCredits >= requiredCredits, "Insufficient carbon credits");

        certifications[_business].push(Certification({
            issuedDate: block.timestamp,
            certificationDetails: _certificationDetails,
            isValid: true
        }));

        emit CertificationIssued(_business, _certificationDetails, block.timestamp);
    }

    function getCertifications(address _business) public view returns (Certification[] memory) {
        return certifications[_business];
    }

    function changeRequiredCredits(uint256 _newRequiredCredits) public onlyAdmin {
        require(_newRequiredCredits > 0, "Required credits must be greater than zero");
        requiredCredits = _newRequiredCredits;
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
}
