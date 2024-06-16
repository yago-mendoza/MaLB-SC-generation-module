```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressBidCount;
    mapping(address => mapping(uint => uint)) public addressBids;
    uint constant MAX_BIDS_PER_ADDRESS = 3;
    uint constant MIN_BID_INCREMENT_PERCENTAGE = 5;
    bool public auctionEnded;
    bool public bidExtended;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Change the duration as needed
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid(uint bidAmount) external payable {
        require(!auctionEnded, "Auction has ended");
        require(block.timestamp < auctionEndTime, "Auction time expired");
        require(msg.value == bidAmount, "Sent ETH amount must match bid amount");
        require(bidAmount > highestBid, "Bid amount must be higher than current highest bid");
        require((bidAmount * 100) / highestBid >= 100 + MIN_BID_INCREMENT_PERCENTAGE, "Bid increment percentage not met");
        require(addressBidCount[msg.sender] < MAX_BIDS_PER_ADDRESS, "Exceeded maximum bid count per address");

        if (block.timestamp >= auctionEndTime - 5 minutes && !bidExtended) {
            auctionEndTime += 10 minutes;
            bidExtended = true;
        }

        highestBid = bidAmount;
        highestBidder = msg.sender;
        addressBids[msg.sender][addressBidCount[msg.sender]] = bidAmount;
        addressBidCount[msg.sender]++;

        emit NewHighestBid(msg.sender, bidAmount);
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");

        // Perform transfer to organizer
        payable(organizer).transfer(highestBid);
    }

    function endAuction() external onlyOrganizer {
        require(!auctionEnded, "Auction has already ended");

        auctionEnded = true;
        // Additional logic can be added for tie-breaking scenarios
    }
}
```