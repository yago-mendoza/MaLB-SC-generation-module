// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    
    mapping(address => uint) public bidderBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address allowed");
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
            
            // Reset bid count if a new highest bid is placed
            bidderBidCount[msg.sender] = 1;
        } else {
            bidderBidCount[msg.sender]++;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer the winning bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}