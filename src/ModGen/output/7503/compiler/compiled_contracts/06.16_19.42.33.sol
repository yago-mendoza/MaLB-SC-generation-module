// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    
    struct Bid {
        address bidder;
        uint amount;
    }
    
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public numBids;
    uint constant public bidIncrementPercentage = 5;
    uint constant public auctionDuration = 30 minutes;
    uint constant public extensionDuration = 10 minutes;
    uint constant public maxBidsPerAddress = 3;
    
    mapping(address => uint) public numBidsByAddress;
    mapping(uint => Bid) public bids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid + (highestBid * bidIncrementPercentage) / 100, "Bid increment percentage not met");
        require(numBidsByAddress[msg.sender] < maxBidsPerAddress, "Maximum bids per address reached");
        
        if (block.timestamp + extensionDuration > auctionEndTime) {
            auctionEndTime = block.timestamp + extensionDuration;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        numBids++;
        numBidsByAddress[msg.sender]++;
        
        bids[numBids] = Bid(msg.sender, msg.value);
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}