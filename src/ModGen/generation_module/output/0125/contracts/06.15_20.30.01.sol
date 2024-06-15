```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidderBidCount;
    mapping(address => mapping(uint => uint)) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent value does not match bid amount");
        require(_bidAmount > highestBid * 105 / 100, "Bid amount must be at least 5% higher than the current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        highestBid = _bidAmount;
        highestBidder = msg.sender;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = _bidAmount;
        bidderBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, _bidAmount);
    }
    
    function withdraw() external {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        
        payable(organizer).transfer(highestBid);
    }
}
```