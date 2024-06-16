// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEnd;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    
    mapping(address => uint) public numBids;
    mapping(address => mapping(uint => uint)) public bids;
    
    bool public auctionEnded;
    bool public bidExtended;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    constructor(uint _auctionDuration, uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEnd = block.timestamp + _auctionDuration;
        ticketTokenId = _ticketTokenId;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEnd, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(numBids[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        if (block.timestamp >= auctionEnd - 5 minutes && !bidExtended) {
            auctionEnd += 10 minutes;
            bidExtended = true;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        numBids[msg.sender]++;
        bids[msg.sender][numBids[msg.sender]] = msg.value;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        
        auctionEnded = true;
        // Transfer highest bid amount to organizer
        payable(organizer).transfer(highestBid);
    }
}