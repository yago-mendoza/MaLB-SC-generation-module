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

    mapping(address => uint) public bidderBidCount;

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
        require(msg.value >= (highestBid * (100 + minBidIncreasePercentage)) / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionTime;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        lastBidTime = block.timestamp;
        bidderBidCount[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        (bool success, ) = organizer.call{value: highestBid}("");
        require(success, "Transfer failed");
    }
}