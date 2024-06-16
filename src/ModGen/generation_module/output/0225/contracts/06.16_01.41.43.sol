// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public numTickets;
    uint public minBidAmount;
    uint public minTokenBalance;

    mapping(address => uint) public numBids;
    mapping(address => mapping(uint => uint)) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _extensionDuration, uint _numTickets, uint _minBidAmount, uint _minTokenBalance) {
        organizer = msg.sender;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        numTickets = _numTickets;
        minBidAmount = _minBidAmount;
        minTokenBalance = _minTokenBalance;
        auctionEndTime = block.timestamp + _auctionDuration;
        bidIncrementPercentage = 5;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent value must equal bid amount");
        require(_bidAmount >= highestBid + (highestBid * bidIncrementPercentage / 100), "Bid amount must be at least 5% higher than current highest bid");
        require(numBids[msg.sender] < 3, "Maximum 3 bids per address");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }

        numBids[msg.sender]++;
        bidderBids[msg.sender][numBids[msg.sender]] = _bidAmount;

        if (_bidAmount > highestBid) {
            highestBid = _bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, _bidAmount);
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}