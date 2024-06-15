```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public auctionDuration = 30 minutes;
    uint public extensionDuration = 10 minutes;
    uint public minBidIncreasePercentage = 105; // 105 represents 5% increase

    mapping(address => uint) public bidderBidCount;

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
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(msg.value >= highestBid * minBidIncreasePercentage / 100, "Bid must be at least 5% higher");

        if (block.timestamp + 5 minutes > auctionEndTime) {
            auctionEndTime += extensionDuration;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        bidderBidCount[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}
```