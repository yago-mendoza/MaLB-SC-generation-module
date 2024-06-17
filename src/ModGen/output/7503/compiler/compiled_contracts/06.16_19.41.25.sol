// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public auctionDuration;
    uint public extensionTime;
    
    mapping(address => uint) public bidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _auctionDuration, uint _extensionTime) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionDuration = _auctionDuration;
        extensionTime = _extensionTime;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.value >= highestBid + (highestBid * bidIncrementPercentage) / 100, "Bid increment percentage not met");
        require(bidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        if (block.timestamp + extensionTime > auctionEndTime) {
            auctionEndTime = block.timestamp + extensionTime;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        bidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Perform transfer to organizer
        payable(organizer).transfer(highestBid);
    }
}