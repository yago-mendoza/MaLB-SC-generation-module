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
    uint public extensionTime = 10 minutes;
    uint public numBidsAllowed = 3;
    mapping(address => uint) public numBidsByAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid && msg.value >= (highestBid * minBidIncreasePercentage / 100), "Bid amount too low");
        require(numBidsByAddress[msg.sender] < numBidsAllowed, "Exceeded maximum number of bids");

        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += extensionTime;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        lastBidTime = block.timestamp;
        numBidsByAddress[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}