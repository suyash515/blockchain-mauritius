// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificationContract {
    // Struct to store certification details
    struct Certification {
        uint256 id;                 // Unique certification ID
        string certifyingBody;      // Name of the certifying organization
        address certifiedEntity;    // Address of the entity being certified
        string certificationDetails; // Details of the certification
        uint256 issuedAt;           // Timestamp of issuance
        uint256 validUntil;         // Expiry date of the certification
        bool isValid;               // Whether the certification is valid
    }

    // Mapping to store certifications by ID
    mapping(uint256 => Certification) private certifications;

    // Counter for certification IDs
    uint256 private certificationCounter;

    // Event emitted when a certification is issued
    event CertificationIssued(
        uint256 indexed id,
        string certifyingBody,
        address indexed certifiedEntity,
        uint256 issuedAt,
        uint256 validUntil
    );

    // Event emitted when a certification is revoked
    event CertificationRevoked(uint256 indexed id, string reason);

    // Modifier to ensure a certification exists
    modifier certificationExists(uint256 certificationId) {
        require(certifications[certificationId].id != 0, "Certification does not exist");
        _;
    }

    // Function to issue a new certification
    function issueCertification(
        string memory certifyingBody,
        address certifiedEntity,
        string memory certificationDetails,
        uint256 validDuration
    ) public {
        require(certifiedEntity != address(0), "Invalid certified entity address");
        require(validDuration > 0, "Validity duration must be greater than zero");

        certificationCounter++;

        certifications[certificationCounter] = Certification({
            id: certificationCounter,
            certifyingBody: certifyingBody,
            certifiedEntity: certifiedEntity,
            certificationDetails: certificationDetails,
            issuedAt: block.timestamp,
            validUntil: block.timestamp + validDuration,
            isValid: true
        });

        emit CertificationIssued(
            certificationCounter,
            certifyingBody,
            certifiedEntity,
            block.timestamp,
            block.timestamp + validDuration
        );
    }

    // Function to revoke a certification
    function revokeCertification(uint256 certificationId, string memory reason)
        public
        certificationExists(certificationId)
    {
        Certification storage cert = certifications[certificationId];
        require(cert.isValid, "Certification is already revoked or expired");

        cert.isValid = false;

        emit CertificationRevoked(certificationId, reason);
    }

    // Function to validate a certification
    function validateCertification(uint256 certificationId)
        public
        view
        certificationExists(certificationId)
        returns (bool)
    {
        Certification memory cert = certifications[certificationId];
        if (cert.isValid && cert.validUntil > block.timestamp) {
            return true;
        }
        return false;
    }

    // Function to get certification details
    function getCertification(uint256 certificationId)
        public
        view
        certificationExists(certificationId)
        returns (
            string memory certifyingBody,
            address certifiedEntity,
            string memory certificationDetails,
            uint256 issuedAt,
            uint256 validUntil,
            bool isValid
        )
    {
        Certification memory cert = certifications[certificationId];
        return (
            cert.certifyingBody,
            cert.certifiedEntity,
            cert.certificationDetails,
            cert.issuedAt,
            cert.validUntil,
            cert.isValid
        );
    }

    // Function to get the total number of certifications issued
    function getTotalCertifications() public view returns (uint256) {
        return certificationCounter;
    }
}

