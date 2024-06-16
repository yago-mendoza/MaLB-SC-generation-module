// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressToBidCount;
    bool public auctionEnded;
    bool public withdrawalInitiated;

    event NewHighestBid(address bidder, uint amount);

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has already ended");
        _;
    }

    constructor(uint _durationMinutes) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _durationMinutes * 1 minutes;
    }

    function placeBid() external payable auctionNotEnded {
        require(msg.value > highestBid * 105 / 100, "Bid amount must be at least 5% higher than the current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum of 3 bids per address allowed");

        addressToBidCount[msg.sender]++;
        highestBid = msg.value;
        highestBidder = msg.sender;

        emit NewHighestBid(msg.sender, msg.value);

        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid placed within last 5 minutes
        }
    }

    function concludeAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        auctionEnded = true;
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        require(!withdrawalInitiated, "Withdrawal already initiated");

        withdrawalInitiated = true;
        payable(organizer).transfer(highestBid);
    }
}