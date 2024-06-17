// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage = 5;
    uint public minBidAmount;
    uint public auctionDuration = 30 minutes;
    uint public lastBidTime;
    
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _minBidAmount) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidAmount = _minBidAmount;
        auctionEndTime = block.timestamp + auctionDuration;
        highestBid = 0;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= minBidAmount, "Bid amount too low");
        require(msg.value >= highestBid + (highestBid * minBidIncreasePercentage) / 100, "Bid not high enough");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }
        
        addressBidCount[msg.sender]++;
        highestBid = msg.value;
        highestBidder = msg.sender;
        lastBidTime = block.timestamp;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}