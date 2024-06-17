// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidderBidCount;
    mapping(address => mapping(uint => uint)) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Auction runs for 1 hour
    }
    
    function placeBid(uint bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == bidAmount, "Sent Ether amount must match bid amount");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address allowed");
        require(bidAmount >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        
        highestBidder = msg.sender;
        highestBid = bidAmount;
        bidderBidCount[msg.sender]++;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = bidAmount;
        
        emit NewHighestBid(msg.sender, bidAmount);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid placed within last 5 minutes
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}