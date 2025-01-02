// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PublicServiceFeedback {
    struct Feedback {
        address user;
        string serviceId;
        string feedbackText;
        uint256 timestamp;
        bool anonymous;
    }

    Feedback[] private feedbacks;
    mapping(string => uint256[]) private serviceFeedback; // Maps serviceId to feedback indexes

    event FeedbackSubmitted(address indexed user, string serviceId, uint256 feedbackIndex, uint256 timestamp);

    // Submit feedback
    function submitFeedback(string memory _serviceId, string memory _feedbackText, bool _anonymous) public {
        require(bytes(_serviceId).length > 0, "Service ID cannot be empty");
        require(bytes(_feedbackText).length > 0, "Feedback cannot be empty");

        Feedback memory newFeedback = Feedback({
            user: _anonymous ? address(0) : msg.sender,
            serviceId: _serviceId,
            feedbackText: _feedbackText,
            timestamp: block.timestamp,
            anonymous: _anonymous
        });

        feedbacks.push(newFeedback);
        uint256 feedbackIndex = feedbacks.length - 1;
        serviceFeedback[_serviceId].push(feedbackIndex);

        emit FeedbackSubmitted(msg.sender, _serviceId, feedbackIndex, block.timestamp);
    }

    // Get feedback for a specific service
    function getServiceFeedback(string memory _serviceId) public view returns (Feedback[] memory) {
        uint256[] memory indexes = serviceFeedback[_serviceId];
        Feedback[] memory serviceFeedbacks = new Feedback[](indexes.length);

        for (uint256 i = 0; i < indexes.length; i++) {
            serviceFeedbacks[i] = feedbacks[indexes[i]];
        }

        return serviceFeedbacks;
    }

    // Get all feedbacks
    function getAllFeedbacks() public view returns (Feedback[] memory) {
        return feedbacks;
    }
}
