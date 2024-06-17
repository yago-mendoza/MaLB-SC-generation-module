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
        auctionEndTime = block.timestamp + 1 hours; // 1 hour auction duration
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid(uint amount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == amount, "Sent value must match bid amount");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        require(amount >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        
        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid placed in last 5 minutes
        }
        
        highestBid = amount;
        highestBidder = msg.sender;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = amount;
        bidderBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, amount);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}