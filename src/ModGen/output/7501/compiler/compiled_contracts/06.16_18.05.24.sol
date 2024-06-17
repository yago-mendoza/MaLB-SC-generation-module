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
    
    constructor(uint _auctionDuration, uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketTokenId = _ticketTokenId;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can perform this action");
        _;
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether amount must match bid amount");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        require(_bidAmount > highestBid + (highestBid * 5) / 100, "Bid must be at least 5% higher than current highest bid");
        
        highestBid = _bidAmount;
        highestBidder = msg.sender;
        addressBidCount[msg.sender]++;
        addressBids[msg.sender][addressBidCount[msg.sender]] = _bidAmount;
        
        emit NewHighestBid(msg.sender, _bidAmount);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}