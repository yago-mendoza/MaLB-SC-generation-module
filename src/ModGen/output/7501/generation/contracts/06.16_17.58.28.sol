// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId = 1;
    uint constant public maxBidsPerAddress = 3;
    uint constant public minBidIncreasePercentage = 5;
    uint constant public auctionExtensionTime = 600; // 10 minutes in seconds

    mapping(address => uint) public addressToNumBids;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 3600; // 1 hour duration for the auction
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require((msg.value * 100) / highestBid >= minBidIncreasePercentage, "Bid increment percentage not met");
        require(addressToNumBids[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids");

        if (block.timestamp + 300 > auctionEndTime) { // Check if within last 5 minutes
            auctionEndTime += auctionExtensionTime; // Extend auction by 10 minutes
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        addressToNumBids[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}