// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public numBids;
    uint constant maxBidsPerAddress = 3;
    uint constant minBidIncreasePercentage = 5;
    bool public auctionEnded;
    
    mapping(address => uint) public numBidsByAddress;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction time to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(numBidsByAddress[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids per address");
        require(msg.value >= (highestBid * (100 + minBidIncreasePercentage) / 100), "Bid must be at least 5% higher than current highest bid");
        require(!auctionEnded, "Auction has ended");
        
        numBids++;
        numBidsByAddress[msg.sender]++;
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Automatically extend auction by 10 minutes
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        
        auctionEnded = true;
        // Transfer funds to organizer
        payable(organizer).transfer(highestBid);
    }
    
    function finalizeAuction() external onlyOrganizer {
        require(!auctionEnded, "Auction has already ended");
        
        auctionEnded = true;
        // Transfer funds to organizer
        payable(organizer).transfer(highestBid);
    }
}