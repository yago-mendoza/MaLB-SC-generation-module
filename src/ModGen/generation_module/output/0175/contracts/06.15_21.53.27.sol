```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenID;
    uint public totalBids;
    uint constant public maxBidsPerAddress = 3;
    uint constant public minBidIncreasePercentage = 5;
    bool public auctionEnded;
    bool public bidExtended;

    mapping(address => uint) public addressBidCount;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenID, uint _auctionDurationMinutes) {
        organizer = msg.sender;
        ticketTokenID = _ticketTokenID;
        auctionEndTime = block.timestamp + _auctionDurationMinutes * 1 minutes;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has ended");
        _;
    }

    function placeBid() external payable auctionNotEnded {
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.value >= (highestBid * (100 + minBidIncreasePercentage)) / 100, "Bid increment must be at least 5% higher than the current highest bid");
        require(addressBidCount[msg.sender] < maxBidsPerAddress, "Maximum number of bids reached for this address");

        totalBids++;
        addressBidCount[msg.sender]++;
        highestBidder = msg.sender;
        highestBid = msg.value;

        emit NewHighestBid(msg.sender, msg.value);

        if (auctionEndTime - block.timestamp < 5 minutes && !bidExtended) {
            auctionEndTime += 10 minutes;
            bidExtended = true;
        }
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");

        auctionEnded = true;
        // Perform transfer of highestBid to organizer
    }

    function finalizeAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        auctionEnded = true;
        // Perform finalization logic, transfer of highestBid to organizer
    }
}
```