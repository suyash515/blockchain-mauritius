// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ArtisanRegistryContract {
    // Struct to store artisan details
    struct Artisan {
        address artisanAddress;  // Address of the artisan
        string name;             // Name of the artisan
        string contactInfo;      // Contact information (e.g., email or phone)
        string bio;              // Short biography or description
        bool isRegistered;       // Registration status of the artisan
    }

    // Mapping to store registered artisans by their address
    mapping(address => Artisan) private artisans;

    // Event emitted when a new artisan is registered
    event ArtisanRegistered(address indexed artisanAddress, string name, string contactInfo);

    // Event emitted when artisan details are updated
    event ArtisanUpdated(address indexed artisanAddress, string name, string contactInfo);

    // Modifier to check if an artisan is registered
    modifier onlyRegisteredArtisan() {
        require(artisans[msg.sender].isRegistered, "Caller is not a registered artisan");
        _;
    }

    // Function to register a new artisan
    function registerArtisan(
        string memory name,
        string memory contactInfo,
        string memory bio
    ) public {
        require(!artisans[msg.sender].isRegistered, "Artisan is already registered");

        artisans[msg.sender] = Artisan({
            artisanAddress: msg.sender,
            name: name,
            contactInfo: contactInfo,
            bio: bio,
            isRegistered: true
        });

        emit ArtisanRegistered(msg.sender, name, contactInfo);
    }

    // Function to update artisan details
    function updateArtisanDetails(
        string memory name,
        string memory contactInfo,
        string memory bio
    ) public onlyRegisteredArtisan {
        Artisan storage artisan = artisans[msg.sender];
        artisan.name = name;
        artisan.contactInfo = contactInfo;
        artisan.bio = bio;

        emit ArtisanUpdated(msg.sender, name, contactInfo);
    }

    // Function to retrieve artisan details
    function getArtisan(address artisanAddress)
        public
        view
        returns (string memory name, string memory contactInfo, string memory bio, bool isRegistered)
    {
        Artisan memory artisan = artisans[artisanAddress];
        return (artisan.name, artisan.contactInfo, artisan.bio, artisan.isRegistered);
    }

    // Function to check if an address is a registered artisan
    function isArtisan(address artisanAddress) public view returns (bool) {
        return artisans[artisanAddress].isRegistered;
    }
}

