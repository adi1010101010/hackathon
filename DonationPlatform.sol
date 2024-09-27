// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DonationPlatform {
    address public owner;
    mapping(address => uint256) public donations;

    uint256 private constant MAX_DONATION_PER_PERSON = 100 * 1 ether;
    uint256 private constant MAX_TOTAL_DONATIONS = 1_000 * 1 ether;
    uint256 public totalDonations;

    uint256 public donationStartTime;
    uint256 public donationEndTime;
    uint256 public withdrawalStartTime;
    uint256 public withdrawalEndTime;

    bool public donationActive;
    bool public withdrawalActive;

    event DonationReceived(address indexed donor, uint256 amount);
    event Withdrawal(address indexed owner, uint256 amount);
    event DonationStarted(uint256 startTime, uint256 endTime);
    event DonationEnded(uint256 endTime);
    event WithdrawalStarted(uint256 startTime, uint256 endTime);
    event WithdrawalEnded(uint256 endTime);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier duringDonationPeriod() {
        require(donationActive, "Donation period is not active");
        require(block.timestamp >= donationStartTime, "Donation period has not started");
        require(block.timestamp <= donationEndTime, "Donation period has ended");
        _;
    }

    modifier duringWithdrawalPeriod() {
        require(withdrawalActive, "Withdrawal period is not active");
        require(block.timestamp >= withdrawalStartTime, "Withdrawal period has not started");
        require(block.timestamp <= withdrawalEndTime, "Withdrawal period has ended");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Manually start the donation period
    function startDonation(uint256 durationInSeconds) public onlyOwner {
        require(!donationActive, "Donation period is already active");
        donationStartTime = block.timestamp;
        donationEndTime = block.timestamp + durationInSeconds;
        donationActive = true;
        emit DonationStarted(donationStartTime, donationEndTime);
    }

    // Manually end the donation period
    function endDonation() public onlyOwner {
        require(donationActive, "Donation period is not active");
        donationEndTime = block.timestamp;
        donationActive = false;
        emit DonationEnded(donationEndTime);
    }

    // Manually start the withdrawal period
    function startWithdrawal(uint256 durationInSeconds) public onlyOwner {
        require(!withdrawalActive, "Withdrawal period is already active");
        require(!donationActive, "Donation period is still active");
        withdrawalStartTime = block.timestamp;
        withdrawalEndTime = block.timestamp + durationInSeconds;
        withdrawalActive = true;
        emit WithdrawalStarted(withdrawalStartTime, withdrawalEndTime);
    }

    // Manually end the withdrawal period
    function endWithdrawal() public onlyOwner {
        require(withdrawalActive, "Withdrawal period is not active");
        withdrawalEndTime = block.timestamp;
        withdrawalActive = false;
        emit WithdrawalEnded(withdrawalEndTime);
    }

    // Donate function
    function donate() public payable duringDonationPeriod {
        require(msg.value > 0, "Donation must be greater than 0");
        require(donations[msg.sender] + msg.value <= MAX_DONATION_PER_PERSON, "Donation exceeds limit");
        require(totalDonations + msg.value <= MAX_TOTAL_DONATIONS, "Total donations exceed limit");

        donations[msg.sender] += msg.value;
        totalDonations += msg.value;
        emit DonationReceived(msg.sender, msg.value);
    }

    // Withdraw function
    function withdraw() public onlyOwner duringWithdrawalPeriod {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to withdraw");

        (bool success, ) = owner.call{value: contractBalance}("");
        require(success, "Withdrawal failed");

        emit Withdrawal(owner, contractBalance);
    }

    // Fallback function to accept ETH sent to the contract
    receive() external payable {}
}
