```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public numBids;
    mapping(address => uint) public numBidsPerAddress;
    mapping(address => mapping(uint => uint)) public bidsPerAddress;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    modifier auctionNotEnded() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }
    
    constructor(uint _auctionDuration) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    function placeBid() external payable auctionNotEnded {
        require(numBidsPerAddress[msg.sender] < 3, "Exceeded maximum number of bids per address");
        require(msg.value > highestBid * 105 / 100, "Bid amount must be at least 5% higher than current highest bid");
        
        numBidsPerAddress[msg.sender]++;
        numBids++;
        bidsPerAddress[msg.sender][numBidsPerAddress[msg.sender]] = msg.value;
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}
```