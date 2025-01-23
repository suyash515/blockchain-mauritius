// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DisputeResolution {
    enum DisputeStatus { Open, Resolved, Rejected }

    struct Dispute {
        uint256 disputeId;
        address complainant;
        address respondent;
        string description;
        DisputeStatus status;
        uint256 timestamp;
        string resolutionDetails;
    }

    mapping(uint256 => Dispute) public disputes;
    uint256 public disputeCounter;
    address public admin;

    event DisputeFiled(
        uint256 indexed disputeId,
        address indexed complainant,
        address indexed respondent,
        string description,
        uint256 timestamp
    );

    event DisputeResolved(
        uint256 indexed disputeId,
        string resolutionDetails,
        uint256 timestamp
    );

    event DisputeRejected(
        uint256 indexed disputeId,
        string resolutionDetails,
        uint256 timestamp
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
        disputeCounter = 0;
    }

    function fileDispute(
        address _respondent,
        string memory _description
    ) public {
        require(_respondent != address(0), "Invalid respondent address");

        disputeCounter++;
        disputes[disputeCounter] = Dispute({
            disputeId: disputeCounter,
            complainant: msg.sender,
            respondent: _respondent,
            description: _description,
            status: DisputeStatus.Open,
            timestamp: block.timestamp,
            resolutionDetails: ""
        });

        emit DisputeFiled(disputeCounter, msg.sender, _respondent, _description, block.timestamp);
    }

    function resolveDispute(
        uint256 _disputeId,
        string memory _resolutionDetails
    ) public onlyAdmin {
        require(disputes[_disputeId].status == DisputeStatus.Open, "Dispute is not open");

        disputes[_disputeId].status = DisputeStatus.Resolved;
        disputes[_disputeId].resolutionDetails = _resolutionDetails;

        emit DisputeResolved(_disputeId, _resolutionDetails, block.timestamp);
    }

    function rejectDispute(
        uint256 _disputeId,
        string memory _resolutionDetails
    ) public onlyAdmin {
        require(disputes[_disputeId].status == DisputeStatus.Open, "Dispute is not open");

        disputes[_disputeId].status = DisputeStatus.Rejected;
        disputes[_disputeId].resolutionDetails = _resolutionDetails;

        emit DisputeRejected(_disputeId, _resolutionDetails, block.timestamp);
    }

    function getDispute(uint256 _disputeId) public view returns (Dispute memory) {
        return disputes[_disputeId];
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
}
