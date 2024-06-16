// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint constant maxBidsPerAddress = 3;
    uint constant minBidIncreasePercentage = 5;
    uint constant auctionExtensionTime = 600; // 10 minutes
    bool auctionEnded;
    mapping(address => uint) public numBidsByAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _auctionDuration) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketTokenId = _ticketTokenId;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= (highestBid * (100 + minBidIncreasePercentage)) / 100, "Bid increment must be at least 5% higher");

        highestBidder = msg.sender;
        highestBid = msg.value;
        numBidsByAddress[msg.sender]++;
        emit NewHighestBid(msg.sender, msg.value);

        if (block.timestamp > auctionEndTime - 300 && !auctionEnded) {
            auctionEndTime += auctionExtensionTime;
        }
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction is still ongoing");
        payable(organizer).transfer(highestBid);
    }

    function endAuction() external onlyOrganizer {
        require(!auctionEnded, "Auction already ended");
        auctionEnded = true;
    }
}