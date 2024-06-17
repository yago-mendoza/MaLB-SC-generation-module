// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public numBidsAllowed;
    uint public constant auctionDuration = 30 minutes;
    uint public constant auctionExtension = 10 minutes;
    uint public constant minTokensRequired = 10;
    
    mapping(address => uint) public numBidsByAddress;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _numBidsAllowed) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        numBidsAllowed = _numBidsAllowed;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= minTokensRequired, "Minimum of 10 tokens required to participate");
        require(numBidsByAddress[msg.sender] < numBidsAllowed, "Exceeded maximum number of bids");
        
        uint minBidAmount = highestBid + (highestBid * minBidIncreasePercentage) / 100;
        require(msg.value >= minBidAmount, "Bid amount must be at least 5% higher than current highest bid");
        
        numBidsByAddress[msg.sender]++;
        
        if (block.timestamp + 5 minutes > auctionEndTime) {
            auctionEndTime = block.timestamp + auctionExtension;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Perform transfer to organizer
        payable(organizer).transfer(highestBid);
    }
}