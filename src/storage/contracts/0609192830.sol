pragma solidity ^0.8.0;

contract TokenSaleManagement {
    uint public totalTicketsAvailable = 50000;
    uint public totalTicketsSold;
    address public owner;

    enum UserStatus {Golden, Platinum, Bronze}

    struct Ticket {
        address holder;
        UserStatus status;
    }

    mapping(uint => Ticket) public tickets;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    function purchaseTicket(UserStatus _status) public {
        require(totalTicketsSold < totalTicketsAvailable, "No more tickets available");
        
        tickets[totalTicketsSold] = Ticket(msg.sender, _status);
        totalTicketsSold++;
    }

    function transferTicket(uint _ticketId, address _newHolder) public {
        require(tickets[_ticketId].holder == msg.sender, "You do not own this ticket");
        
        tickets[_ticketId].holder = _newHolder;
    }

    function refundTicket(uint _ticketId) public onlyOwner {
        delete tickets[_ticketId];
        totalTicketsSold--;
    }
}