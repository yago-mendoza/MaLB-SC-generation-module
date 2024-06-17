// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    
    mapping(address => uint) public addressBidCount;
    mapping(address => mapping(uint => uint)) public addressBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    constructor(uint _auctionDurationMinutes, uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDurationMinutes * 1 minutes;
        ticketTokenId = _ticketTokenId;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid must be at least 5% higher than the current highest bid");
        require(addressBidCount[msg.sender] < 3, "Maximum of 3 bids per address");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }
        
        addressBidCount[msg.sender]++;
        addressBids[msg.sender][addressBidCount[msg.sender]] = msg.value;
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer funds to organizer
        payable(organizer).transfer(highestBid);
    }
}