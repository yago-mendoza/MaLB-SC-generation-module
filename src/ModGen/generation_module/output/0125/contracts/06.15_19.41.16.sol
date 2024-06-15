```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidderBidCount;
    mapping(address => mapping(uint => uint)) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    constructor(uint _auctionDuration) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent ether amount must match the bid amount");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address allowed");
        require(_bidAmount > highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");

        highestBid = _bidAmount;
        highestBidder = msg.sender;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = _bidAmount;
        bidderBidCount[msg.sender]++;

        emit NewHighestBid(msg.sender, _bidAmount);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}
```  