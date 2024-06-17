// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;

    mapping(address => uint) public addressBidCount;
    mapping(address => uint[3]) public addressBids;
    
    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid(uint bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(bidAmount > highestBid, "Bid amount must be higher than current highest bid");
        require(bidAmount >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(addressBidCount[msg.sender] < 3, "Maximum of 3 bids per address allowed");

        // Update bid information
        addressBids[msg.sender][addressBidCount[msg.sender]] = bidAmount;
        addressBidCount[msg.sender]++;
        
        if (bidAmount > highestBid) {
            highestBid = bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, bidAmount);
            
            // Extend auction duration by 10 minutes if new highest bid in last 5 minutes
            if (auctionEndTime - block.timestamp < 5 minutes) {
                auctionEndTime += 10 minutes;
            }
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(highestBid > 0, "No bids have been placed");

        payable(organizer).transfer(highestBid);
    }
}