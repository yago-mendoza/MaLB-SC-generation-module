// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressBidCount;
    mapping(address => mapping(uint => uint)) public addressBids;
    uint constant maxBidsPerAddress = 3;
    uint constant minBidIncreasePercentage = 5;
    uint constant auctionDuration = 30 minutes; // Example duration, can be customized

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    function placeBid(uint _bidAmount) external payable {
        require(msg.value == _bidAmount, "Ether value sent must match bid amount");
        require(block.timestamp < auctionEndTime, "Auction has ended");

        require(_bidAmount > highestBid + highestBid * minBidIncreasePercentage / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(addressBidCount[msg.sender] < maxBidsPerAddress, "Maximum number of bids reached for this address");

        highestBid = _bidAmount;
        highestBidder = msg.sender;
        addressBids[msg.sender][addressBidCount[msg.sender]] = _bidAmount;
        addressBidCount[msg.sender]++;

        emit NewHighestBid(msg.sender, _bidAmount);

        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes;
        }
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}