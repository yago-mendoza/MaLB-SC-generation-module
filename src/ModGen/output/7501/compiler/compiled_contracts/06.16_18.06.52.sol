// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minimumBidIncreasePercentage = 5;
    uint public constant maxBidsPerAddress = 3;
    
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionEndTime, uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEndTime = _auctionEndTime;
        ticketTokenId = _ticketTokenId;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(msg.value >= (highestBid + (highestBid * minimumBidIncreasePercentage) / 100), "Bid must be at least 5% higher");
        require(addressBidCount[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids");
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
        
        addressBidCount[msg.sender]++;
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}