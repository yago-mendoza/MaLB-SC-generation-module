// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketToken;

    mapping(address => uint) public bidderBidCount;
    mapping(address => mapping(uint => uint)) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _ticketToken) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketToken = _ticketToken;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether amount must match bid amount");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        require(_bidAmount >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes
        }

        bidderBidCount[msg.sender]++;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = _bidAmount;

        if (_bidAmount > highestBid) {
            highestBid = _bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, _bidAmount);
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        // Transfer the winning bid amount to the organizer
        payable(organizer).transfer(highestBid);

        // Lock the winning bid amount in the contract
        highestBid = 0;
    }
}