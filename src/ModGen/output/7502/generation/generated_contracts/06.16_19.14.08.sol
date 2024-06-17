// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public bidIncrement;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public numBidsPerAddress;

    mapping(address => uint) public numBids;
    mapping(address => uint[]) public bidsByAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _auctionDuration, uint _extensionDuration, uint _numBidsPerAddress) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        numBidsPerAddress = _numBidsPerAddress;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(msg.value >= highestBid + bidIncrement, "Bid increment not met");
        require(numBids[msg.sender] < numBidsPerAddress, "Exceeded maximum number of bids per address");

        if (block.timestamp > auctionEndTime - extensionDuration) {
            auctionEndTime += extensionDuration;
        }

        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }

        numBids[msg.sender]++;
        bidsByAddress[msg.sender].push(msg.value);
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        payable(organizer).transfer(address(this).balance);
    }
}