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
    uint public lastBidTime;
    
    mapping(address => uint) public bidsCount;
    
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
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid + minBidIncrease, "Bid amount must be at least 5% higher than current highest bid");
        require(bidsCount[msg.sender] < 3, "Maximum 3 bids per address allowed");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        bidsCount[msg.sender]++;
        lastBidTime = block.timestamp;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}
```  