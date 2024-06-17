// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public numBids;
    uint constant public bidIncrementPercentage = 5;
    uint constant public auctionDuration = 30 minutes;
    uint constant public extensionDuration = 10 minutes;
    mapping(address => uint) public numBidsByAddress;

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
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(msg.value >= (highestBid + ((highestBid * bidIncrementPercentage) / 100)), "Bid increment not met");
        require(numBidsByAddress[msg.sender] < 3, "Maximum 3 bids per address reached");

        if (block.timestamp + 5 minutes > auctionEndTime) {
            auctionEndTime += extensionDuration;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        numBidsByAddress[msg.sender]++;
        numBids++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}