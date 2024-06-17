// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressBids;
    uint constant public maxBidsPerAddress = 3;
    uint constant public minBidIncreasePercentage = 5;
    bool public auctionEnded;
    
    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
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
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require((msg.value * 100 / highestBid) >= minBidIncreasePercentage, "Bid amount must be at least 5% higher");
        require(addressBids[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids per address");

        addressBids[msg.sender]++;
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit NewHighestBid(msg.sender, msg.value);

        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes;
        }
    }

    function endAuction() external onlyOrganizer auctionNotEnded {
        auctionEnded = true;
        auctionEndTime = block.timestamp;
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}