```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public auctionDuration;
    uint public extensionTime;
    bool public auctionEnded;
    mapping(address => uint) public bidsPerAddress;

    event NewHighestBid(address bidder, uint amount);

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    constructor(uint _auctionDuration, uint _extensionTime, uint _bidIncrementPercentage) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        auctionDuration = _auctionDuration;
        extensionTime = _extensionTime;
        bidIncrementPercentage = _bidIncrementPercentage;
    }

    function placeBid() external payable {
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(bidsPerAddress[msg.sender] < 3, "Maximum 3 bids per address allowed");
        require((msg.value * 100) / highestBid >= bidIncrementPercentage, "Bid must be at least 5% higher than the current highest bid");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionTime;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        bidsPerAddress[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");

        auctionEnded = true;
        payable(organizer).transfer(highestBid);
    }

    function finalizeAuction() external {
        require(!auctionEnded, "Auction has already ended");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        auctionEnded = true;
    }
}
```  