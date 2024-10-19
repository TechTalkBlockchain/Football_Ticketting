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

    // Custom Errors
    error NotAdmin();
    error TicketDoesNotExist();
    error NotTicketOwner();
    error ContractIsPaused(); // Renamed error to avoid conflict with the event
    error InvalidMatchId();
    error IncorrectEtherSent();
    error MaxTicketLimitReached();
    error TicketAlreadyUsed();
    error TicketPriceMustBeGreaterThanZero();
    error NoFundsToWithdraw();

    event TicketPurchased(address indexed buyer, uint256 ticketId, uint256 matchId);
    event TicketUsed(uint256 ticketId);
    event ContractPaused();
    event ContractUnpaused();

    modifier onlyAdmin() {
        if (msg.sender != admin) {
            revert NotAdmin();
        }
        _;
    }

    modifier validTicketId(uint256 ticketId) {
        if (ticketId >= nextTicketId) {
            revert TicketDoesNotExist();
        }
        _;
    }

    modifier onlyOwner(uint256 ticketId) {
        if (ownerOf(ticketId) != msg.sender) {
            revert NotTicketOwner();
        }
        _;
    }

    modifier whenNotPaused() {
        if (paused) {
            revert ContractIsPaused(); // Updated to use the renamed error
        }
        _;
    }

    constructor() ERC721("FootballMatchTicket", "FMT") {
        admin = msg.sender;
        paused = false;
    }

    function add
    function purchaseTicket(uint256 matchId) public payable whenNotPaused {
        if (msg.value != ticketPrice) {
            revert IncorrectEtherSent();
        }
        if (matchId <= 0) {
            revert InvalidMatchId();
        }
        if (nextTicketId >= MAX_TICKETS) {
            revert MaxTicketLimitReached();
        }

        uint256 ticketId = nextTicketId;
        nextTicketId++;

        _safeMint(msg.sender, ticketId);
        tickets[ticketId] = Ticket(matchId, msg.sender, false);

        emit TicketPurchased(msg.sender, ticketId, matchId);
    }

    function verifyTicket(uint256 ticketId) public onlyAdmin validTicketId(ticketId) onlyOwner(ticketId) whenNotPaused {
        if (tickets[ticketId].isUsed) {
            revert TicketAlreadyUsed();
        }

        tickets[ticketId].isUsed = true;

        emit TicketUsed(ticketId);
    }

    function setTicketPrice(uint256 _ticketPrice) external onlyAdmin whenNotPaused {
        if (_ticketPrice <= 0) {
            revert TicketPriceMustBeGreaterThanZero();
        }
        ticketPrice = _ticketPrice;
    }

    function getTicketPrice() external view onlyAdmin returns (uint256) {
        return ticketPrice;
    }

    function isValidTicket(uint256 ticketId) public view validTicketId(ticketId) returns (bool) {
        return tickets[ticketId].owner == ownerOf(ticketId) && !tickets[ticketId].isUsed;
    }

    function withdrawFunds() external onlyAdmin {
        if (address(this).balance == 0) {
            revert NoFundsToWithdraw();
        }
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
