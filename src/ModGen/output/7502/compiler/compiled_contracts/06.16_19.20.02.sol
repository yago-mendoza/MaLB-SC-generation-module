// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public auctionDuration = 30 minutes;
    uint public extensionDuration = 10 minutes;
    uint public minTokenRequired = 10;
    
    mapping(address => uint) public bidderBidCount;
    mapping(address => mapping(uint => uint)) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require((msg.value * 100) / highestBid >= minBidIncreasePercentage, "Bid increase percentage not met");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        if (block.timestamp + 5 minutes >= auctionEndTime) {
            auctionEndTime += extensionDuration;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        bidderBidCount[msg.sender]++;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = msg.value;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}