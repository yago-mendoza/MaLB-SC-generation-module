// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage = 5;
    uint public auctionDuration = 60 minutes;
    uint public extensionDuration = 10 minutes;
    uint public totalBids;
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(msg.value >= highestBid + (highestBid * minBidIncreasePercentage) / 100, "Bid increase must be at least 5%");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address");

        totalBids++;
        addressBidCount[msg.sender]++;
        highestBid = msg.value;
        highestBidder = msg.sender;

        emit NewHighestBid(msg.sender, msg.value);

        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime = block.timestamp + extensionDuration;
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Withdraw the highest bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}