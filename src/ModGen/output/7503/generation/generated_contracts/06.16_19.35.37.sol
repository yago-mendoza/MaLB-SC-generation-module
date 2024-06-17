// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;

    mapping(address => uint) public numBidsPerAddress;
    mapping(address => mapping(uint => uint)) public bidsPerAddress;
    
    event NewHighestBid(address bidder, uint amount);

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    constructor(uint _auctionDuration, uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketTokenId = _ticketTokenId;
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether amount must match bid amount");
        require(numBidsPerAddress[msg.sender] < 3, "Maximum 3 bids per address reached");
        require(_bidAmount > highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");

        // Refund previous bid if any
        if (bidsPerAddress[msg.sender][numBidsPerAddress[msg.sender]] > 0) {
            payable(msg.sender).transfer(bidsPerAddress[msg.sender][numBidsPerAddress[msg.sender]]);
        }

        // Update bid information
        numBidsPerAddress[msg.sender]++;
        bidsPerAddress[msg.sender][numBidsPerAddress[msg.sender]] = _bidAmount;

        // Update highest bid
        if (_bidAmount > highestBid) {
            highestBid = _bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, _bidAmount);
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(highestBidder != address(0), "No bids have been placed");

        // Transfer winning bid amount to organizer
        payable(organizer).transfer(highestBid);
    }
}