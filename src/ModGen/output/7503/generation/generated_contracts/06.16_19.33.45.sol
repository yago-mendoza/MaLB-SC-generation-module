// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;

    mapping(address => uint) public addressBidCount;
    mapping(address => mapping(uint => uint)) public addressBids;
    
    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Adjust time limit as needed
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether amount must match bid amount");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address allowed");
        require(_bidAmount >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");

        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if new bid in last 5 minutes
        }

        highestBid = _bidAmount;
        highestBidder = msg.sender;
        addressBids[msg.sender][addressBidCount[msg.sender]] = _bidAmount;
        addressBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, _bidAmount);
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}