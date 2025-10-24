# **SettleX**

**SettleX** is the first **confidential, compliant, and chain-agnostic clearing and settlement layer** for fungible tokens.  

Instead of bridging gross amounts across chains, SettleX **nets cross-chain obligations and settles only the net delta**, reducing bridging and rebalancing costs by up to **90%**.  

This repository contains the **Base Batches alpha build**, showcasing how SettleX reduces bridging volume and improves capital efficiency by performing cross-chain netting between **Base** 
and other chains.

---

## 🧩 **Repository Structure**

```
SettleX_Base_Batches/
│
├── ABI/                  # Compiled ABI files for Hub, Spoke, Stablecoin, and TokenPool contracts
│
├── SmartContract/        # Solidity contracts and Foundry setup
│   ├── src/              # Core contract logic (Hub, Spoke, TokenPool, Stablecoin)
│   ├── script/           # Deployment and verification scripts
│   ├── foundry.toml      # Foundry configuration
│   └── .gitignore        # Build and cache ignores
│
├── FrontEnd/             # Next.js frontend integrating smart contracts
│   ├── components/       # UI components for interaction
│   ├── pages/            # App routing and dashboard views
│   ├── utils/            # Contract interaction logic and hooks
│   └── package.json      # Frontend dependencies
│
├── .gitmodules           # External libraries (e.g., OpenZeppelin)
├── .gitattributes
└── README.md
```
---


## 🚀 Demo Overview

In this demo, SettleX performs cross-chain netting between Base and Fuji testnets.

Scenario:

10,000 USDT transferred from Base → Fuji

9,500 USDT transferred from Fuji → Base

Instead of bridging 19,500 USDT, SettleX bridges only 500 USDT, reducing bridging volume by 97%.

This validates SettleX’s netting algorithm and showcases the efficiency of settlement batching across chains.

---
## ⚙️ Tech Stack

Smart Contracts: Solidity (Foundry)

Frontend: Next.js (TypeScript)

Messaging/Interoperability: Concero

Libraries: OpenZeppelin Contracts

---

## 🧠 Core Components

Hub Contract: Maintains global netting state and settlement logic across connected chains.

Spoke Contract: Deployed on each chain to aggregate obligations before netting via Hub.

Stablecoin Contract (Mock): Used for testnet simulations and settlement examples.

TokenPool Contract: Manages liquidity and ensures delta settlements are bridged efficiently.

---

## 📖 Contract Addresses

Hub Contract: (0x7D9f7b6dAA5407bFd4A935aae48c64aa0FE69bcb)(https://sepolia.arbiscan.io/address/0x7D9f7b6dAA5407bFd4A935aae48c64aa0FE69bcb)

Spoke Contract: [0x91e2E34718EFD173389c7876BBBb57594cE27e37](https://sepolia.basescan.org/address/0x91e2E34718EFD173389c7876BBBb57594cE27e37)

TokenPool Contract: [0x45Ead4ED7Ae622a6B99A124b85d93c496B1CbAa8](https://sepolia.basescan.org/address/0x45Ead4ED7Ae622a6B99A124b85d93c496B1CbAa8)

Stablecoin Contract: [0x0b8C9Cf4F43811D9A22Be732AbE81617D4BD4183](https://sepolia.basescan.org/address/0x0b8C9Cf4F43811D9A22Be732AbE81617D4BD4183)

---

## 🧪 Setup and Deployment
**1. Clone the repository**
```bash
git clone https://github.com/AAYUSH-GUPTA-coder/SettleX_Base_Batches.git
cd SettleX_Base_Batches
```

**2. Install dependencies**
```bash
cd SmartContract
forge install
```
For frontend:
```bash
cd ../FrontEnd
bun install
```

**3. Compile contracts**
```bash
forge build
```

**4. Deploy contracts**
Use Foundry scripts to deploy Hub and Spoke contracts:

```bash
forge script script/Spoke/Base/Setter/Deploy/DeploySpokeBase.s.sol:DeploySpokeBase --account defaultKey --sender $WALLET_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast -vvv
```

5. Run the frontend
```bash
bun run dev
```

---

## 🧾 Example Workflow

1. User submits cross-chain transfers (e.g., Base → Fuji).
2. SettleX aggregates and nets obligations using the Hub and Spoke contracts.
3. Only the net delta is bridged, significantly reducing gas and transfer volume.
4. Settlement confirmations are displayed in the frontend dashboard.

---

## 🔒 Key Features

1. Cross-chain Netting: Aggregates obligations across chains and settles the net delta.
2. Capital Efficiency: Reduces bridging and rebalancing costs by up to 90%.
3. Modular Design: Works with bridges, solver networks, and liquidity pools.

---

## 🤝 Credits & Contributors
- Aayush Gupta – Founder & Smart Contract Developer
- Suvraneel Bhuin – Co-founder & Full-stack Engineer
- Harsh Nimbhorker – UI/UX Developer

---

## 🌐 Learn More

Website: https://www.settlex.fi

Twitter: https://twitter.com/SettleX_build

Linkedin: https://www.linkedin.com/company/settlex

Demo Video: https://youtu.be/D9KFmyzSH1A

Team Intro Video: https://youtu.be/DA9IuXNV8PA

---

## ⚠️ Disclaimer

This is not the original repository of the working SettleX protocol.

We have intentionally removed key components of the proprietary netting algorithm, which forms the core of our product’s unique value proposition and remains confidential.

As we are currently participating in accelerator programs and preparing for a seed funding round, the production repository is private and cannot be shared or made public at this stage.
