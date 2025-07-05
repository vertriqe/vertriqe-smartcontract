# Foundry Commands Cheat Sheet

A comprehensive guide to Foundry commands for Solidity development.

## 📋 Table of Contents
- [Basic Commands](#basic-commands)
- [Testing Commands](#testing-commands)
- [Deployment Commands](#deployment-commands)
- [Contract Interaction Commands](#contract-interaction-commands)
- [Verification Commands](#verification-commands)
- [Debugging Commands](#debugging-commands)
- [Useful Flags](#useful-flags)

## 🔧 Basic Commands

### Project Setup
```bash
# Initialize new Foundry project
forge init my-project

# Initialize in existing directory (force)
forge init --force

# Install dependencies
forge install

# Build/compile contracts
forge build

# Clean build artifacts
forge clean

# Update dependencies
forge update
```

### Configuration
```bash
# Check Foundry version
forge --version

# Show current configuration
forge config

# Format Solidity code
forge fmt
```

## 🧪 Testing Commands

### Running Tests
```bash
# Run all tests
forge test

# Run tests with verbose output (show logs)
forge test -v

# Run tests with very verbose output (show traces)
forge test -vv

# Run tests with maximum verbosity (show setup traces)
forge test -vvv

# Run specific test function
forge test --match-test test_RegisterDevice

# Run specific test contract
forge test --match-contract EnergyTrackerTest

# Run tests matching a pattern
forge test --match-path "*/EnergyTracker*"
```

### Advanced Testing
```bash
# Run tests with gas reporting
forge test --gas-report

# Generate test coverage report
forge coverage

# Run tests with summary
forge test --summary

# Run fuzz tests with custom runs
forge test --fuzz-runs 1000

# Run tests on specific fork
forge test --fork-url https://eth-mainnet.alchemyapi.io/v2/YOUR-API-KEY
```

## 🚀 Deployment Commands

### Local Deployment
```bash
# Start local blockchain (anvil)
anvil

# Deploy to local blockchain
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

# Deploy with custom gas price
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --gas-price 1000000000 --broadcast
```

### Testnet Deployment
```bash
# Deploy to Sepolia testnet
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY --broadcast

# Deploy to Goerli testnet
forge script script/Deploy.s.sol --rpc-url $GOERLI_URL --private-key $PRIVATE_KEY --broadcast

# Deploy with verification
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### Environment Variables
```bash
# Load environment variables and deploy
source .env && forge script script/Deploy.s.sol --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY --broadcast

# Use environment variables directly
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_URL --account myaccount --broadcast
```

## 📞 Contract Interaction Commands

### Reading Contract State (view/pure functions)
```bash
# Call a view function
cast call CONTRACT_ADDRESS "functionName()" --rpc-url $RPC_URL

# Call function with parameters
cast call CONTRACT_ADDRESS "getDeviceInfo(string)" "device-id" --rpc-url $RPC_URL

# Call function with multiple parameters
cast call CONTRACT_ADDRESS "getDeviceEnergyData(string,uint256,uint256)" "device-id" 1672531200 1675209600 --rpc-url $RPC_URL

# Get current block number
cast block-number --rpc-url $RPC_URL

# Get ETH balance
cast balance ADDRESS --rpc-url $RPC_URL
```

### Writing to Contract (state-changing functions)
```bash
# Send transaction to contract
cast send CONTRACT_ADDRESS "registerDevice(string,string)" "device-1" "solar_panel" --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Send transaction with ETH value
cast send CONTRACT_ADDRESS "payableFunction()" --value 1ether --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Send transaction with custom gas limit
cast send CONTRACT_ADDRESS "functionName()" --gas-limit 200000 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### Transaction Information
```bash
# Get transaction receipt
cast receipt TRANSACTION_HASH --rpc-url $RPC_URL

# Get transaction details
cast tx TRANSACTION_HASH --rpc-url $RPC_URL

# Estimate gas for transaction
cast estimate CONTRACT_ADDRESS "functionName()" --rpc-url $RPC_URL
```

## ✅ Verification Commands

### Contract Verification
```bash
# Verify contract on Etherscan
forge verify-contract CONTRACT_ADDRESS src/Contract.sol:ContractName --chain-id 11155111 --etherscan-api-key $ETHERSCAN_API_KEY

# Verify with constructor arguments
forge verify-contract CONTRACT_ADDRESS src/Contract.sol:ContractName --constructor-args $(cast abi-encode "constructor(uint256,string)" 123 "hello") --etherscan-api-key $ETHERSCAN_API_KEY

# Verify on different networks
forge verify-contract CONTRACT_ADDRESS src/Contract.sol:ContractName --chain-id 1 --etherscan-api-key $ETHERSCAN_API_KEY  # Mainnet
forge verify-contract CONTRACT_ADDRESS src/Contract.sol:ContractName --chain-id 5 --etherscan-api-key $ETHERSCAN_API_KEY  # Goerli
```

## 🐛 Debugging Commands

### Contract Debugging
```bash
# Simulate transaction without broadcasting
forge script script/Deploy.s.sol --rpc-url $RPC_URL

# Debug specific transaction
cast run TRANSACTION_HASH --rpc-url $RPC_URL

# Trace transaction execution
cast run TRANSACTION_HASH --trace --rpc-url $RPC_URL

# Get contract bytecode
cast code CONTRACT_ADDRESS --rpc-url $RPC_URL

# Get storage slot value
cast storage CONTRACT_ADDRESS SLOT_NUMBER --rpc-url $RPC_URL
```

### ABI and Signature Utils
```bash
# Get function signature
cast sig "transfer(address,uint256)"

# Decode calldata
cast calldata-decode "transfer(address,uint256)" 0xa9059cbb000000000000000000000000...

# Encode function call
cast calldata "transfer(address,uint256)" 0x... 1000000000000000000

# Convert between formats
cast --to-hex 1000000000000000000
cast --to-dec 0xde0b6b3a7640000
```

## 🎯 Useful Flags

### Common Flags
```bash
# Verbose output levels
-v, -vv, -vvv, -vvvv

# Gas reporting
--gas-report

# Fork testing
--fork-url RPC_URL
--fork-block-number BLOCK_NUMBER

# Broadcasting transactions
--broadcast

# Verification
--verify
--etherscan-api-key API_KEY

# Network specification
--rpc-url RPC_URL
--chain-id CHAIN_ID

# Account management
--private-key PRIVATE_KEY
--account ACCOUNT_NAME
--from ADDRESS
```

### Environment Variables
```bash
# Common environment variables to set in .env file
SEPOLIA_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR-API-KEY
GOERLI_URL=https://eth-goerli.g.alchemy.com/v2/YOUR-API-KEY
MAINNET_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR-API-KEY
PRIVATE_KEY=your-private-key-without-0x-prefix
ETHERSCAN_API_KEY=your-etherscan-api-key
```

## 📝 Example Workflow

### Complete Development Workflow
```bash
# 1. Create new project
forge init my-defi-project
cd my-defi-project

# 2. Write contracts in src/
# 3. Write tests in test/

# 4. Test your contracts
forge test

# 5. Test with gas reporting
forge test --gas-report

# 6. Generate coverage report
forge coverage

# 7. Deploy to testnet
source .env
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY --broadcast

# 8. Verify contract
forge verify-contract CONTRACT_ADDRESS src/MyContract.sol:MyContract --chain-id 11155111 --etherscan-api-key $ETHERSCAN_API_KEY

# 9. Interact with deployed contract
cast call CONTRACT_ADDRESS "myFunction()" --rpc-url $SEPOLIA_URL
```

## 🔗 Useful Resources

- [Foundry Documentation](https://book.getfoundry.sh/)
- [Foundry GitHub](https://github.com/foundry-rs/foundry)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Ethereum Testnet Faucets](https://faucets.chain.link/)

## 💡 Tips for Beginners

1. **Always test locally first** using `anvil` before deploying to testnets
2. **Use environment variables** for sensitive data like private keys
3. **Start with small amounts** when testing on testnets
4. **Verify your contracts** on Etherscan for transparency
5. **Use gas reporting** to optimize contract efficiency
6. **Write comprehensive tests** - aim for high coverage
7. **Keep your private keys secure** - never commit them to git

## 🚨 Security Reminders

- Never commit private keys to version control
- Use testnet ETH for testing, not mainnet
- Always verify contract addresses before sending transactions
- Double-check function parameters before broadcasting
- Use hardware wallets for mainnet deployments