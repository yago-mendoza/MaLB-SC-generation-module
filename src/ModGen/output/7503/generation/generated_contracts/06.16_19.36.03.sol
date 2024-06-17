// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public auctionDuration = 60 minutes;
    uint public extensionDuration = 10 minutes;
    uint public minBidAmount = 10 ether;
    
    mapping(address => uint) public bidderBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _bidIncrementPercentage) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    function placeBid() external payable {
        require(msg.value >= minBidAmount, "Bid amount must be at least 10 ether");
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(bidderBidCount[msg.sender] < 3, "Maximum of 3 bids per address reached");
        
        uint minBidIncrement = (highestBid * bidIncrementPercentage) / 100;
        uint requiredBidAmount = highestBid + minBidIncrement;
        
        require(msg.value >= requiredBidAmount, "Bid amount must be at least 5% higher than current highest bid");
        
        if (block.timestamp + 5 minutes > auctionEndTime) {
            auctionEndTime += extensionDuration;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        bidderBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}