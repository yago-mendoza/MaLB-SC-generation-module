pragma solidity ^0.8.0;

contract TokenSaleManagement {
    uint public totalTicketsAvailable = 50000;
    mapping(address => uint) public userTicketsPurchased;
    mapping(address => string) public userStatus;
    mapping(uint => uint) public ticketPrice;
    mapping(uint => bool) public ticketTransferred;
    bool public eventCancelled = false;
    uint public totalTicketsSold = 0;

    function purchaseTicket(uint _ticketQuantity) public {
        require(_ticketQuantity > 0, "Ticket quantity must be greater than 0");
        require(_ticketQuantity <= 3 || keccak256(abi.encodePacked(userStatus[msg.sender])) == keccak256(abi.encodePacked("Golden")), "Ticket quantity exceeded for non-Golden users");
        require(userTicketsPurchased[msg.sender] + _ticketQuantity <= 3, "Ticket quantity exceeded for Golden users");
        require(totalTicketsSold + _ticketQuantity <= totalTicketsAvailable, "Not enough tickets available");

        userTicketsPurchased[msg.sender] += _ticketQuantity;
        totalTicketsSold += _ticketQuantity;
    }

    function transferTicket(address _to, uint _ticketId) public {
        require(!eventCancelled, "Event has been cancelled, ticket transfer not allowed");
        require(ticketTransferred[_ticketId] == false, "Ticket has already been transferred");
        
        ticketTransferred[_ticketId] = true;
        userTicketsPurchased[msg.sender]--;
        userTicketsPurchased[_to]++;
    }

    function cancelEvent() public {
        eventCancelled = true;
    }

    function calculateRefund(address _user) public view returns (uint) {
        require(eventCancelled, "Event has not been cancelled");

        if (keccak256(abi.encodePacked(userStatus[_user])) == keccak256(abi.encodePacked("Golden"))) {
            return ticketPrice[_user] * 125 / 100;
        } else if (keccak256(abi.encodePacked(userStatus[_user])) == keccak256(abi.encodePacked("Platinum"))) {
            return ticketPrice[_user] * 105 / 100;
        } else {
            return ticketPrice[_user];
        }
    }
}