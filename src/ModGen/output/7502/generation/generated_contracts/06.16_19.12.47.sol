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

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent ETH amount must match bid amount");
        require(bidderBidCount[msg.sender] < 3, "Maximum of 3 bids per address reached");
        require(_bidAmount > highestBid + highestBid * 5 / 100, "Bid must be at least 5% higher than current highest bid");
        
        // Update bid information
        bidderBidCount[msg.sender]++;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = _bidAmount;
        
        // Update highest bid
        if (_bidAmount > highestBid) {
            highestBid = _bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, _bidAmount);
            
            // Extend auction duration by 10 minutes if new highest bid in last 5 minutes
            if (auctionEndTime - block.timestamp < 5 minutes) {
                auctionEndTime += 10 minutes;
            }
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer highest bid amount to organizer
        payable(organizer).transfer(highestBid);
    }
}