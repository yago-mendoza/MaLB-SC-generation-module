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
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    function placeBid() external payable {
        require(!auctionEnded, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum of 3 bids per address allowed");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if new bid in last 5 minutes
        }
        
        addressToBidCount[msg.sender]++;
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        
        auctionEnded = true;
        // Perform fund transfer to organizer
        payable(organizer).transfer(highestBid);
    }
    
    function finalizeAuction() external onlyOrganizer {
        require(!auctionEnded, "Auction has already ended");
        
        auctionEnded = true;
        // Perform any finalization tasks here
    }
}