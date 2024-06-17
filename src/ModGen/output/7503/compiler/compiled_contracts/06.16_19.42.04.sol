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
    uint constant auctionExtensionTime = 600; // 10 minutes in seconds

    mapping(address => uint) public bidsPerAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _auctionDuration) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        auctionEndTime = block.timestamp + _auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * (100 + minBidIncreasePercentage) / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(bidsPerAddress[msg.sender] < maxBidsPerAddress, "Maximum number of bids reached for this address");

        if (block.timestamp >= auctionEndTime - 300) { // Last 5 minutes, extend auction
            auctionEndTime += auctionExtensionTime;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        bidsPerAddress[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        // Transfer funds to the organizer
        payable(organizer).transfer(highestBid);
    }

    function getHighestBid() external view returns (uint) {
        return highestBid;
    }

    function getHighestBidder() external view returns (address) {
        return highestBidder;
    }
}