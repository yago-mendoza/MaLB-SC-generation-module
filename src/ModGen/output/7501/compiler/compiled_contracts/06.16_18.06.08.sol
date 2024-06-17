// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketIdCounter;
    uint constant public MIN_BID_INCREMENT_PERCENTAGE = 5;
    uint constant public AUCTION_DURATION = 30 minutes;
    uint constant public BID_LOCK_DURATION = 10 minutes;

    struct Bid {
        address bidder;
        uint amount;
    }

    mapping(uint => Bid[]) public ticketBids;
    mapping(address => uint) public addressBidCount;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + AUCTION_DURATION;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid(uint _ticketId) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require((msg.value * 100) / highestBid >= MIN_BID_INCREMENT_PERCENTAGE, "Bid increment percentage not met");
        require(addressBidCount[msg.sender] < 3, "Address has reached maximum bid limit");

        if (block.timestamp > auctionEndTime - BID_LOCK_DURATION) {
            auctionEndTime += BID_LOCK_DURATION;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        addressBidCount[msg.sender]++;
        ticketBids[_ticketId].push(Bid(msg.sender, msg.value));
        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}