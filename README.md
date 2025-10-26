# MEGA Blockscout - Make Ethereum Great Again 🚀

**Live Demo**: [https://ethglobal-blockscout.roax.network/](https://ethglobal-blockscout.roax.network/)

MEGA Blockscout revolutionizes blockchain exploration by transforming the traditional explorer into a comprehensive development and monitoring platform for the Ethereum ecosystem.

## 🌟 The Problem We Solve

Traditional open-source Blockscout is limited to execution client RPC calls, providing only a partial view of blockchain activity. Developers and validators need multiple tools to:
- Monitor validator performance
- Access beacon chain data
- Write and test smart contracts
- Deploy contracts to the blockchain
- Track transaction history
- Debug contract interactions

This fragmented experience slows down development and makes blockchain monitoring unnecessarily complex.

## 💡 Our Solution: MEGA Blockscout

MEGA Blockscout is an **all-in-one blockchain development platform** that integrates:

### 🔍 **Validator APIs with Lighthouse Integration**
- Full beacon chain data access through Lighthouse consensus client
- Real-time validator performance metrics
- Attestation and proposal tracking
- Slashing detection and alerts
- Complete consensus layer visibility alongside execution data

### 💻 **Integrated Smart Contract IDE**
- **Write**: Full-featured Solidity code editor with syntax highlighting
- **Compile**: In-browser Solidity compilation
- **Deploy**: Direct contract deployment through MetaMask integration
- **Verify**: Automatic contract verification upon deployment
- **Interact**: Test and debug contracts directly in the explorer

### 📊 **Blockscout SDK Integration**
- Real-time transaction monitoring
- WebSocket subscriptions for live updates
- Advanced querying capabilities
- Transaction history aggregation
- Custom event filtering and notifications

## 🎯 Why All-in-One Matters

Every blockchain project needs:

1. **Development Tools**: Instead of switching between Remix, explorers, and deployment scripts, developers can write, test, and deploy contracts in one place.

2. **Monitoring Capabilities**: Projects need to track their contracts, monitor validator performance, and analyze on-chain activity - all available in MEGA Blockscout.

3. **User Transparency**: End users can verify contracts, track transactions, and understand validator behavior without technical expertise.

4. **Reduced Complexity**: One platform replaces 5-10 separate tools, reducing infrastructure costs and maintenance overhead.

5. **Faster Iteration**: The integrated environment enables rapid prototyping and deployment, accelerating project development cycles.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/roax-scout-deployment.git
cd roax-scout-deployment

# Navigate to docker-compose directory
cd docker-compose

# Start all services
docker-compose up -d

# Access at http://localhost
```

## 🐳 Docker Images

- Frontend: `darkartistry/blockscout-frontend:validator`
- Backend: `darkartistry/blockscout:validator`

Both images include all MEGA enhancements and are production-ready.

## ⚙️ Configuration

Edit environment files in `docker-compose/envs/` before deployment:

### Backend Configuration (`common-blockscout.env`):
```bash
# Execution Layer RPC
ETHEREUM_JSONRPC_HTTP_URL=https://your-execution-rpc

# Beacon Chain API (Lighthouse)
INDEXER_BEACON_RPC_URL=https://your-lighthouse-beacon-api

# Enable Validator Features
VALIDATOR_APIS_ENABLED=true
BEACON_CHAIN_INTEGRATION=true
```

### Frontend Configuration (`common-frontend.env`):
```bash
# Enable MEGA Features
NEXT_PUBLIC_CONTRACT_EDITOR_ENABLED=true
NEXT_PUBLIC_VALIDATORS_CHAIN_TYPE=beacon
NEXT_PUBLIC_SDK_ENABLED=true

# Wallet Integration
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your-project-id
```

## 📦 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    MEGA Blockscout                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐ │
│  │   Frontend  │  │   Backend    │  │  Smart Contract│ │
│  │   Next.js   │  │   Elixir     │  │     IDE       │ │
│  │  + SDK Int. │  │ + Validator  │  │   Solidity    │ │
│  └──────┬──────┘  │    APIs      │  │   Compiler    │ │
│         │         └──────┬────────┘  └───────┬───────┘ │
│         │                │                    │         │
├─────────┴────────────────┴────────────────────┴─────────┤
│                     Docker Network                       │
├─────────────────────────┬─────────────────────────────┤
│    Execution Client     │     Consensus Client          │
│    (Geth/Erigon)       │     (Lighthouse)              │
└─────────────────────────┴─────────────────────────────┘
```

## 🛠️ Features

### Core Blockscout Features
- Block explorer with enhanced UI
- Transaction tracking and analysis
- Address analytics and portfolio view
- Token transfers and balances
- Smart contract verification

### MEGA Enhancements

#### 🎖️ Validator Dashboard
- Real-time performance metrics
- Attestation effectiveness
- Proposal history
- Reward tracking
- Slashing alerts

#### 🔗 Beacon Chain Integration
- Epoch and slot information
- Committee assignments
- Sync committee participation
- Fork choice visualization
- Network health metrics

#### 💡 Integrated Smart Contract IDE
- Monaco editor with Solidity support
- Multi-file project management
- Import resolution
- Real-time compilation feedback
- Gas estimation
- One-click deployment

#### 📡 Blockscout SDK Features
- WebSocket subscriptions
- Transaction streaming
- Custom event filters
- Historical data queries
- Rate-limited public API

## 🔗 Deployment Options

- **Local Development**: Quick start with Docker Compose
- **Production (GCE)**: Full deployment guide with SSL, monitoring, and backups
- **Kubernetes**: Helm charts available for cloud-native deployments

## 🤝 Open Source Commitment

MEGA Blockscout is fully open source to benefit the Ethereum community:

- **Frontend Repository**: [github.com/DarkArtistry/frontend](https://github.com/DarkArtistry/frontend)
- **Backend Repository**: [github.com/DarkArtistry/blockscout](https://github.com/DarkArtistry/blockscout)
- **Deployment Tools**: This repository

We believe in:
- 🌍 **Community First**: Built by the community, for the community
- 🔓 **Full Transparency**: All code is open and auditable
- 🤝 **Collaboration**: PRs and issues welcome
- 📚 **Knowledge Sharing**: Comprehensive documentation
- 🚀 **Innovation**: Pushing blockchain tooling forward

## 📚 Documentation

- [Deployment Guide](DEPLOYMENT_GUIDE.md) - Complete production deployment
- [Quick Start](QUICKSTART.md) - Get running in 10 minutes
- [Architecture](../ARCHITECTURE.md) - System design details
- [Contract Editor](../CONTRACT_EDITOR_IMPLEMENTATION_SUMMARY.md) - IDE documentation
- [Validators API](../VALIDATORS.md) - Beacon chain integration guide

## 🏗️ Roadmap

- [x] Lighthouse beacon chain integration
- [x] Smart contract IDE
- [x] Blockscout SDK integration
- [x] Production deployment on GCE
- [ ] MEV analysis dashboard
- [ ] Layer 2 support
- [ ] Advanced debugging tools
- [ ] AI-powered contract analysis

## 👥 Contributing

We welcome contributions! See our [Contributing Guide](CONTRIBUTING.md) for:
- Code style guidelines
- Development setup
- Testing requirements
- PR process

## 🙏 Acknowledgments

- [Blockscout](https://blockscout.com/) team for the amazing foundation
- [Lighthouse](https://lighthouse.sigmaprime.io/) for beacon chain client
- Ethereum community for continuous support
- ETHGlobal for hosting our demo

## 📄 License

MEGA Blockscout is released under the same license as Blockscout (GPL-3.0), ensuring it remains free and open source forever.

---

**Built with ❤️ to Make Ethereum Great Again**
