// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidCount;
    mapping(address => mapping(uint => uint)) public bids;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent ETH amount must match bid amount");

        require(bidCount[msg.sender] < 3, "Maximum 3 bids per address");
        require(_bidAmount >= highestBid * 105 / 100, "Bid must be at least 5% higher than the current highest bid");

        highestBid = _bidAmount;
        highestBidder = msg.sender;
        bidCount[msg.sender]++;
        bids[msg.sender][bidCount[msg.sender]] = _bidAmount;

        emit NewHighestBid(msg.sender, _bidAmount);

        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if new bid in last 5 minutes
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}