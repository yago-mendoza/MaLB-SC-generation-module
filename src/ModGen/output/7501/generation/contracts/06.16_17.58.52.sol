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

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether amount must match bid amount");
        require(addressBidCount[msg.sender] < 3, "Exceeded maximum bid count per address");
        require(_bidAmount > highestBid + highestBid * 5 / 100, "Bid amount must be at least 5% higher than current highest bid");

        highestBid = _bidAmount;
        highestBidder = msg.sender;
        addressBids[msg.sender][addressBidCount[msg.sender]] = _bidAmount;
        addressBidCount[msg.sender]++;

        emit NewHighestBid(msg.sender, _bidAmount);

        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Automatically extend auction by 10 minutes if bid placed within last 5 minutes
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}