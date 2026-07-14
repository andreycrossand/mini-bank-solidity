# Mini Bank Smart Contract

A secure and modular decentralized banking system built on Ethereum using Solidity. This project implements a user-based accounting system, allowing for registration, deposits, and secure withdrawals.

## Features

- **User Registration**: Each user gets a unique, incremental ID mapped to their wallet address.
- **Role-Based Access**: Distinguishes between the contract owner (admin) and regular visitors.
- **Deposit System**: Users can deposit ETH, which is tracked internally in the contract.
- **Secure Withdrawals**: Implements the Checks-Effects-Interactions pattern to prevent reentrancy attacks.
- **Event Logging**: Emits events for major actions (Deposit/Withdraw) for easy tracking.

## Technical Details

- **Language**: Solidity ^0.8.28
- **Security**: 
    - Custom error handling for gas efficiency.
    - Protected against reentrancy attacks.
    - Access control via modifiers.

## How to Deploy

1. Open [Remix IDE](https://remix.ethereum.org/).
2. Create a new file `MiniBank.sol` and paste the contract code.
3. Compile using the **0.8.28** compiler version.

## License

This project is licensed under the MIT License.
