// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReputationAndFeedback {
    // Struct to represent a stakeholder's reputation and feedback
    struct Reputation {
        uint256 score;
        string[] feedback;
    }

    // Mapping to store reputation data for each stakeholder
    mapping(address => Reputation) public reputations;

    // Events
    event FeedbackGiven(address indexed stakeholder, string feedback);
    event ReputationUpdated(address indexed stakeholder, uint256 newScore);

    // Modifier to ensure feedback is non-empty
    modifier validFeedback(string calldata _feedback) {
        require(bytes(_feedback).length > 0, "Feedback cannot be empty");
        _;
    }

    // Function to give feedback to a stakeholder
    function giveFeedback(address _stakeholder, string calldata _feedback)
        external
        validFeedback(_feedback)
    {
        reputations[_stakeholder].feedback.push(_feedback);
        emit FeedbackGiven(_stakeholder, _feedback);
    }

    // Function to update a stakeholder's reputation score
    function updateReputation(address _stakeholder, uint256 _newScore) external {
        require(_newScore <= 100, "Score must be between 0 and 100");
        reputations[_stakeholder].score = _newScore;
        emit ReputationUpdated(_stakeholder, _newScore);
    }

    // Function to retrieve feedback for a stakeholder
    function getFeedback(address _stakeholder) external view returns (string[] memory) {
        return reputations[_stakeholder].feedback;
    }

    // Function to retrieve the reputation score of a stakeholder
    function getReputationScore(address _stakeholder) external view returns (uint256) {
        return reputations[_stakeholder].score;
    }
}
