// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract FootballTicketBooking is ERC721 {
    uint256 public nextTicketId;
    uint256 public constant MAX_TICKETS = 10000;
    uint256 public ticketPrice = 0.05 ether;

    address public admin;  
    bool public paused;    
    mapping(uint256 => Ticket) public tickets;

    struct Ticket {
        uint256 matchId;
        address owner;
        bool isUsed;  
    }

    event TicketPurchased(address indexed buyer, uint256 ticketId, uint256 matchId);
    event TicketUsed(uint256 ticketId);
    event ContractPaused();
    event ContractUnpaused();

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the admin");
        _;
    }

    modifier validTicketId(uint256 ticketId) {
        require(ticketId < nextTicketId, "Ticket does not exist");
        _;
    }

    modifier onlyOwner(uint256 ticketId) {
        require(ownerOf(ticketId) == msg.sender, "You do not own this ticket");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor() ERC721("FootballMatchTicket", "FMT") {
        admin = msg.sender; 
        paused = false;      
    }

    
    function addMatch(uint256 matchId) view public onlyAdmin whenNotPaused {
        require(matchId > 0, "Invalid match ID");
    }

    function purchaseTicket(uint256 matchId) public payable whenNotPaused {
        require(msg.value == ticketPrice, "Incorrect Ether sent");
        require(matchId > 0, "Invalid match ID");
        require(nextTicketId < MAX_TICKETS, "Max ticket limit reached");

        uint256 ticketId = nextTicketId;
        nextTicketId++;

        _safeMint(msg.sender, ticketId);
        tickets[ticketId] = Ticket(matchId, msg.sender, false); 

        emit TicketPurchased(msg.sender, ticketId, matchId);
    }

    function verifyTicket(uint256 ticketId) public onlyAdmin validTicketId(ticketId) onlyOwner(ticketId) whenNotPaused {
        require(!tickets[ticketId].isUsed, "Ticket has already been used");
        
        tickets[ticketId].isUsed = true;
        
        emit TicketUsed(ticketId);
    }

    function setTicketPrice(uint256 _ticketPrice) external onlyAdmin whenNotPaused {
        require(_ticketPrice > 0, "Ticket price must be greater than 0");
        ticketPrice = _ticketPrice;
    }

    function getTicketPrice() external view onlyAdmin returns (uint256) {
        return ticketPrice;
     }

    function isValidTicket(uint256 ticketId) public view validTicketId(ticketId) returns (bool) {
        return tickets[ticketId].owner == ownerOf(ticketId) && !tickets[ticketId].isUsed;
    }

    function withdrawFunds() external onlyAdmin {
        require(address(this).balance > 0, "No funds to withdraw");
        payable(admin).transfer(address(this).balance);
    }

    function pause() external onlyAdmin {
        paused = true;
        emit ContractPaused();
    }

    function unpause() external onlyAdmin {
        paused = false;
        emit ContractUnpaused();
    }

    receive() external payable {
        revert("Use purchaseTicket function");
    }
}
