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
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction time to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid(uint bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == bidAmount, "Sent Ether must match bid amount");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        require(bidAmount > highestBid, "Bid must be higher than current highest bid");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid in last 5 minutes
        }
        
        highestBid = bidAmount;
        highestBidder = msg.sender;
        addressToBidCount[msg.sender]++;
        addressToBids[msg.sender][addressToBidCount[msg.sender]] = bidAmount;
        
        emit NewHighestBid(msg.sender, bidAmount);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}