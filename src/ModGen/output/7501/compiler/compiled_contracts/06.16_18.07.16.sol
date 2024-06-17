// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidderBidCount;
    mapping(address => mapping(uint => bool)) public hasBid;
    bool public auctionEnded;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    constructor() {
        organizer = msg.sender;
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(!auctionEnded, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether must match bid amount");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        require(_bidAmount >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        
        if (block.timestamp >= auctionEndTime - 300) {
            auctionEndTime += 600; // Extend auction by 10 minutes
        }
        
        highestBid = _bidAmount;
        highestBidder = msg.sender;
        bidderBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, _bidAmount);
    }
    
    function endAuction() external onlyOrganizer {
        require(!auctionEnded, "Auction has already ended");
        
        auctionEnded = true;
        // Perform any additional logic here
        
        // Transfer funds to organizer
        payable(organizer).transfer(highestBid);
    }
}