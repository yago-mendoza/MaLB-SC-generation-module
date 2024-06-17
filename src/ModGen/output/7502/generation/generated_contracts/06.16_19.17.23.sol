// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressToBidCount;
    mapping(address => mapping(uint => uint)) public addressToBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    function placeBid(uint bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == bidAmount, "Sent Ether amount must match bid amount");
        require(bidAmount > highestBid, "Bid amount must be higher than current highest bid");
        require(bidAmount >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        // Update bid information
        addressToBidCount[msg.sender]++;
        uint bidIndex = addressToBidCount[msg.sender];
        addressToBids[msg.sender][bidIndex] = bidAmount;
        
        // Update highest bid
        highestBid = bidAmount;
        highestBidder = msg.sender;
        
        emit NewHighestBid(msg.sender, bidAmount);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid placed within last 5 minutes
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}