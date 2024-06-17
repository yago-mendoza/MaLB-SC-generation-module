// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;

    mapping(address => uint) public addressToBidCount;
    mapping(uint => address) public bidIndexToBidder;
    uint public totalBids;
    uint public bidIncrementPercentage = 5;
    uint public minBidIncrease;
    bool public auctionEnded;
    bool public bidExtensionActive;
    uint public constant maxBidsPerAddress = 3;
    uint public constant auctionDuration = 30 minutes;
    uint public constant bidLockDuration = 10 minutes;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        auctionEndTime = block.timestamp + auctionDuration;
        highestBid = 0;
        minBidIncrease = 0;
        auctionEnded = false;
        bidExtensionActive = false;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(!auctionEnded, "Auction has ended");
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid + minBidIncrease, "Bid amount must be at least 5% higher than current highest bid");
        require(addressToBidCount[msg.sender] < maxBidsPerAddress, "Maximum 3 bids per address reached");

        if (block.timestamp > auctionEndTime - 5 minutes && !bidExtensionActive) {
            auctionEndTime += bidLockDuration;
            bidExtensionActive = true;
        }

        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }

        totalBids++;
        bidIndexToBidder[totalBids] = msg.sender;
        addressToBidCount[msg.sender]++;

        if (addressToBidCount[msg.sender] >= maxBidsPerAddress) {
            // Prevent further bids from this address
            addressToBidCount[msg.sender] = maxBidsPerAddress;
        }
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }

    function endAuction() external onlyOrganizer {
        require(!auctionEnded, "Auction has already ended");
        auctionEnded = true;
        auctionEndTime = block.timestamp;
    }
}