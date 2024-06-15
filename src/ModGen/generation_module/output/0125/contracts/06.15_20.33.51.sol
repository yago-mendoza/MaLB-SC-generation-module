```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidCount;
    mapping(address => mapping(uint => uint)) public bids;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether amount must match bid amount");

        require(bidCount[msg.sender] < 3, "Exceeded maximum bid count");
        require(_bidAmount >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than current highest bid");

        bidCount[msg.sender]++;
        bids[msg.sender][bidCount[msg.sender]] = _bidAmount;

        if (_bidAmount > highestBid) {
            highestBid = _bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, _bidAmount);

            if (auctionEndTime - block.timestamp < 300) {
                auctionEndTime += 600; // Extend auction by 10 minutes if new bid in last 5 minutes
            }
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}
```