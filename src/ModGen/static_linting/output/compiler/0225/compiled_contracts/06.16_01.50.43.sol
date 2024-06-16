// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidderBidCount;
    bool public auctionEnded;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has already ended");
        _;
    }

    function placeBid() external payable auctionNotEnded {
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than the current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Each address can place a maximum of 3 bids");
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        bidderBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid placed within last 5 minutes
        }
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }

    function endAuction() external onlyOrganizer {
        require(!auctionEnded, "Auction has already ended");
        
        auctionEnded = true;
        auctionEndTime = block.timestamp;
    }
}