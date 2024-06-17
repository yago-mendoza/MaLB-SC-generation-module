// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;

    mapping(address => uint[]) public bidsByAddress;
    mapping(uint => address) public bidderByBid;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(bidsByAddress[msg.sender].length < 3, "Maximum 3 bids per address");
        require(msg.value > highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");

        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid placed in last 5 minutes
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        bidsByAddress[msg.sender].push(msg.value);
        bidderByBid[msg.value] = msg.sender;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}