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
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(_bidAmount > highestBid, "Bid amount must be higher than current highest bid");
        require((_bidAmount * 100) >= (highestBid * 105), "Bid must be at least 5% higher than current highest bid");
        require(addressBidCount[msg.sender] < 3, "Maximum of 3 bids per address allowed");

        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Automatically extend auction by 10 minutes if bid placed within last 5 minutes
        }

        highestBid = _bidAmount;
        highestBidder = msg.sender;
        addressBids[msg.sender][addressBidCount[msg.sender]] = _bidAmount;
        addressBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, _bidAmount);
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}