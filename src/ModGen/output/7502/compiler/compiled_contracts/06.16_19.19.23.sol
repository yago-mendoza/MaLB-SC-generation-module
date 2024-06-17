// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public constant maxBidsPerAddress = 3;
    uint public constant minBidIncreasePercentage = 105; // 105 represents 5% increase
    bool public auctionEnded;
    
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Auction runs for 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(addressBidCount[msg.sender] < maxBidsPerAddress, "Maximum bids reached");
        require(msg.value > highestBid * minBidIncreasePercentage / 100, "Bid amount too low");
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        addressBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid in last 5 minutes
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        
        auctionEnded = true;
        payable(organizer).transfer(highestBid);
    }
}