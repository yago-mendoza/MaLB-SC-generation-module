```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public auctionDuration = 30 minutes;
    uint public lastBidTime;
    bool public auctionEnded;
    
    mapping(address => uint) public addressToNumBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= (highestBid * minBidIncreasePercentage / 100) + highestBid, "Bid increase percentage not met");
        require(addressToNumBids[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        lastBidTime = block.timestamp;
        addressToNumBids[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdrawOrganizer() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
    
    function finalizeAuction() external {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(!auctionEnded, "Auction has already been finalized");
        
        auctionEnded = true;
    }
}
```