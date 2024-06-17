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
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    function placeBid(uint bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(bidAmount > highestBid, "Bid amount must be higher than current highest bid");
        require((bidAmount * 100) / highestBid >= 105, "Bid must be at least 5% higher than current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        if (block.timestamp + 5 minutes > auctionEndTime) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid placed within last 5 minutes
        }
        
        bidderBidCount[msg.sender]++;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = bidAmount;
        
        highestBid = bidAmount;
        highestBidder = msg.sender;
        
        emit NewHighestBid(msg.sender, bidAmount);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer highest bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}