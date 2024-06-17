// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public auctionExtensionTime;
    uint public totalBids;
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _auctionExtensionTime) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionExtensionTime = _auctionExtensionTime;
        auctionEndTime = block.timestamp + 1 hours; // Initial auction duration of 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * (100 + bidIncrementPercentage) / 100, "Bid increment percentage not met");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        
        totalBids++;
        addressBidCount[msg.sender]++;
        highestBid = msg.value;
        highestBidder = msg.sender;
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += auctionExtensionTime;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        address payable organizerPayable = payable(organizer);
        organizerPayable.transfer(highestBid);
    }
}