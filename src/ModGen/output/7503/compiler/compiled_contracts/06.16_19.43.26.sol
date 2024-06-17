// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressToBidCount;
    bool public auctionEnded;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }
    
    function placeBid() external payable onlyDuringAuction {
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid must be at least 5% higher than the current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Automatically extend auction by 10 minutes if bid placed in last 5 minutes
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        addressToBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(!auctionEnded, "Auction has already ended");
        
        auctionEnded = true;
        
        // Transfer the winning bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}