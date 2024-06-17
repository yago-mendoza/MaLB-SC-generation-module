// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressToBidCount;
    bool public auctionEnded;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }

    function placeBid() external payable onlyDuringAuction {
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid must be at least 5% higher than the current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid placed within last 5 minutes
        }

        addressToBidCount[msg.sender]++;
        highestBid = msg.value;
        highestBidder = msg.sender;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");

        auctionEnded = true;
        // Perform fund transfer to organizer
        payable(organizer).transfer(highestBid);
    }

    function finalizeAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        auctionEnded = true;
        // Perform any finalization tasks here
    }
}