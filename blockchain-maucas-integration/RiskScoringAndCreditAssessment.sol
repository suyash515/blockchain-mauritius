// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RiskScoringAndCreditAssessment {
    // Events
    event RiskScoreAssigned(address indexed user, uint256 score, uint256 timestamp);
    event CreditAssessmentRequested(address indexed user, uint256 amount, uint256 timestamp);
    event CreditDecision(address indexed user, uint256 amount, bool approved, string reason, uint256 timestamp);

    // Struct for storing user financial data
    struct FinancialData {
        uint256 totalLoans;
        uint256 totalRepaid;
        uint256 overduePayments;
        bool exists;
    }

    // Struct for credit assessment requests
    struct CreditRequest {
        address user;
        uint256 amount;
        uint256 timestamp;
    }

    // Mapping for user financial data
    mapping(address => FinancialData) public financialData;

    // Mapping for risk scores
    mapping(address => uint256) public riskScores;

    // Modifier to ensure user exists
    modifier userExists(address user) {
        require(financialData[user].exists, "User financial data does not exist");
        _;
    }

    // Function to update or add financial data for a user
    function updateFinancialData(
        address user,
        uint256 totalLoans,
        uint256 totalRepaid,
        uint256 overduePayments
    ) external {
        require(user != address(0), "Invalid user address");

        financialData[user] = FinancialData({
            totalLoans: totalLoans,
            totalRepaid: totalRepaid,
            overduePayments: overduePayments,
            exists: true
        });

        // Automatically calculate and assign a risk score
        uint256 score = calculateRiskScore(totalLoans, totalRepaid, overduePayments);
        riskScores[user] = score;

        emit RiskScoreAssigned(user, score, block.timestamp);
    }

    // Function to calculate risk score
    function calculateRiskScore(
        uint256 totalLoans,
        uint256 totalRepaid,
        uint256 overduePayments
    ) internal pure returns (uint256) {
        if (totalLoans == 0) {
            return 0; // No loans, no risk
        }

        uint256 repaymentRatio = (totalRepaid * 100) / totalLoans;
        uint256 overduePenalty = overduePayments * 10; // Arbitrary penalty per overdue payment

        // Risk score is inversely proportional to repayment ratio and penalized by overdue payments
        uint256 score = 100 - repaymentRatio - overduePenalty;
        return score > 0 ? score : 0; // Ensure score is not negative
    }

    // Function to request a credit assessment
    function requestCreditAssessment(uint256 amount) external userExists(msg.sender) {
        require(amount > 0, "Credit amount must be greater than zero");

        emit CreditAssessmentRequested(msg.sender, amount, block.timestamp);

        // Perform automatic credit decision
        uint256 riskScore = riskScores[msg.sender];
        if (riskScore <= 50) {
            emit CreditDecision(msg.sender, amount, true, "Credit approved", block.timestamp);
        } else {
            emit CreditDecision(msg.sender, amount, false, "Credit denied due to high risk score", block.timestamp);
        }
    }

    // Function to view financial data for a user
    function getFinancialData(address user)
        external
        view
        returns (uint256 totalLoans, uint256 totalRepaid, uint256 overduePayments, uint256 riskScore)
    {
        FinancialData memory data = financialData[user];
        return (data.totalLoans, data.totalRepaid, data.overduePayments, riskScores[user]);
    }
}
