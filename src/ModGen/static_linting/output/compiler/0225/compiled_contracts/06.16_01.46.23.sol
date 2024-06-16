// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public minBidAmount;
    uint public numBidsPerAddress;
    uint public totalBids;
    mapping(address => uint) public numBidsByAddress;
    mapping(address => uint[]) public bidsByAddress;
    bool public auctionEnded;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _minBidAmount, uint _numBidsPerAddress, uint _auctionDurationMinutes) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        minBidAmount = _minBidAmount;
        numBidsPerAddress = _numBidsPerAddress;
        auctionEndTime = block.timestamp + (_auctionDurationMinutes * 1 minutes);
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can perform this action");
        _;
    }

    function placeBid() external payable {
        require(msg.value >= minBidAmount, "Bid amount must be at least the minimum bid amount");
        require(numBidsByAddress[msg.sender] < numBidsPerAddress, "Exceeded maximum number of bids per address");
        require(msg.value >= highestBid + ((highestBid * minBidIncreasePercentage) / 100), "Bid must be at least 5% higher than current highest bid");

        totalBids++;
        numBidsByAddress[msg.sender]++;
        bidsByAddress[msg.sender].push(msg.value);

        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
            if (auctionEndTime - block.timestamp < 5 minutes) {
                auctionEndTime += 10 minutes;
            }
        }
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }

    function endAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        auctionEnded = true;
    }
}