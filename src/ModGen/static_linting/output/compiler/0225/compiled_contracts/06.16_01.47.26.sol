// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidderBidCount;
    mapping(address => bool) public hasWithdrawn;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Auction duration set to 1 hour for demonstration purposes
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum of 3 bids per address allowed");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid is in the last 5 minutes
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        bidderBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(!hasWithdrawn[msg.sender], "Funds have already been withdrawn");

        hasWithdrawn[msg.sender] = true;
        payable(msg.sender).transfer(highestBid);
    }

    function getHighestBidder() external view returns (address) {
        return highestBidder;
    }

    function getHighestBid() external view returns (uint) {
        return highestBid;
    }

    function getAuctionEndTime() external view returns (uint) {
        return auctionEndTime;
    }
}