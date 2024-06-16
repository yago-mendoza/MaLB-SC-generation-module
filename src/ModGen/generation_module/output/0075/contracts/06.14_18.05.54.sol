pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressToBidCount;
    mapping(address => mapping(uint => uint)) public addressToBids;
    uint public bidCount;
    uint public auctionEndTime;
    bool public auctionEnded;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        highestBid = 0;
        highestBidder = address(0);
        bidCount = 0;
        auctionEndTime = block.timestamp + 3600; // 1 hour auction duration
        auctionEnded = false;
    }

    function placeBid(uint amount) public {
        require(!auctionEnded, "Auction has ended");
        require(msg.sender != organizer, "Organizer cannot bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        require(amount >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");

        addressToBidCount[msg.sender]++;
        bidCount++;
        addressToBids[msg.sender][addressToBidCount[msg.sender]] = amount;

        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, amount);
        }

        if (block.timestamp > auctionEndTime - 300) {
            auctionEndTime += 600; // Extend auction by 10 minutes
        }
    }

    function withdraw() public {
        require(msg.sender == organizer, "Only organizer can withdraw");
        require(auctionEnded, "Auction has not ended");

        auctionEnded = true;
        // Transfer funds to organizer
    }
}