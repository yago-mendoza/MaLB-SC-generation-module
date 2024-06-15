```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrement;
    uint public minBidAmount;
    uint public auctionDuration = 30 minutes;
    uint public bufferDuration = 5 minutes;
    bool public auctionEnded;
    
    mapping(address => uint) public bidsByAddress;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _bidIncrement, uint _minBidAmount) {
        organizer = msg.sender;
        bidIncrement = _bidIncrement;
        minBidAmount = _minBidAmount;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= minBidAmount, "Bid amount too low");
        require(msg.value >= highestBid + bidIncrement, "Bid amount must be at least bidIncrement higher than current highest bid");
        require(bidsByAddress[msg.sender] < 3, "Maximum 3 bids per address");
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
            
            if (auctionEndTime - block.timestamp < bufferDuration) {
                auctionEndTime = block.timestamp + bufferDuration;
            }
        }
        
        bidsByAddress[msg.sender]++;
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction is not over yet");
        
        (bool success, ) = organizer.call{value: highestBid}("");
        require(success, "Transfer failed");
    }
    
    function endAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        
        auctionEnded = true;
    }
}
```