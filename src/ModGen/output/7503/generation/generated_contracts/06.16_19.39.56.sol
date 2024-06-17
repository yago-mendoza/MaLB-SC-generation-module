// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public minBidIncreasePercentage;
    uint public numBidsAllowed;
    uint public numTokensRequired;
    bool public auctionEnded;
    mapping(address => uint) public numBidsByAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _minBidIncreasePercentage, uint _numBidsAllowed, uint _numTokensRequired) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        numBidsAllowed = _numBidsAllowed;
        numTokensRequired = _numTokensRequired;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has ended");
        _;
    }

    function placeBid() external payable auctionNotEnded {
        require(msg.value >= numTokensRequired, "Minimum of 10 tokens required to participate");
        require(numBidsByAddress[msg.sender] < numBidsAllowed, "Exceeded maximum number of bids");

        uint minBidAmount = highestBid + (highestBid * minBidIncreasePercentage / 100);
        require(msg.value >= minBidAmount, "Bid amount must be at least 5% higher than current highest bid");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }

        numBidsByAddress[msg.sender]++;
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
    }

    function endAuction() external onlyOrganizer auctionNotEnded {
        auctionEnded = true;
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}