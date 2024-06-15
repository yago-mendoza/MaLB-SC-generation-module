```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidderBidCount;
    mapping(address => uint[]) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    modifier auctionNotEnded() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }
    
    function placeBid() external payable auctionNotEnded {
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address allowed");
        require(msg.value > highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        
        if (block.timestamp + 5 minutes > auctionEndTime) {
            auctionEndTime += 10 minutes;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        bidderBidCount[msg.sender]++;
        bidderBids[msg.sender].push(msg.value);
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}
```  