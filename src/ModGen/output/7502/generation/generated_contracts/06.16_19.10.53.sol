// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public numBids;
    uint constant public maxBidsPerAddress = 3;
    uint constant public minBidIncreasePercentage = 5;
    bool public auctionEnded;
    
    mapping(address => uint) public numBidsByAddress;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has already ended");
        _;
    }
    
    function placeBid() external payable auctionNotEnded {
        require(numBidsByAddress[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids per address");
        require(msg.value > highestBid + (highestBid * minBidIncreasePercentage / 100), "Bid amount must be at least 5% higher than the current highest bid");
        
        numBidsByAddress[msg.sender]++;
        numBids++;
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
    
    function endAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction is still ongoing");
        
        auctionEnded = true;
    }
}