// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public constant maxBidsPerAddress = 3;
    uint public constant minBidIncreasePercentage = 5;
    uint public constant auctionExtensionTime = 600; // 10 minutes
    bool public auctionEnded;

    mapping(address => uint) public bidsPerAddress;

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

    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has ended");
        _;
    }

    function placeBid() external payable auctionNotEnded {
        require(bidsPerAddress[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids");
        require(msg.value > highestBid + (highestBid * minBidIncreasePercentage) / 100, "Bid amount must be at least 5% higher than the current highest bid");

        if (block.timestamp >= auctionEndTime - 300) { // Check if within last 5 minutes
            auctionEndTime += auctionExtensionTime;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        bidsPerAddress[msg.sender]++;
        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");

        auctionEnded = true;
        // Perform transfer of highest bid amount to organizer
        payable(organizer).transfer(highestBid);
    }

    function finalizeAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        auctionEnded = true;
        // Perform any finalization tasks
    }
}