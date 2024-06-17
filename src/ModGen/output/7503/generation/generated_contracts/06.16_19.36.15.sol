// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressToBidCount;
    mapping(address => uint[]) public addressToBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require((msg.value * 100) / highestBid >= 105, "Bid must be at least 5% higher than current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum of 3 bids per address reached");
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        addressToBids[msg.sender].push(msg.value);
        addressToBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid placed within last 5 minutes
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer funds to the organizer
        payable(organizer).transfer(highestBid);
    }
}