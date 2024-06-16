// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    
    mapping(address => uint) public addressBidCount;
    mapping(address => mapping(uint => uint)) public addressBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid(uint bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == bidAmount, "Sent Ether amount must match bid amount");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        require(bidAmount >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        
        // Update bid information
        addressBidCount[msg.sender]++;
        addressBids[msg.sender][addressBidCount[msg.sender]] = bidAmount;
        
        // Update highest bid
        if (bidAmount > highestBid) {
            highestBid = bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, bidAmount);
            
            // Extend auction by 10 minutes if new bid in last 5 minutes
            if (auctionEndTime - block.timestamp < 5 minutes) {
                auctionEndTime += 10 minutes;
            }
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}