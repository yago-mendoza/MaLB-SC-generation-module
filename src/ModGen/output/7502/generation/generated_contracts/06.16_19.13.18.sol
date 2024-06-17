// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public numBidsPerAddress;
    uint public totalBids;
    bool public auctionEnded;
    
    mapping(address => uint) public numBidsByAddress;
    
    event NewHighestBid(address bidder, uint bidAmount);
    
    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _numBidsPerAddress, uint _auctionDurationMinutes) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        numBidsPerAddress = _numBidsPerAddress;
        auctionEndTime = block.timestamp + _auctionDurationMinutes * 1 minutes;
    }
    
    function placeBid() external payable {
        require(msg.value > highestBid && msg.value >= (highestBid * minBidIncreasePercentage) / 100, "Bid amount must be higher than current highest bid and meet minimum increase percentage");
        require(numBidsByAddress[msg.sender] < numBidsPerAddress, "Exceeded maximum number of bids per address");
        require(!auctionEnded, "Auction has ended");
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        numBidsByAddress[msg.sender]++;
        totalBids++;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid placed within last 5 minutes
        }
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        require(auctionEnded, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
    
    function endAuction() external {
        require(!auctionEnded, "Auction has already ended");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        auctionEnded = true;
    }
}