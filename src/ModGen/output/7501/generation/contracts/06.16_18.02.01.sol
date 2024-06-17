// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public auctionExtensionTime;
    uint public numBidsAllowed;
    mapping(address => uint) public numBidsPlaced;
    bool public auctionEnded;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _auctionExtensionTime, uint _numBidsAllowed) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionExtensionTime = _auctionExtensionTime;
        numBidsAllowed = _numBidsAllowed;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction time to 1 hour
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(!auctionEnded, "Auction has ended");
        require(numBidsPlaced[msg.sender] < numBidsAllowed, "You have reached the maximum number of bids allowed");
        require(msg.value > highestBid + (highestBid * bidIncrementPercentage / 100), "Bid amount must be at least 5% higher than the current highest bid");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += auctionExtensionTime;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        numBidsPlaced[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function endAuction() external onlyOrganizer {
        require(!auctionEnded, "Auction has already ended");
        auctionEnded = true;
        // Perform any finalization logic here
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}