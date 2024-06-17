// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressToBidCount;
    mapping(address => mapping(uint => uint)) public addressToBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    function placeBid(uint _bidAmount) public payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(_bidAmount > highestBid, "Bid must be higher than current highest bid");
        require((_bidAmount * 100) / highestBid >= 105, "Bid must be at least 5% higher than current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        
        highestBid = _bidAmount;
        highestBidder = msg.sender;
        addressToBids[msg.sender][addressToBidCount[msg.sender]] = _bidAmount;
        addressToBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, _bidAmount);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if new bid within last 5 minutes
        }
    }
    
    function withdraw() public onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}