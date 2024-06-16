pragma solidity ^0.8.0;

contract TokenSaleManagement {
    uint public ticketsAvailable = 50000;
    enum UserStatus {Golden, Platinum, Bronze}
    mapping(address => uint) public userTicketsPurchased;

    function purchaseTicket(uint _numTickets) public {
        require(_numTickets <= 3 || userTicketsPurchased[msg.sender] == 0, "Ticket purchase limit exceeded");
        require(_numTickets + userTicketsPurchased[msg.sender] <= 3, "Cannot purchase more than 3 tickets");
        
        userTicketsPurchased[msg.sender] += _numTickets;
        ticketsAvailable -= _numTickets;
    }

    function transferTicket(address _to, uint _numTickets) public {
        require(userTicketsPurchased[msg.sender] >= _numTickets, "Not enough tickets to transfer");
        require(userTicketsPurchased[_to] + _numTickets <= 3, "Recipient cannot hold more than 3 tickets");
        
        userTicketsPurchased[msg.sender] -= _numTickets;
        userTicketsPurchased[_to] += _numTickets;
    }

    function refundTicket(uint _numTickets) public {
        require(userTicketsPurchased[msg.sender] >= _numTickets, "Not enough tickets to refund");
        
        userTicketsPurchased[msg.sender] -= _numTickets;
        ticketsAvailable += _numTickets;
    }
}

contract TicketPurchaseLimitations {
    uint public ticketsAvailable = 50000;
    enum UserStatus {Golden, NonGolden}
    mapping(address => uint) public userTicketsPurchased;

    function purchaseTicket(uint _numTickets) public {
        require(_numTickets <= 3 || userTicketsPurchased[msg.sender] == 0, "Ticket purchase limit exceeded");
        require(_numTickets + userTicketsPurchased[msg.sender] <= 3, "Cannot purchase more than 3 tickets");
        
        userTicketsPurchased[msg.sender] += _numTickets;
        ticketsAvailable -= _numTickets;
    }

    function transferTicket(address _to, uint _numTickets) public {
        require(userTicketsPurchased[msg.sender] >= _numTickets, "Not enough tickets to transfer");
        require(userTicketsPurchased[_to] + _numTickets <= 3, "Recipient cannot hold more than 3 tickets");
        
        userTicketsPurchased[msg.sender] -= _numTickets;
        userTicketsPurchased[_to] += _numTickets;
    }
}

contract GoldenUserTicketTransfer {
    uint public totalTicketsSold;
    mapping(address => uint) public ticketsPurchased;
    mapping(uint => address) public ticketOwners;

    function purchaseTicket(uint _numTickets) public {
        require(_numTickets <= 3 || ticketsPurchased[msg.sender] == 0, "Ticket purchase limit exceeded");
        require(_numTickets + ticketsPurchased[msg.sender] <= 3, "Cannot purchase more than 3 tickets");
        
        ticketsPurchased[msg.sender] += _numTickets;
        totalTicketsSold += _numTickets;
        
        for(uint i = totalTicketsSold - _numTickets + 1; i <= totalTicketsSold; i++) {
            ticketOwners[i] = msg.sender;
        }
    }

    function transferTicket(address _to, uint _numTickets) public {
        require(ticketsPurchased[msg.sender] >= _numTickets, "Not enough tickets to transfer");
        
        for(uint i = totalTicketsSold - ticketsPurchased[msg.sender] + 1; i <= totalTicketsSold; i++) {
            if(ticketOwners[i] == msg.sender) {
                ticketOwners[i] = _to;
            }
        }
    }
}

contract TicketTransferMechanism {
    mapping(uint => address) public ticketOwners;

    function transferTicket(address _to, uint _ticketId) public {
        require(ticketOwners[_ticketId] == msg.sender, "You do not own this ticket");
        
        ticketOwners[_ticketId] = _to;
    }
}