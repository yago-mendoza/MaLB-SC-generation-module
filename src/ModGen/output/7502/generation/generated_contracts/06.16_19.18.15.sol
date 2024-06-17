// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidCounts;
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
        require(_bidAmount > highestBid, "Bid amount must be higher than the current highest bid");
        require(_bidAmount >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than the current highest bid");
        require(bidCounts[msg.sender] < 3, "Maximum of 3 bids per address reached");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid placed within last 5 minutes
        }

        highestBid = _bidAmount;
        highestBidder = msg.sender;
        bidCounts[msg.sender]++;
        bids[msg.sender][bidCounts[msg.sender]] = _bidAmount;

        emit NewHighestBid(msg.sender, _bidAmount);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        // Transfer the highest bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}