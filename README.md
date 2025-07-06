# EnergyTracker Smart Contract

A Solidity smart contract for tracking energy usage from IoT devices, built with Foundry. This contract enables device registration, energy usage recording, and data aggregation with automatic monthly reporting and 366-day data retention.


## 🌟 Features

- **Device Management**: Register and manage IoT energy devices
- **Energy Tracking**: Record daily energy usage with metadata
- **Data Aggregation**: Automatic monthly energy usage summaries
- **Access Control**: Only device owners can record energy data
- **Data Retention**: Intelligent cleanup of old data (366-day retention)
- **Event Logging**: Track all device registrations and energy recordings

## 📋 Contract Architecture

### Core Data Structures

- **`Device`**: Device registration and ownership information
- **`EnergyData`**: Daily energy usage records with timestamps and metadata
- **`MonthlyAggregate`**: Aggregated monthly data for reporting

### Key Functions

- `registerDevice(deviceId, deviceType)` - Register a new energy device
- `recordEnergyUsage(deviceId, energyUsage, dataSource, metadata)` - Record daily energy usage
- `getDeviceEnergyData(deviceId, fromDate, toDate)` - Retrieve historical energy data
- `getMonthlyAggregate(deviceId, monthTimestamp)` - Get monthly aggregated data
- `cleanupOldData(deviceId, batchSize)` - Clean up old data in batches

## 🚀 Deployment Information

### Sepolia Testnet
- **Original Contract**: `0xe00f337C70089FC7fFB832E7C34B2e16dF20ad13` ([View](https://sepolia.etherscan.io/address/0xe00f337c70089fc7ffb832e7c34b2e16df20ad13))
- **Final Optimized Contract**: `0x81060c826Ed733e281B925091b079C81C5DDcc87` ([View](https://sepolia.etherscan.io/address/0x81060c826Ed733e281B925091b079C81C5DDcc87))
- **Network**: Sepolia Testnet (Chain ID: 11155111)
- **Gas Savings**: 45% deployment, 62% operations, uint32 timestamps, simple usage

## 🛠️ Development Setup

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- Node.js and npm (for additional tooling)
- An Ethereum wallet with testnet ETH

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd vertriqe-smartcontract

# Install dependencies
forge install

# Copy environment file
cp .env.example .env

# Edit .env with your configuration
# - SEPOLIA_URL: Your Alchemy/Infura RPC URL
# - PRIVATE_KEY: Your wallet private key (without 0x prefix)
# - ETHERSCAN_API_KEY: Your Etherscan API key for verification
```

## 🧪 Testing

### Run Tests
```bash
# Run all tests
forge test

# Run tests with gas reporting
forge test --gas-report

# Run tests with verbose output
forge test -vv

# Generate coverage report
forge coverage
```

### Test Results
- ✅ 8/8 tests passing
- 📊 Coverage: ~65% lines, ~66% statements, ~50% branches
- ⛽ Gas optimization: Efficient mappings-based storage

## 🚀 Deployment

### Local Development
```bash
# Start local blockchain
anvil

# Deploy to local network
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```

### Testnet Deployment
```bash
# Load environment variables
source .env

# Deploy to Sepolia testnet
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY --broadcast

# Verify on Etherscan
forge verify-contract CONTRACT_ADDRESS src/EnergyTracker.sol:EnergyTracker --chain-id 11155111 --etherscan-api-key $ETHERSCAN_API_KEY
```

## 📊 Usage Examples

### Register a New Device
```bash
# Register a solar panel device
cast send $CONTRACT_ADDRESS "registerDevice(string,string)" "V2223" "solar_panel" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY
```

### Record Energy Usage
```bash
# Original contract (expensive)
cast send $CONTRACT_ADDRESS "recordEnergyUsage(string,uint256,string,string)" "V2223" 2229 "smart_meter" "{'temperature': 25}" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY

# Simple optimized contract (62% cheaper)
cast send 0x75124eC2E8A583658EDB2480f2B53742ed6F7E3E "recordEnergyUsage(string,uint32)" "V2223" 2229 --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY
```

### Query Energy Data
```bash
# Get device information
cast call $CONTRACT_ADDRESS "getDeviceInfo(string)" "V2223" --rpc-url $SEPOLIA_URL

# Get today's energy data
TODAY=$(date -d "$(date +%Y-%m-%d) 00:00:00" +%s)
cast call $CONTRACT_ADDRESS "getDeviceEnergyData(string,uint256,uint256)" "V2223" $TODAY $TODAY --rpc-url $SEPOLIA_URL

# Get monthly aggregate
CURRENT_MONTH=$(cast call $CONTRACT_ADDRESS "getCurrentMonthTimestamp()" --rpc-url $SEPOLIA_URL)
cast call $CONTRACT_ADDRESS "getMonthlyAggregate(string,uint256)" "V2223" $CURRENT_MONTH --rpc-url $SEPOLIA_URL
```

## 📁 Project Structure

```
├── src/
│   └── EnergyTracker.sol          # Main smart contract
├── test/
│   └── EnergyTracker.t.sol        # Foundry tests
├── script/
│   └── Deploy.s.sol               # Deployment script
├── lib/
│   └── forge-std/                 # Foundry standard library
├── .env.example                   # Environment variables template
├── foundry.toml                   # Foundry configuration
├── CLAUDE.md                      # Development guidelines
├── FOUNDRY_COMMANDS.md            # General Foundry commands
└── PROJECT_COMMANDS.md            # Project-specific commands
```

## 🔧 Key Technologies

- **Solidity ^0.8.28**: Smart contract development
- **Foundry**: Development framework (Forge, Cast, Anvil)
- **OpenZeppelin**: Security best practices
- **Alchemy/Infura**: Ethereum node provider
- **Etherscan**: Contract verification and monitoring

## 💡 Use Cases

### IoT Energy Monitoring
- **Solar Panels**: Track daily energy generation
- **Wind Turbines**: Monitor wind energy production
- **Smart Meters**: Record household energy consumption
- **Battery Storage**: Track charging/discharging cycles
- **Heat Pumps**: Monitor heating/cooling energy usage

### Data Analytics
- **Monthly Reports**: Automated energy usage summaries
- **Historical Analysis**: Compare energy patterns over time
- **Efficiency Tracking**: Monitor device performance trends
- **Cost Optimization**: Analyze energy usage for cost savings

## 🛡️ Security Features

- **Access Control**: Only device owners can modify their data
- **Input Validation**: Comprehensive parameter validation
- **Gas Optimization**: Efficient storage patterns to minimize costs
- **Event Logging**: Complete audit trail of all actions
- **Batch Processing**: Safe cleanup of old data in manageable chunks

## 📈 Gas Costs Analysis

### Gas Usage (from Foundry tests and live transactions)

| Function | Gas Used | Cost per Gwei | Cost at 20 Gwei | Cost at 40 Gwei | Cost at 100 Gwei |
|----------|----------|---------------|-----------------|-----------------|-------------------|
| Deploy Contract | 2,353,416 | 0.002353 ETH | $141.20 | $282.41 | $706.02 |
| Register Device | 118,441 | 0.000118 ETH | $7.11 | $14.21 | $35.53 |
| Record Energy Usage | 197,839 | 0.000198 ETH | $11.87 | $23.74 | $59.35 |
| Get Monthly Aggregate | 8,620 | 0.000009 ETH | $0.52 | $1.03 | $2.59 |
| Cleanup Old Data | 25,724 | 0.000026 ETH | $1.54 | $3.09 | $7.72 |

### Network Comparison

| Network | Current Gas Price | Deploy Cost | Register Device | Record Energy |
|---------|------------------|-------------|-----------------|---------------|
| **Sepolia Testnet** | ~0.6 gwei | $4.09 | $0.21 | $0.34 |
| **Ethereum Mainnet (Low)** | ~20 gwei | $141.20 | $7.11 | $11.87 |
| **Ethereum Mainnet (High)** | ~40 gwei | $282.41 | $14.21 | $23.74 |
| **Ethereum Mainnet (Peak)** | ~100 gwei | $706.02 | $35.53 | $59.35 |

### Cost Calculation Formula
```
Cost (ETH) = Gas Used × Gas Price (gwei) × 10^-9
Cost (USD) = Cost (ETH) × ETH Price (~$3,000)
```

### Cost Optimization Tips
- **Use testnets for development** - Nearly free transactions
- **Deploy during off-peak hours** - Weekends and late nights typically have lower gas
- **Monitor gas prices** - Use [ETH Gas Station](https://ethgasstation.info/) or [GasTracker](https://etherscan.io/gastracker)
- **Batch operations** - Combine multiple calls when possible
- **Consider Layer 2** - Polygon, Arbitrum, or Optimism for 90%+ cost reduction
- **See [CHEAP_ALTERNATIVES.md](./CHEAP_ALTERNATIVES.md)** - Complete guide to low-cost blockchain alternatives

*All USD estimates assume ETH = $3,000. Actual costs vary with ETH price and network congestion.*

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass: `forge test`
5. Submit a pull request

## 📚 Documentation

- [FOUNDRY_COMMANDS.md](./FOUNDRY_COMMANDS.md) - General Foundry commands and workflows
- [PROJECT_COMMANDS.md](./PROJECT_COMMANDS.md) - Project-specific interaction commands
- [GAS_COSTS.md](./GAS_COSTS.md) - Detailed gas cost analysis and optimization
- [CHEAP_ALTERNATIVES.md](./CHEAP_ALTERNATIVES.md) - Layer 2 and alternative blockchain options
- [CLAUDE.md](./CLAUDE.md) - Development guidelines and architecture notes

## 🔗 Links

- [Foundry Documentation](https://book.getfoundry.sh/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Contract on Etherscan](https://sepolia.etherscan.io/address/0xe00f337c70089fc7ffb832e7c34b2e16df20ad13)
- [Sepolia Testnet Faucet](https://faucets.chain.link/sepolia)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🚨 Disclaimer

This smart contract is deployed on testnet for development and testing purposes. Always audit smart contracts before deploying to mainnet with real funds.