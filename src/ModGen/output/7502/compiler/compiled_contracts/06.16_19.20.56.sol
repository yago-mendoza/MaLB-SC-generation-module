// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public totalBids;
    uint constant maxBidsPerAddress = 3;
    uint constant minBidIncreasePercentage = 105; // 105 represents 5% increase
    uint constant auctionDuration = 30 minutes;
    uint constant bidExtensionDuration = 10 minutes;

    mapping(address => uint) public bidsPerAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid && msg.value >= (highestBid * minBidIncreasePercentage) / 100, "Bid amount too low");

        if (block.timestamp > auctionEndTime - bidExtensionDuration) {
            auctionEndTime += bidExtensionDuration;
        }

        totalBids++;
        bidsPerAddress[msg.sender]++;

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}