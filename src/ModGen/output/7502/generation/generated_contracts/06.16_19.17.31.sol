// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrement;
    uint public auctionDuration = 60 minutes; // Example 1 hour auction duration
    uint public extensionDuration = 10 minutes;
    mapping(address => uint) public bidsPerAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
        bidIncrement = 5; // 5% bid increment
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid + (highestBid * bidIncrement) / 100, "Bid increment not met");
        require(bidsPerAddress[msg.sender] < 3, "Maximum 3 bids per address reached");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        bidsPerAddress[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        address payable organizerPayable = payable(organizer);
        organizerPayable.transfer(highestBid);
    }
}