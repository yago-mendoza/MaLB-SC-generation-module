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
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    constructor(uint _auctionDuration) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid && msg.value > 0, "Bid must be higher than the current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address allowed");
        
        if (block.timestamp > auctionEndTime - 300) {
            auctionEndTime += 600; // Extend auction by 10 minutes if bid placed in last 5 minutes
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        addressToBidCount[msg.sender]++;
        addressToBids[msg.sender][addressToBidCount[msg.sender]] = msg.value;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer the winning bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}