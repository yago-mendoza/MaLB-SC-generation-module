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
    uint public auctionDuration = 30 minutes;
    uint public extensionDuration = 10 minutes;
    bool public auctionEnded;
    
    mapping(address => uint) public bidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _bidIncrementPercentage, uint _minBidIncrease) {
        organizer = msg.sender;
        bidIncrementPercentage = _bidIncrementPercentage;
        minBidIncrease = _minBidIncrease;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has ended");
        _;
    }
    
    function placeBid() external payable auctionNotEnded {
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(msg.value >= highestBid + (highestBid * minBidIncrease / 100), "Bid must be at least 5% higher than the current highest bid");
        require(bidCount[msg.sender] < 3, "Maximum 3 bids per address allowed");
        
        if (block.timestamp + 5 minutes >= auctionEndTime) {
            auctionEndTime += extensionDuration;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        bidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer auctionEnded {
        payable(organizer).transfer(highestBid);
    }
    
    function endAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        
        auctionEnded = true;
    }
}
```