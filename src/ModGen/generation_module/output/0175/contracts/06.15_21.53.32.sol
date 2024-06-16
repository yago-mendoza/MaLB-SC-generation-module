```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint constant minBidIncrementPercentage = 5;
    uint constant auctionDuration = 30 minutes;
    uint constant extraTime = 10 minutes;
    uint public numBids;

    mapping(address => uint) public bids;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= (highestBid * (100 + minBidIncrementPercentage)) / 100, "Bid amount must be at least 5% higher");

        if (bids[msg.sender] == 0) {
            numBids++;
        }

        bids[msg.sender] = msg.value;
        highestBid = msg.value;
        highestBidder = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(msg.sender == organizer, "Only organizer can withdraw funds");

        payable(organizer).transfer(highestBid);
    }
}
```