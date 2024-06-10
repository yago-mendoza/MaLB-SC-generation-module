pragma solidity ^0.8.0;

contract TokenSaleManagement {
    uint public totalTicketsAvailable = 50000;
    mapping(address => uint) public userTicketsPurchased;
    mapping(address => uint) public userTicketsTransferred;
    mapping(address => bool) public isGoldenUser;
    mapping(uint => address) public ticketOwner;
    
    enum UserStatus { Golden, Platinum, Bronze }
    
    event TicketPurchased(address indexed user, uint amount);
    event TicketTransferred(address indexed from, address indexed to, uint amount);
    
    function purchaseTicket() public {
        require(userTicketsPurchased[msg.sender] == 0, "You can only purchase one ticket");
        
        if(isGoldenUser[msg.sender]) {
            require(userTicketsTransferred[msg.sender] <= 2, "Golden status users can purchase and transfer up to three tickets");
        }
        
        require(totalTicketsAvailable > 0, "No tickets available for purchase");
        
        userTicketsPurchased[msg.sender]++;
        totalTicketsAvailable--;
        ticketOwner[userTicketsPurchased[msg.sender]] = msg.sender;
        
        emit TicketPurchased(msg.sender, 1);
    }
    
    function transferTicket(address to) public {
        require(userTicketsPurchased[msg.sender] > 0, "You have not purchased any tickets");
        
        if(isGoldenUser[msg.sender]) {
            require(userTicketsTransferred[msg.sender] < 3, "Golden status users can transfer up to three tickets");
        }
        
        require(userTicketsPurchased[to] == 0, "Recipient already has a ticket");
        
        userTicketsPurchased[to]++;
        userTicketsTransferred[msg.sender]++;
        userTicketsPurchased[msg.sender]--;
        ticketOwner[userTicketsPurchased[to]] = to;
        
        emit TicketTransferred(msg.sender, to, 1);
    }
}