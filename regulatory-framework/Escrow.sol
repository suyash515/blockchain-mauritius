// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    address public arbiter;
    address public depositor;
    address public beneficiary;

    uint256 public escrowBalance;
    bool public isReleased;

    event Deposit(address indexed depositor, uint256 amount);
    event Release(address indexed beneficiary, uint256 amount);
    event Refunded(address indexed depositor, uint256 amount);

    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only the arbiter can perform this action");
        _;
    }

    modifier fundsAvailable() {
        require(escrowBalance > 0, "No funds available in escrow");
        _;
    }

    constructor(address _arbiter, address _beneficiary) {
        require(_arbiter != address(0), "Invalid arbiter address");
        require(_beneficiary != address(0), "Invalid beneficiary address");

        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositor = msg.sender;
    }

    function deposit() external payable {
        require(msg.sender == depositor, "Only the depositor can deposit funds");
        require(msg.value > 0, "Deposit amount must be greater than zero");

        escrowBalance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function releaseFunds() external onlyArbiter fundsAvailable {
        isReleased = true;
        uint256 amount = escrowBalance;
        escrowBalance = 0;

        payable(beneficiary).transfer(amount);
        emit Release(beneficiary, amount);
    }

    function refundFunds() external onlyArbiter fundsAvailable {
        uint256 amount = escrowBalance;
        escrowBalance = 0;

        payable(depositor).transfer(amount);
        emit Refunded(depositor, amount);
    }
}

