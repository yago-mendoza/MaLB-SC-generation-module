pragma solidity ^0.8.0;

contract TokenSaleManagement {
    uint public totalTicketsAvailable = 50000;
    mapping(address => uint) public userTicketsPurchased;
    mapping(address => string) public userStatus;
    mapping(uint => bool) public ticketTransferred;
    bool public eventCancelled = false;
    
    function purchaseTicket(uint _numTickets, string memory _status) public {
        require(_numTickets > 0, "Number of tickets must be greater than 0");
        require(_numTickets <= 3 || keccak256(abi.encodePacked(_status)) == keccak256(abi.encodePacked("Golden")), "Ticket purchase limit exceeded for non-Golden status users");
        require(totalTicketsAvailable >= _numTickets, "Not enough tickets available");
        
        if(keccak256(abi.encodePacked(_status)) == keccak256(abi.encodePacked("Golden"))) {
            require(userTicketsPurchased[msg.sender] + _numTickets <= 3, "Golden status users can purchase up to 3 tickets only");
        } else {
            require(userTicketsPurchased[msg.sender] + _numTickets <= 1, "Non-Golden status users can purchase only 1 ticket");
        }
        
        userTicketsPurchased[msg.sender] += _numTickets;
        totalTicketsAvailable -= _numTickets;
    }
    
    function transferTicket(address _to, uint _ticketId) public {
        require(!eventCancelled, "Ticket transfer not allowed after event cancellation");
        require(userTicketsPurchased[msg.sender] > 0, "No tickets to transfer");
        require(!ticketTransferred[_ticketId], "Ticket already transferred");
        
        userTicketsPurchased[msg.sender]--;
        userTicketsPurchased[_to]++;
        ticketTransferred[_ticketId] = true;
    }
    
    function cancelEvent() public {
        eventCancelled = true;
    }
}

contract TicketPurchaseLimitations {
    uint public totalTicketsAvailable = 50000;
    mapping(address => uint) public userTicketsPurchased;
    
    function purchaseTicket(uint _numTickets, string memory _status) public {
        require(_numTickets > 0, "Number of tickets must be greater than 0");
        require(_numTickets <= 3 || keccak256(abi.encodePacked(_status)) == keccak256(abi.encodePacked("Golden")), "Ticket purchase limit exceeded for non-Golden status users");
        require(totalTicketsAvailable >= _numTickets, "Not enough tickets available");
        
        if(keccak256(abi.encodePacked(_status)) == keccak256(abi.encodePacked("Golden"))) {
            require(userTicketsPurchased[msg.sender] + _numTickets <= 3, "Golden status users can purchase up to 3 tickets only");
        } else {
            require(userTicketsPurchased[msg.sender] + _numTickets <= 1, "Non-Golden status users can purchase only 1 ticket");
        }
        
        userTicketsPurchased[msg.sender] += _numTickets;
        totalTicketsAvailable -= _numTickets;
    }
}