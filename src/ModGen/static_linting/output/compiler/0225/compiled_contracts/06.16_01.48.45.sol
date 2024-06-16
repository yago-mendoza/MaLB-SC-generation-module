// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public auctionExtensionTime;
    
    mapping(address => uint) public bidderBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _auctionExtensionTime) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionExtensionTime = _auctionExtensionTime;
        auctionEndTime = block.timestamp + 1 hours; // Initial auction time set to 1 hour
    }
    
    function placeBid() external payable {
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum of 3 bids per address reached");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += auctionExtensionTime;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        bidderBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        
        // Implement transfer of highest bid amount to organizer
        payable(organizer).transfer(highestBid);
    }
}