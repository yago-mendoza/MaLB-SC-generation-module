// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidderBidCount;
    mapping(address => mapping(uint => uint)) public bidderBids;
    uint constant MAX_BID_COUNT = 3;
    uint constant MIN_BID_INCREMENT_PERCENTAGE = 5;
    uint constant AUCTION_DURATION = 30 minutes;
    uint constant AUCTION_EXTENSION = 10 minutes;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + AUCTION_DURATION;
    }

    function placeBid(uint bidAmount) external payable {
        require(msg.value == bidAmount, "Ether value must match bid amount");
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(bidderBidCount[msg.sender] < MAX_BID_COUNT, "Maximum bid count reached");

        uint minBidAmount = highestBid + (highestBid * MIN_BID_INCREMENT_PERCENTAGE) / 100;
        require(bidAmount >= minBidAmount, "Bid amount too low");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += AUCTION_EXTENSION;
        }

        highestBid = bidAmount;
        highestBidder = msg.sender;
        bidderBidCount[msg.sender]++;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = bidAmount;

        emit NewHighestBid(msg.sender, bidAmount);
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}