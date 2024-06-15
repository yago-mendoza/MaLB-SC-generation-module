```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrement;
    uint public minBidIncreasePercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public totalTickets;
    uint public totalBids;
    mapping(address => uint) public bids;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _totalTickets, uint _auctionDuration, uint _extensionDuration, uint _minBidIncreasePercentage) {
        organizer = msg.sender;
        totalTickets = _totalTickets;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        bidIncrement = 0;
        highestBid = 0;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    function placeBid() external payable {
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(bids[msg.sender] < 3, "Maximum 3 bids per address allowed");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        bids[msg.sender]++;
        totalBids++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}
```