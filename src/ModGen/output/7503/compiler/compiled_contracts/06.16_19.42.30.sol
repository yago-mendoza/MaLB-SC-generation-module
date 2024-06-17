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
    uint public lastBidTime;
    uint constant bidLimit = 3;
    uint constant minTokenRequired = 10;

    mapping(address => uint) public bidderBidCount;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= minTokenRequired, "Minimum of 10 tokens required to participate");
        require(bidderBidCount[msg.sender] < bidLimit, "Exceeded bid limit");

        uint minBidAmount = highestBid + (highestBid * minBidIncreasePercentage) / 100;
        require(msg.value > minBidAmount, "Bid amount must be at least 5% higher than current highest bid");

        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }

        lastBidTime = block.timestamp;
        highestBid = msg.value;
        highestBidder = msg.sender;
        bidderBidCount[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        // Transfer the winning bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }

    function getBidderBidCount(address bidder) external view returns (uint) {
        return bidderBidCount[bidder];
    }

    function getAuctionDetails() external view returns (uint, uint, address, uint, uint, uint) {
        return (auctionEndTime, highestBid, highestBidder, ticketTokenId, minBidIncreasePercentage, lastBidTime);
    }
}