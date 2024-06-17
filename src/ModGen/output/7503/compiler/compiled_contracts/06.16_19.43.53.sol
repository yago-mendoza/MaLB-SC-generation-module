// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    bool public auctionEnded;
    
    mapping(address => uint) public addressToNumBids;
    
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
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than the current highest bid");
        require(addressToNumBids[msg.sender] < 3, "Maximum of 3 bids per address reached");
        
        addressToNumBids[msg.sender]++;
        highestBid = msg.value;
        highestBidder = msg.sender;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid is placed within last 5 minutes
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        
        auctionEnded = true;
        payable(organizer).transfer(highestBid);
    }
    
    function finalizeAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        auctionEnded = true;
    }
}