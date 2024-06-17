// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressBidCount;
    mapping(address => uint[]) public addressBids;
    bool public auctionEnded;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can perform this action");
        _;
    }

    function placeBid() external payable {
        require(!auctionEnded, "Auction has ended");
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than the current highest bid");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address");

        highestBid = msg.value;
        highestBidder = msg.sender;
        addressBids[msg.sender].push(msg.value);
        addressBidCount[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);

        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid placed within last 5 minutes
        }
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended");
        auctionEnded = true;
        // Transfer the highest bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}