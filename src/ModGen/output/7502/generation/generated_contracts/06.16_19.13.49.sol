// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId = 1;
    
    mapping(address => uint) public addressToBidCount;
    mapping(uint => address) public tokenIdToOwner;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Auction duration set to 1 hour for demonstration
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid); // Refund previous highest bidder
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        addressToBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer funds to organizer
        payable(organizer).transfer(highestBid);
        
        // Assign token ownership to the highest bidder
        tokenIdToOwner[ticketTokenId] = highestBidder;
        ticketTokenId++;
    }
}