// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketToken;
    uint public bidIncrementPercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public totalBids;
    
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketToken, uint _bidIncrementPercentage, uint _auctionDuration, uint _extensionDuration) {
        organizer = msg.sender;
        ticketToken = _ticketToken;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require((msg.value * 100) >= (highestBid * (100 + bidIncrementPercentage)), "Bid must be at least 5% higher than current highest bid");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        totalBids++;
        addressBidCount[msg.sender]++;
        highestBid = msg.value;
        highestBidder = msg.sender;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += extensionDuration;
        }
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}