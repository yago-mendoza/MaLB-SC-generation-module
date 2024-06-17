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
    
    function placeBid(uint bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        require(bidAmount >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid placed within last 5 minutes
        }
        
        highestBid = bidAmount;
        highestBidder = msg.sender;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = bidAmount;
        bidderBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, bidAmount);
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        
        // Implement transfer of highest bid amount to organizer
        // For simplicity, direct transfer is shown here
        payable(organizer).transfer(highestBid);
    }
}