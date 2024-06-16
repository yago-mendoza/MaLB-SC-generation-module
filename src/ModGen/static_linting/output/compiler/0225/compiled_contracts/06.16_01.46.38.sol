// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public numBids;
    uint constant maxBidsPerAddress = 3;
    uint constant minBidIncreasePercentage = 5;
    uint constant auctionExtensionTime = 10 minutes;
    bool public auctionEnded;
    mapping(address => uint) public numBidsByAddress;
    
    event NewHighestBid(address bidder, uint bidAmount);

    constructor(uint _ticketTokenId, uint _auctionDuration) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketTokenId = _ticketTokenId;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(numBidsByAddress[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids per address");
        require(msg.value >= highestBid * (100 + minBidIncreasePercentage) / 100, "Bid amount must be at least 5% higher than the current highest bid");
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        numBidsByAddress[msg.sender]++;
        numBids++;

        emit NewHighestBid(msg.sender, msg.value);

        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += auctionExtensionTime;
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