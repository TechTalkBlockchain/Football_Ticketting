# Football Ticket Booking System

## Overview

The **Football Ticket Booking** system is a decentralized application (dApp) built on Ethereum that allows users to purchase tickets for football matches as NFTs (ERC721 tokens). Admins can manage ticket prices, pause the contract, and verify tickets. Users can purchase tickets using Ether and verify ownership through the blockchain. The contract also supports withdrawal of funds by the admin.

Key features:
- Ticket purchase as ERC721 NFTs.
- Admin-managed ticket prices and contract states (pause/unpause).
- Ticket verification system to ensure tickets are valid and unused.
- Maximum cap of 10,000 tickets.
- Admin withdrawal of collected funds.

## Smart Contract Details

- **Name**: FootballMatchTicket (ERC721)
- **Symbol**: FMT
- **Ticket Price**: 0.05 ETH (modifiable by the admin)
- **Max Tickets**: 10,000
- **Admin**: The contract deployer (can manage ticket prices, pause/unpause the contract, verify tickets, and withdraw funds).

## Installation

1. Clone the repository:
   ```bash
   git clone 
   cd 
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Compile the smart contract:
   ```bash
   npx hardhat compile
   ```

## Running the Tests

The project includes unit tests to verify the functionality of the smart contract. Tests cover the following features:
- Ticket purchase
- Ticket verification
- Admin management (setting ticket price, pausing/unpausing contract)
- Funds withdrawal

To run the tests:

1. Start a local Ethereum network for testing:
   ```bash
   npx hardhat node
   ```

2. Run the tests:
   ```bash
   npx hardhat test
   ```

### Test Coverage

The tests include:
- **Deployment Tests**: Verifies correct admin and initial ticket price.
- **Ticket Purchase**: Tests successful and failed purchases based on various conditions (e.g., incorrect Ether, invalid match ID).
- **Ticket Verification**: Ensures that only the admin can verify tickets and checks if a ticket is already used.
- **Admin Actions**: Tests ticket price changes, pausing/unpausing the contract, and funds withdrawal.
  
## Smart Contract Breakdown

The smart contract includes the following functionality:

### 1. `purchaseTicket(uint256 matchId)`
Allows users to purchase a ticket for a specific match by sending the required amount of Ether (0.05 ETH by default). The purchased ticket is minted as an ERC721 token.

### 2. `verifyTicket(uint256 ticketId)`
Admin-only function that allows the admin to mark a ticket as "used" after being checked at a venue. A ticket can only be used once.

### 3. `setTicketPrice(uint256 _ticketPrice)`
Allows the admin to update the ticket price. The price must be greater than 0.

### 4. `pause()` and `unpause()`
Admin-only functions to pause and unpause the contract, preventing ticket purchases while paused.

### 5. `withdrawFunds()`
Allows the admin to withdraw Ether from the contract balance.

### Custom Errors
The contract uses custom errors for gas optimization:
- `NotAdmin()`: Thrown when a non-admin attempts to perform an admin-only action.
- `TicketDoesNotExist()`: Thrown when accessing a non-existent ticket.
- `NotTicketOwner()`: Thrown when an operation is attempted by someone other than the ticket owner.
- `ContractIsPaused()`: Thrown when actions are attempted while the contract is paused.
- `InvalidMatchId()`: Thrown when an invalid match ID is provided.
- `IncorrectEtherSent()`: Thrown when the wrong amount of Ether is sent during ticket purchase.
- `MaxTicketLimitReached()`: Thrown when attempting to purchase more than the maximum allowed tickets.
- `TicketAlreadyUsed()`: Thrown when attempting to verify an already used ticket.
- `TicketPriceMustBeGreaterThanZero()`: Thrown when trying to set a ticket price of zero or less.
- `NoFundsToWithdraw()`: Thrown when attempting to withdraw funds, but the contract balance is zero.

## Deployment

1. Set up your environment:
   - Get your private key for deploying contracts on an Ethereum network (e.g., via MetaMask).
   - Add an Infura/Alchemy API URL for network access.

2. Deploy to a network (e.g., Rinkeby):
   ```bash
   npx hardhat run scripts/deploy.js --network rinkeby
   ```


3. Verify the contract (optional):
   After deploying, you can verify the contract on Etherscan using Hardhat’s Etherscan plugin:
   ```bash
   npx hardhat verify --network rinkeby <DEPLOYED_CONTRACT_ADDRESS>
   ```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

This README provides all the essential details to understand, install, and test the Football Ticket Booking system. If you need any adjustments, feel free to ask!