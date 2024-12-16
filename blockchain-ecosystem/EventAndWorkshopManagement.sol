// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventAndWorkshopManagement {
    // Struct to represent an event or workshop
    struct Event {
        uint256 id;
        string name;
        string description;
        address organizer;
        uint256 date; // Timestamp of the event
        uint256 capacity;
        uint256 registeredCount;
        address[] participants;
        bool isActive;
    }

    // Mapping to store events by ID
    mapping(uint256 => Event) public events;

    // Counter to generate unique event IDs
    uint256 private eventIdCounter;

    // Events
    event EventCreated(uint256 indexed id, string name, address indexed organizer, uint256 date, uint256 capacity);
    event ParticipantRegistered(uint256 indexed eventId, address indexed participant);
    event ParticipantRemoved(uint256 indexed eventId, address indexed participant);
    event EventCancelled(uint256 indexed id);

    // Modifier to check if an event exists
    modifier eventExists(uint256 _eventId) {
        require(events[_eventId].organizer != address(0), "Event does not exist");
        _;
    }

    // Modifier to ensure only the organizer can manage the event
    modifier onlyOrganizer(uint256 _eventId) {
        require(msg.sender == events[_eventId].organizer, "Only the organizer can perform this action");
        _;
    }

    // Modifier to ensure the event is active
    modifier isActive(uint256 _eventId) {
        require(events[_eventId].isActive, "Event is not active");
        _;
    }

    // Function to create a new event or workshop
    function createEvent(
        string calldata _name,
        string calldata _description,
        uint256 _date,
        uint256 _capacity
    ) external returns (uint256) {
        require(bytes(_name).length > 0, "Event name cannot be empty");
        require(bytes(_description).length > 0, "Event description cannot be empty");
        require(_date > block.timestamp, "Event date must be in the future");
        require(_capacity > 0, "Event capacity must be greater than zero");

        uint256 newId = ++eventIdCounter;

        events[newId] = Event({
            id: newId,
            name: _name,
            description: _description,
            organizer: msg.sender,
            date: _date,
            capacity: _capacity,
            registeredCount: 0,
            participants: new address          isActive: true
        });

        emit EventCreated(newId, _name, msg.sender, _date, _capacity);
        return newId;
    }

    // Function to register a participant for an event
    function registerParticipant(uint256 _eventId) external eventExists(_eventId) isActive(_eventId) {
        Event storage eventDetails = events[_eventId];
        require(eventDetails.date > block.timestamp, "Event has already taken place");
        require(eventDetails.registeredCount < eventDetails.capacity, "Event is fully booked");

        for (uint256 i = 0; i < eventDetails.participants.length; i++) {
            require(eventDetails.participants[i] != msg.sender, "You are already registered for this event");
        }

        eventDetails.participants.push(msg.sender);
        eventDetails.registeredCount++;

        emit ParticipantRegistered(_eventId, msg.sender);
    }

    // Function to remove a participant from an event
    function removeParticipant(uint256 _eventId, address _participant)
        external
        eventExists(_eventId)
        onlyOrganizer(_eventId)
    {
        Event storage eventDetails = events[_eventId];
        bool found = false;

        for (uint256 i = 0; i < eventDetails.participants.length; i++) {
            if (eventDetails.participants[i] == _participant) {
                eventDetails.participants[i] = eventDetails.participants[eventDetails.participants.length - 1];
                eventDetails.participants.pop();
                eventDetails.registeredCount--;
                found = true;
                break;
            }
        }

        require(found, "Participant not found in this event");
        emit ParticipantRemoved(_eventId, _participant);
    }

    // Function to cancel an event
    function cancelEvent(uint256 _eventId) external eventExists(_eventId) onlyOrganizer(_eventId) {
        Event storage eventDetails = events[_eventId];
        require(eventDetails.isActive, "Event is already cancelled");

        eventDetails.isActive = false;

        emit EventCancelled(_eventId);
    }

    // Function to get details of an event
    function getEventDetails(uint256 _eventId)
        external
        view
        eventExists(_eventId)
        returns (
            string memory name,
            string memory description,
            address organizer,
            uint256 date,
            uint256 capacity,
            uint256 registeredCount,
            bool isActive,
            address[] memory participants
        )
    {
        Event memory eventDetails = events[_eventId];
        return (
            eventDetails.name,
            eventDetails.description,
            eventDetails.organizer,
            eventDetails.date,
            eventDetails.capacity,
            eventDetails.registeredCount,
            eventDetails.isActive,
            eventDetails.participants
        );
    }
}
