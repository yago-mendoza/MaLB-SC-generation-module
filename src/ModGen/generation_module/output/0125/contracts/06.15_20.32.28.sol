```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _biddingTime) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _biddingTime;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher");
        require(msg.value >= highestBid * 105 / 100, "Bid must be at least 5% higher");
        require(bidCount[msg.sender] < 3, "Maximum 3 bids per address");
        
        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        bidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}
```