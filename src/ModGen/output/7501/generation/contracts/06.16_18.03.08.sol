// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    
    mapping(address => uint) public bidderBidCount;
    mapping(address => mapping(uint => uint)) public addressBidAmounts;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    constructor(uint _auctionDurationMinutes, uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDurationMinutes * 1 minutes;
        ticketTokenId = _ticketTokenId;
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent ETH amount must match bid amount");
        require(bidderBidCount[msg.sender] < 3, "Bidder has reached maximum bid count");
        require(_bidAmount > highestBid * 105 / 100, "Bid amount must be at least 5% higher than current highest bid");
        
        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }
        
        highestBid = _bidAmount;
        highestBidder = msg.sender;
        bidderBidCount[msg.sender]++;
        addressBidAmounts[msg.sender][bidderBidCount[msg.sender]] = _bidAmount;
        
        emit NewHighestBid(msg.sender, _bidAmount);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer funds to organizer
        payable(organizer).transfer(highestBid);
    }
}