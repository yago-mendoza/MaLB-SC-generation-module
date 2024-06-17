// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidderBidCount;
    mapping(address => mapping(uint => uint)) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(_bidAmount > highestBid, "Bid amount must be higher than current highest bid");
        require(_bidAmount >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid within last 5 minutes
        }
        
        highestBid = _bidAmount;
        highestBidder = msg.sender;
        bidderBidCount[msg.sender]++;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = _bidAmount;
        
        emit NewHighestBid(msg.sender, _bidAmount);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer the highest bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}