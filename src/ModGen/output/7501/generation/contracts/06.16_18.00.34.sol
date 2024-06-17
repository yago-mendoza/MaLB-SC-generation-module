// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public totalBids;
    uint constant public minBidIncreasePercentage = 5;
    uint constant public maxBidsPerAddress = 3;
    uint constant public auctionDuration = 30 minutes;
    uint constant public bidWithdrawalLockTime = 1 days;

    mapping(address => uint) public addressToBids;
    mapping(uint => address) public bidIndexToBidder;
    mapping(address => uint) public addressToWithdrawalTime;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }

    modifier onlyAfterAuction() {
        require(block.timestamp >= auctionEndTime, "Auction is still ongoing");
        _;
    }

    function placeBid() external payable onlyDuringAuction {
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require((msg.value * 100) / highestBid >= minBidIncreasePercentage, "Bid amount must be at least 5% higher than current highest bid");
        require(addressToBids[msg.sender] < maxBidsPerAddress, "Maximum bids per address reached");

        totalBids++;
        addressToBids[msg.sender]++;
        highestBid = msg.value;
        highestBidder = msg.sender;
        bidIndexToBidder[totalBids] = msg.sender;
        emit NewHighestBid(msg.sender, msg.value);

        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes;
        }
    }

    function withdrawOrganizerFunds() external onlyAfterAuction onlyOrganizer {
        address payable organizerPayable = payable(organizer);
        organizerPayable.transfer(highestBid);
    }

    function withdrawBidderFunds() external onlyAfterAuction {
        require(msg.sender != highestBidder, "Highest bidder cannot withdraw until auction end");
        require(addressToWithdrawalTime[msg.sender] == 0 || block.timestamp >= addressToWithdrawalTime[msg.sender], "Withdrawal locked for bidder");

        address payable bidderPayable = payable(msg.sender);
        bidderPayable.transfer(msg.value);
    }

    function lockWinningBid() external onlyAfterAuction {
        addressToWithdrawalTime[highestBidder] = block.timestamp + bidWithdrawalLockTime;
    }
}