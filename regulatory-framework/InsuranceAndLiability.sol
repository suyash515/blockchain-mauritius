// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InsuranceAndLiability {
    address public admin;

    struct Policy {
        address insured;
        uint256 coverageAmount;
        uint256 premium;
        uint256 startDate;
        uint256 endDate;
        bool isActive;
        bool isClaimed;
    }

    struct Claim {
        address claimant;
        uint256 policyId;
        uint256 claimAmount;
        string claimReason;
        bool isApproved;
        bool isPaid;
    }

    uint256 public policyCount;
    uint256 public claimCount;

    mapping(uint256 => Policy) public policies;
    mapping(uint256 => Claim) public claims;
    mapping(address => uint256[]) public userPolicies;

    event PolicyCreated(uint256 indexed policyId, address indexed insured, uint256 coverageAmount, uint256 premium, uint256 startDate, uint256 endDate);
    event ClaimSubmitted(uint256 indexed claimId, address indexed claimant, uint256 policyId, uint256 claimAmount, string claimReason);
    event ClaimApproved(uint256 indexed claimId, uint256 claimAmount);
    event ClaimRejected(uint256 indexed claimId, string reason);
    event ClaimPaid(uint256 indexed claimId, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createPolicy(
        address insured,
        uint256 coverageAmount,
        uint256 premium,
        uint256 duration
    ) external onlyAdmin {
        require(insured != address(0), "Invalid insured address");
        require(coverageAmount > 0, "Coverage amount must be greater than zero");
        require(premium > 0, "Premium must be greater than zero");
        require(duration > 0, "Duration must be greater than zero");

        policies[policyCount] = Policy({
            insured: insured,
            coverageAmount: coverageAmount,
            premium: premium,
            startDate: block.timestamp,
            endDate: block.timestamp + duration,
            isActive: true,
            isClaimed: false
        });

        userPolicies[insured].push(policyCount);

        emit PolicyCreated(policyCount, insured, coverageAmount, premium, block.timestamp, block.timestamp + duration);
        policyCount++;
    }

    function submitClaim(uint256 policyId, uint256 claimAmount, string calldata claimReason) external {
        Policy storage policy = policies[policyId];
        require(policy.insured == msg.sender, "Only the insured can submit a claim");
        require(policy.isActive, "Policy is not active");
        require(!policy.isClaimed, "Policy claim already processed");
        require(claimAmount <= policy.coverageAmount, "Claim amount exceeds coverage");

        claims[claimCount] = Claim({
            claimant: msg.sender,
            policyId: policyId,
            claimAmount: claimAmount,
            claimReason: claimReason,
            isApproved: false,
            isPaid: false
        });

        emit ClaimSubmitted(claimCount, msg.sender, policyId, claimAmount, claimReason);
        claimCount++;
    }

    function approveClaim(uint256 claimId) external onlyAdmin {
        Claim storage claim = claims[claimId];
        require(!claim.isApproved, "Claim already approved");
        require(!claim.isPaid, "Claim already paid");

        Policy storage policy = policies[claim.policyId];
        require(policy.isActive, "Policy is not active");

        claim.isApproved = true;
        policy.isClaimed = true;

        emit ClaimApproved(claimId, claim.claimAmount);
    }

    function rejectClaim(uint256 claimId, string calldata reason) external onlyAdmin {
        Claim storage claim = claims[claimId];
        require(!claim.isApproved, "Claim already approved");
        require(!claim.isPaid, "Claim already paid");

        emit ClaimRejected(claimId, reason);
    }

    function payClaim(uint256 claimId) external onlyAdmin {
        Claim storage claim = claims[claimId];
        require(claim.isApproved, "Claim is not approved");
        require(!claim.isPaid, "Claim already paid");

        Policy storage policy = policies[claim.policyId];
        require(policy.isActive, "Policy is not active");

        claim.isPaid = true;
        payable(claim.claimant).transfer(claim.claimAmount);

        emit ClaimPaid(claimId, claim.claimAmount);
    }

    function updateAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        admin = newAdmin;
    }

    receive() external payable {}
}

