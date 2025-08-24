Time-Locked Wallet Smart Contract

Overview

This Clarity smart contract implements a time-locked wallet that allows users to securely deposit STX tokens with an enforced unlock height (block number). Funds can only be withdrawn after the unlock block is reached, ensuring security for long-term holding, trust-based agreements, or delayed payouts.

The contract supports:

Creating new time-locked wallets.

Depositing additional funds into an existing wallet.

Withdrawing funds partially or fully once the unlock height is reached.

Querying wallet details, balances, and unlock conditions.

Features

Time Locking: Funds are locked until a specified block height.

Secure Deposits: Only the wallet owner can deposit and withdraw funds.

Partial & Full Withdrawals: Owners can withdraw specific amounts or their entire balance once unlocked.

Read-Only Queries: Functions allow external contracts or users to check wallet status, balances, and remaining time.

Error Handling: Covers invalid block heights, insufficient funds, unauthorized access, and active locks.

Error Codes

ERR_UNAUTHORIZED (u100) → Caller is not authorized.

ERR_INSUFFICIENT_FUNDS (u101) → Not enough balance or invalid deposit.

ERR_WALLET_NOT_FOUND (u102) → Wallet does not exist.

ERR_TIME_LOCK_ACTIVE (u103) → Unlock height has not yet been reached.

ERR_INVALID_BLOCK_HEIGHT (u104) → Unlock height must be greater than current block height.

Contract Functions
🔐 Public Functions

create-wallet (unlock-height uint) (initial-deposit uint)
Create a wallet with an unlock block height and initial deposit.

deposit (amount uint)
Add funds to an existing wallet.

withdraw (amount uint)
Withdraw a specified amount after unlock height is reached.

withdraw-all
Withdraw entire balance and delete the wallet entry after unlock height is reached.

📖 Read-Only Functions

get-wallet-info (owner principal) → Returns full wallet data (balance, unlock height, creation block).

get-wallet-balance (owner principal) → Returns wallet balance.

get-unlock-height (owner principal) → Returns unlock block height.

is-wallet-unlocked (owner principal) → Checks if the wallet is currently unlocked.

get-blocks-until-unlock (owner principal) → Returns blocks remaining until unlock.

Example Workflow

Create a wallet:

(contract-call? .time-locked-wallet create-wallet u12000 u5000000)


→ Creates a wallet unlocking at block 12000 with an initial deposit of 5,000,000 microSTX.

Deposit more funds:

(contract-call? .time-locked-wallet deposit u2000000)


→ Adds 2,000,000 microSTX to the wallet.

Check balance & unlock status:

(contract-call? .time-locked-wallet get-wallet-balance tx-sender)
(contract-call? .time-locked-wallet is-wallet-unlocked tx-sender)


Withdraw once unlocked:

(contract-call? .time-locked-wallet withdraw u1000000)


→ Withdraws 1,000,000 microSTX if unlocked.

Withdraw all funds & close wallet:

(contract-call? .time-locked-wallet withdraw-all)

Use Cases

Savings Vault: Users can lock funds for a period to enforce disciplined saving.

Trustless Escrow: Parties can deposit funds that unlock only after a pre-agreed block height.

Delayed Payouts: Employers, DAOs, or protocols can set future block releases for salaries, rewards, or grants.

Security Considerations

Only the wallet owner can deposit or withdraw funds.

Unlock height must always be greater than current block height.

Contract enforces balance checks before withdrawal.

Once withdrawn completely, the wallet entry is deleted to prevent stale data.

Deployment

Compile the contract with Clarinet
:

clarinet check


Deploy to a local Devnet or Testnet:

clarinet deploy

License

This project is licensed under the MIT License.