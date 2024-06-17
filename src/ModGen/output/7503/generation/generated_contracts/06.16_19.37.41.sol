// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public auctionDuration = 30 minutes;
    uint public auctionExtension = 10 minutes;

    mapping(address => uint) public addressBidCount;
    mapping(address => mapping(uint => uint)) public addressBids;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    function placeBid() external payable {
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(msg.sender != organizer, "Organizer cannot bid");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += auctionExtension;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        addressBids[msg.sender][addressBidCount[msg.sender]] = msg.value;
        addressBidCount[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}