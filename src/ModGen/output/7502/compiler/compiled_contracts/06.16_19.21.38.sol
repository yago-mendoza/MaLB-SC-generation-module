// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint constant maxBidsPerAddress = 3;
    uint constant minBidIncreasePercentage = 5;
    bool auctionEnded;
    
    event NewHighestBid(address bidder, uint amount);
    
    mapping(address => uint) public numBidsByAddress;
    
    constructor(uint _ticketTokenId, uint _auctionDurationMinutes) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        auctionEndTime = block.timestamp + _auctionDurationMinutes * 1 minutes;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require((msg.value * 100) / highestBid >= minBidIncreasePercentage, "Bid amount must be at least 5% higher than current highest bid");
        require(numBidsByAddress[msg.sender] < maxBidsPerAddress, "Maximum number of bids reached");
        
        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }
        
        numBidsByAddress[msg.sender]++;
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        require(auctionEnded, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
    
    function endAuction() external {
        require(msg.sender == organizer, "Only the organizer can end the auction");
        require(block.timestamp >= auctionEndTime, "Auction time not yet reached");
        
        auctionEnded = true;
    }
}