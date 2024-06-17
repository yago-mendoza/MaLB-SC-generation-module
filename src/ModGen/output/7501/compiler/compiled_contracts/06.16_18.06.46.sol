// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public auctionOrganizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public totalBids;
    mapping(address => uint) public addressBidCount;
    mapping(address => uint[]) public addressBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == auctionOrganizer, "Only the organizer can call this function");
        _;
    }
    
    constructor(uint _auctionDuration) {
        auctionOrganizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid must be at least 5% higher than the current highest bid");
        require(addressBidCount[msg.sender] < 3, "Maximum of 3 bids per address reached");
        
        totalBids++;
        addressBidCount[msg.sender]++;
        addressBids[msg.sender].push(msg.value);
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 300) {
            auctionEndTime += 600; // Extend auction by 10 minutes if bid placed within last 5 minutes
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(auctionOrganizer).transfer(highestBid);
    }
}