```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public minimumTokensRequired;
    uint public totalTokens;
    mapping(address => uint) public bidsPerAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _extensionDuration, uint _minimumTokensRequired, uint _totalTokens) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        bidIncrementPercentage = 5;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        minimumTokensRequired = _minimumTokensRequired;
        totalTokens = _totalTokens;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }

    function placeBid() external payable onlyDuringAuction {
        require(msg.value > 0, "Bid amount must be greater than 0");
        require(msg.value >= highestBid + (highestBid * bidIncrementPercentage / 100), "Bid amount must be at least 5% higher than the current highest bid");
        require(bidsPerAddress[msg.sender] < 3, "Maximum of 3 bids per address reached");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        bidsPerAddress[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}
```