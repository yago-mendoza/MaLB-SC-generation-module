// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint constant public minBidIncreasePercentage = 5;
    uint constant public maxBidsPerAddress = 3;

    mapping(address => uint) public numBidsByAddress;
    mapping(address => mapping(uint => uint)) public bidsByAddress;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _auctionDurationMinutes) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        auctionEndTime = block.timestamp + _auctionDurationMinutes * 1 minutes;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.value >= highestBid * (100 + minBidIncreasePercentage) / 100, "Bid amount must be at least 5% higher than the current highest bid");
        require(numBidsByAddress[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids per address");

        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }

        numBidsByAddress[msg.sender]++;
        bidsByAddress[msg.sender][numBidsByAddress[msg.sender]] = msg.value;
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}