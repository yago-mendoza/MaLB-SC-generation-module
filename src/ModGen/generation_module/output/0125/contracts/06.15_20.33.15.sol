```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public minBidIncrease;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public minTokensRequired;
    uint public totalTokens;
    
    mapping(address => uint) public bidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _extensionDuration, uint _minTokensRequired, uint _bidIncrementPercentage) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        bidIncrementPercentage = _bidIncrementPercentage;
        minBidIncrease = 100 + _bidIncrementPercentage;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        minTokensRequired = _minTokensRequired;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    modifier onlyBeforeEnd() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }
    
    function placeBid() external payable onlyBeforeEnd {
        require(msg.value >= minTokensRequired, "Minimum token requirement not met");
        require(bidCount[msg.sender] < 3, "Maximum bids reached");
        
        uint newBid = msg.value;
        require(newBid >= highestBid * minBidIncrease / 100, "Bid amount too low");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        highestBid = newBid;
        highestBidder = msg.sender;
        bidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, newBid);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}
```