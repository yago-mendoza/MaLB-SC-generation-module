// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint constant public minBidIncreasePercentage = 5;
    uint constant public maxBidsPerAddress = 3;
    uint constant public auctionDuration = 30 minutes;
    uint constant public auctionExtension = 10 minutes;
    bool public auctionEnded;
    
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(!auctionEnded, "Auction has ended");
        require(block.timestamp < auctionEndTime, "Auction time has expired");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= (highestBid + (highestBid * minBidIncreasePercentage) / 100), "Bid amount must be at least 5% higher than current highest bid");
        require(addressBidCount[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids per address");
        
        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += auctionExtension;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        addressBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        
        auctionEnded = true;
        // Perform transfer of funds to the organizer
        payable(organizer).transfer(highestBid);
    }
}