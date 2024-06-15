```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public minBidIncreasePercentage;
    uint public numBidsAllowed;
    uint public totalBids;
    bool public auctionEnded;

    mapping(address => uint) public numBidsByAddress;

    event NewHighestBid(address bidder, uint amount);

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has ended");
        _;
    }

    constructor(uint _auctionDurationMinutes, uint _minBidIncreasePercentage, uint _numBidsAllowed) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDurationMinutes * 1 minutes;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        numBidsAllowed = _numBidsAllowed;
    }

    function placeBid() external payable auctionNotEnded {
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * (100 + minBidIncreasePercentage) / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(numBidsByAddress[msg.sender] < numBidsAllowed, "Maximum number of bids reached for this address");

        totalBids++;
        numBidsByAddress[msg.sender]++;
        highestBid = msg.value;
        highestBidder = msg.sender;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function endAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        auctionEnded = true;
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}
```