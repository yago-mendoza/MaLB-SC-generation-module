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
    
    constructor(uint _ticketTokenId, uint _auctionDuration) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        auctionEndTime = block.timestamp + _auctionDuration;
        highestBid = 0;
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether amount must match bid amount");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        require(_bidAmount >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        
        // Update bid information
        addressBidCount[msg.sender]++;
        addressBids[msg.sender][addressBidCount[msg.sender]] = _bidAmount;
        
        // Update highest bid
        if (_bidAmount > highestBid) {
            highestBid = _bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, _bidAmount);
            
            // Extend auction if new bid in last 5 minutes
            if (auctionEndTime - block.timestamp < 300) {
                auctionEndTime += 600; // 10 minutes extension
            }
        }
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer funds to organizer
        payable(organizer).transfer(highestBid);
    }
}