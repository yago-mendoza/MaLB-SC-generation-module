pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public minBidIncrease;
    uint public auctionDuration;
    uint public extensionDuration;
    bool public auctionEnded;
    mapping(address => uint) public addressToBidCount;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _bidIncrementPercentage, uint _auctionDuration, uint _extensionDuration) {
        organizer = msg.sender;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        auctionEndTime = block.timestamp + auctionDuration;
        highestBid = 0;
        auctionEnded = false;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }

    function placeBid() public payable onlyDuringAuction {
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid + minBidIncrease, "Bid amount must be at least 5% higher than current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum of 3 bids per address reached");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        addressToBidCount[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() public onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");

        auctionEnded = true;
        // Transfer funds to the organizer
        payable(organizer).transfer(highestBid);
    }
}