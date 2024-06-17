// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public auctionExtensionTime;
    
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _auctionExtensionTime) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionExtensionTime = _auctionExtensionTime;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * (100 + bidIncrementPercentage) / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(addressBidCount[msg.sender] < 3, "Maximum of 3 bids per address");
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        addressBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime = block.timestamp + auctionExtensionTime;
        }
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}