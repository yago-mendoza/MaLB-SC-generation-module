// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidderBidCount;
    mapping(address => mapping(uint => uint)) public bidderBids;
    mapping(uint => address) public tokenOwners;
    uint public tokenCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // 1 hour auction time
    }
    
    function placeBid(uint tokenID) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        if (highestBidder != address(0)) {
            require(msg.value >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
            payable(highestBidder).transfer(highestBid);
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = msg.value;
        bidderBidCount[msg.sender]++;
        
        if (tokenOwners[tokenID] == address(0)) {
            tokenOwners[tokenID] = msg.sender;
            tokenCount++;
        }
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(highestBidder != address(0), "No bids placed");
        
        payable(organizer).transfer(highestBid);
    }
}