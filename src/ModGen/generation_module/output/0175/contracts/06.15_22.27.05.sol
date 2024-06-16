```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketToken;
    
    mapping(address => uint) public bidderBids;
    mapping(address => uint) public bidderBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketToken, uint _auctionDuration) {
        organizer = msg.sender;
        ticketToken = _ticketToken;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        
        if (block.timestamp > auctionEndTime - 300) {
            // Extend auction by 10 minutes if new bid in last 5 minutes
            auctionEndTime += 600;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        bidderBids[msg.sender] = msg.value;
        bidderBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(highestBid > 0, "No bids have been placed");
        
        payable(organizer).transfer(highestBid);
    }
}
```