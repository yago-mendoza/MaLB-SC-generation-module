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
    uint constant public maxBidsPerAddress = 3;
    uint constant public auctionDuration = 30 minutes;
    uint constant public extensionDuration = 10 minutes;

    mapping(address => uint) public bidsPerAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid + (highestBid * bidIncrementPercentage) / 100, "Bid amount must be at least 5% higher");

        totalBids++;
        require(bidsPerAddress[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids");

        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);

            if (auctionEndTime - block.timestamp < 5 minutes) {
                auctionEndTime += extensionDuration;
            }
        }

        bidsPerAddress[msg.sender]++;
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}
```