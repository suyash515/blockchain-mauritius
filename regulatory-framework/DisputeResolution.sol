// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DisputeResolution {
    address public arbitrator;

    enum DisputeStatus { Pending, Resolved, Rejected }

    struct Dispute {
        address claimant;
        address respondent;
        string details;
        uint256 amountInEscrow;
        DisputeStatus status;
    }

    uint256 public disputeCount;
    mapping(uint256 => Dispute) public disputes;
    mapping(uint256 => address) public escrow;

    event DisputeFiled(uint256 indexed disputeId, address indexed claimant, address indexed respondent, string details, uint256 amount);
    event DisputeResolved(uint256 indexed disputeId, address winner);
    event DisputeRejected(uint256 indexed disputeId);

    modifier onlyArbitrator() {
        require(msg.sender == arbitrator, "Only the arbitrator can perform this action");
        _;
    }

    constructor(address _arbitrator) {
        require(_arbitrator != address(0), "Invalid arbitrator address");
        arbitrator = _arbitrator;
    }

    function fileDispute(address respondent, string calldata details) external payable {
        require(msg.value > 0, "Escrow amount must be greater than zero");

        disputes[disputeCount] = Dispute({
            claimant: msg.sender,
            respondent: respondent,
            details: details,
            amountInEscrow: msg.value,
            status: DisputeStatus.Pending
        });

        escrow[disputeCount] = address(this);
        emit DisputeFiled(disputeCount, msg.sender, respondent, details, msg.value);
        disputeCount++;
    }

    function resolveDispute(uint256 disputeId, address winner) external onlyArbitrator {
        Dispute storage dispute = disputes[disputeId];
        require(dispute.status == DisputeStatus.Pending, "Dispute is not pending");
        require(winner == dispute.claimant || winner == dispute.respondent, "Winner must be a party to the dispute");

        dispute.status = DisputeStatus.Resolved;
        payable(winner).transfer(dispute.amountInEscrow);
        emit DisputeResolved(disputeId, winner);
    }

    function rejectDispute(uint256 disputeId) external onlyArbitrator {
        Dispute storage dispute = disputes[disputeId];
        require(dispute.status == DisputeStatus.Pending, "Dispute is not pending");

        dispute.status = DisputeStatus.Rejected;
        payable(dispute.claimant).transfer(dispute.amountInEscrow);
        emit DisputeRejected(disputeId);
    }

    function updateArbitrator(address newArbitrator) external onlyArbitrator {
        require(newArbitrator != address(0), "Invalid arbitrator address");
        arbitrator = newArbitrator;
    }

    function getDispute(uint256 disputeId) external view returns (Dispute memory) {
        return disputes[disputeId];
    }
}

