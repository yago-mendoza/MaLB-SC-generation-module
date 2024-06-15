```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public totalBids;
    uint constant public bidIncrementPercentage = 5;
    uint constant public auctionDuration = 30 minutes;
    uint constant public extensionDuration = 10 minutes;
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
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid + (highestBid * bidIncrementPercentage) / 100, "Bid amount must be at least 5% higher");

        totalBids++;
        bidsPerAddress[msg.sender]++;

        if (block.timestamp + extensionDuration > auctionEndTime) {
            auctionEndTime = block.timestamp + extensionDuration;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        address payable organizerPayable = payable(organizer);
        organizerPayable.transfer(highestBid);
    }
}
```