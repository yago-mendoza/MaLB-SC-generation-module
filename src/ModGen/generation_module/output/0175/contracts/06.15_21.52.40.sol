```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public totalBids;

    mapping(address => uint) public addressBidCount;
    mapping(uint => address) public bidIndex;
    mapping(address => uint) public bids;

    bool public auctionEnded;
    bool public extensionTriggered;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Auction duration set to 1 hour
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has already ended");
        _;
    }

    function placeBid() external payable auctionNotEnded {
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid must be at least 5% higher than the current highest bid");
        require(addressBidCount[msg.sender] < 3, "Maximum of 3 bids per address reached");

        if (block.timestamp >= auctionEndTime - 5 minutes && !extensionTriggered) {
            auctionEndTime += 10 minutes;
            extensionTriggered = true;
        }

        totalBids++;
        addressBidCount[msg.sender]++;
        bids[msg.sender] = msg.value;
        bidIndex[totalBids] = msg.sender;

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }

    function endAuction() external onlyOrganizer {
        require(!auctionEnded, "Auction has already ended");

        auctionEnded = true;
        auctionEndTime = block.timestamp;

        // Determine the winning bid in case of multiple bids with the same amount
        for (uint i = totalBids; i > 0; i--) {
            if (bids[bidIndex[i]] == highestBid) {
                highestBidder = bidIndex[i];
                break;
            }
        }
    }
}
```