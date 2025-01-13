// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeedbackAndRatingContract {
    struct Feedback {
        string feedbackId;
        string productId;
        address customer;
        uint8 rating; // Rating from 1 to 5
        string comments;
        uint256 timestamp;
    }

    mapping(string => Feedback[]) private productFeedbacks;
    address public owner;

    event FeedbackSubmitted(
        string feedbackId,
        string productId,
        address customer,
        uint8 rating,
        string comments,
        uint256 timestamp
    );

    modifier onlyValidRating(uint8 _rating) {
        require(_rating >= 1 && _rating <= 5, "Rating must be between 1 and 5.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function submitFeedback(
        string memory _feedbackId,
        string memory _productId,
        uint8 _rating,
        string memory _comments
    ) public onlyValidRating(_rating) {
        require(bytes(_feedbackId).length > 0, "Feedback ID cannot be empty.");
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(_comments).length > 0, "Comments cannot be empty.");

        Feedback memory newFeedback = Feedback(
            _feedbackId,
            _productId,
            msg.sender,
            _rating,
            _comments,
            block.timestamp
        );

        productFeedbacks[_productId].push(newFeedback);

        emit FeedbackSubmitted(
            _feedbackId,
            _productId,
            msg.sender,
            _rating,
            _comments,
            block.timestamp
        );
    }

    function getProductFeedback(string memory _productId)
        public
        view
        returns (Feedback[] memory)
    {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        return productFeedbacks[_productId];
    }

    function getAverageRating(string memory _productId)
        public
        view
        returns (uint256)
    {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        Feedback[] memory feedbacks = productFeedbacks[_productId];
        require(feedbacks.length > 0, "No feedback available for this product.");

        uint256 totalRating = 0;
        for (uint256 i = 0; i < feedbacks.length; i++) {
            totalRating += feedbacks[i].rating;
        }

        return totalRating / feedbacks.length;
    }
}

