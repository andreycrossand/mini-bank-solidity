# MiniBank Smart Contract

A decentralized mini-bank smart contract built with Solidity. It features a time-based reward system, a referral program, dynamic withdrawal fees, and robust admin security controls.

## 🚀 Key Features

### 1. User Registration & Referral System
* **Paid Registration:** Users must pay a registration fee (`0.01 ETH`). Any excess ETH sent during registration is automatically refunded.
* **Referral Discounts:** Users registering with a valid referrer's address get a 25% discount on the registration fee (`0.0075 ETH`).
* **Referral Rewards:** Referrers automatically receive 20% of the bank's profit fee whenever their referrals withdraw funds.

### 2. Deposits & Rewards
* **Time-Locked Actions:** A mandatory 10-minute cooldown is applied between deposits and withdrawals to prevent spam.
* **Interval Rewards:** Users earn a **3% reward** on their balance for every completed 10-minute interval.
* **Deposit Limits:** Maximum deposit is capped at `5 ETH` per user to manage contract liquidity risks.

### 3. Withdrawals
* **Dynamic Fees:** 
  * Standard fee: **5%**
  * VIP fee (balances >= 2 ETH): **1%**
* **Emergency Withdrawals:** Users can bypass standard checks in an emergency, subject to a strict **10% penalty fee**.

### 4. Admin & Security Controls
* **Pausable Architecture:** The contract owner can halt all core functions (deposits, withdrawals, registrations) in case of an emergency.
* **Blacklist:** The owner can block malicious addresses from interacting with the bank.
* **Profit Claiming:** The owner can safely withdraw accumulated bank profits (registration fees + withdrawal fees) without touching user deposits.

## 🛠 Tech Stack
* **Solidity:** `^0.8.28`

## 🔐 Security Considerations
* Protection against self-referrals and non-existent referrers.
* Proper state updates before external calls (Checks-Effects-Interactions pattern).
* Graceful handling of excess `msg.value` to prevent stuck ETH.