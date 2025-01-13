// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProcessingMilestoneContract {
    struct Milestone {
        string milestoneId;
        string productId;
        string description;
        string completedBy;
        string completionDate;
        bool isCompleted;
    }

    mapping(string => Milestone[]) private milestones;
    address public owner;

    event MilestoneAdded(
        string milestoneId,
        string productId,
        string description,
        string completedBy,
        string completionDate,
        bool isCompleted
    );

    event MilestoneCompleted(
        string milestoneId,
        string productId,
        string completionDate,
        string completedBy
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addMilestone(
        string memory _milestoneId,
        string memory _productId,
        string memory _description
    ) public onlyOwner {
        require(bytes(_milestoneId).length > 0, "Milestone ID cannot be empty.");
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(_description).length > 0, "Description cannot be empty.");

        Milestone memory newMilestone = Milestone(
            _milestoneId,
            _productId,
            _description,
            "",
            "",
            false
        );

        milestones[_productId].push(newMilestone);

        emit MilestoneAdded(
            _milestoneId,
            _productId,
            _description,
            "",
            "",
            false
        );
    }

    function completeMilestone(
        string memory _productId,
        string memory _milestoneId,
        string memory _completionDate,
        string memory _completedBy
    ) public onlyOwner {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        require(bytes(_milestoneId).length > 0, "Milestone ID cannot be empty.");
        require(bytes(_completionDate).length > 0, "Completion date cannot be empty.");
        require(bytes(_completedBy).length > 0, "Completed by cannot be empty.");

        Milestone[] storage productMilestones = milestones[_productId];
        bool milestoneFound = false;

        for (uint256 i = 0; i < productMilestones.length; i++) {
            if (
                keccak256(bytes(productMilestones[i].milestoneId)) ==
                keccak256(bytes(_milestoneId))
            ) {
                productMilestones[i].isCompleted = true;
                productMilestones[i].completionDate = _completionDate;
                productMilestones[i].completedBy = _completedBy;
                milestoneFound = true;

                emit MilestoneCompleted(
                    _milestoneId,
                    _productId,
                    _completionDate,
                    _completedBy
                );
                break;
            }
        }

        require(milestoneFound, "Milestone ID not found for the given product.");
    }

    function getMilestones(string memory _productId)
        public
        view
        returns (Milestone[] memory)
    {
        require(bytes(_productId).length > 0, "Product ID cannot be empty.");
        return milestones[_productId];
    }
}

