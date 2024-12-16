// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CommunicationAndNotification {
    // Struct to represent a message
    struct Message {
        uint256 id;
        address sender;
        address recipient;
        string content;
        uint256 timestamp;
        bool isRead;
    }

    // Mapping to store messages for each user
    mapping(address => Message[]) private userMessages;

    // Counter to generate unique message IDs
    uint256 private messageIdCounter;

    // Events
    event MessageSent(uint256 indexed id, address indexed sender, address indexed recipient, string content);
    event MessageRead(uint256 indexed id, address indexed recipient);

    // Function to send a message
    function sendMessage(address _recipient, string calldata _content) external {
        require(_recipient != address(0), "Recipient address cannot be zero");
        require(bytes(_content).length > 0, "Message content cannot be empty");

        uint256 newId = ++messageIdCounter;

        userMessages[_recipient].push(Message({
            id: newId,
            sender: msg.sender,
            recipient: _recipient,
            content: _content,
            timestamp: block.timestamp,
            isRead: false
        }));

        emit MessageSent(newId, msg.sender, _recipient, _content);
    }

    // Function to retrieve all messages for the caller
    function getMessages() external view returns (Message[] memory) {
        return userMessages[msg.sender];
    }

    // Function to mark a message as read
    function markAsRead(uint256 _messageId) external {
        Message[] storage messages = userMessages[msg.sender];
        bool found = false;

        for (uint256 i = 0; i < messages.length; i++) {
            if (messages[i].id == _messageId) {
                require(!messages[i].isRead, "Message is already marked as read");
                messages[i].isRead = true;
                emit MessageRead(_messageId, msg.sender);
                found = true;
                break;
            }
        }

        require(found, "Message not found");
    }
}
