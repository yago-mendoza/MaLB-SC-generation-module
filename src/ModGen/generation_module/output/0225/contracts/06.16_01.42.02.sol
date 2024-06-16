// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public minBidAmount;
    uint public numBidsAllowed;
    
    mapping(address => uint) public numBidsPlaced;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _auctionDuration, uint _extensionDuration, uint _minBidAmount, uint _numBidsAllowed) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        minBidAmount = _minBidAmount;
        numBidsAllowed = _numBidsAllowed;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= minBidAmount, "Bid amount too low");
        require(numBidsPlaced[msg.sender] < numBidsAllowed, "Exceeded maximum number of bids");
        
        if (msg.value > highestBid) {
            if (block.timestamp + extensionDuration > auctionEndTime) {
                auctionEndTime = block.timestamp + extensionDuration;
            }
            highestBidder = msg.sender;
            highestBid = msg.value;
            numBidsPlaced[msg.sender]++;
            emit NewHighestBid(msg.sender, msg.value);
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}