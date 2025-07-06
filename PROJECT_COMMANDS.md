# EnergyTracker Commands

## Setup
```bash
source .env
export CONTRACT_ADDRESS=0xB537EfAbAAf252246E9dc0952e102fbfD1DBE49f
```

## Device Registration
```bash
# Register device
cast send $CONTRACT_ADDRESS "registerDevice(string)" "V2223" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY

# Check device info (returns owner address and registration time)
cast call $CONTRACT_ADDRESS "getDevice(string)" "V2223" --rpc-url $SEPOLIA_URL

# Get owner's devices
cast call $CONTRACT_ADDRESS "getOwnerDevices(address)" "YOUR_ADDRESS" --rpc-url $SEPOLIA_URL

# Check if device exists (returns owner address)
cast call $CONTRACT_ADDRESS "devices(string)" "V2223" --rpc-url $SEPOLIA_URL
```

## Energy Usage Recording
```bash
# FIRST: Make sure device is registered!
cast send $CONTRACT_ADDRESS "registerDevice(string)" "V2223" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY

# THEN: Record energy usage (value in Wh)
cast send $CONTRACT_ADDRESS "recordEnergyUsage(string,uint32)" "V2223" 2229 --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY

# Record different values
cast send $CONTRACT_ADDRESS "recordEnergyUsage(string,uint32)" "V2223" 1850 --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY
```

## Data Retrieval
```bash
# Get today's energy data
TODAY=$(expr $(date +%s) / 86400)
cast call $CONTRACT_ADDRESS "getEnergyData(string,uint256)" "V2223" $TODAY --rpc-url $SEPOLIA_URL

# Get specific date (calculate: timestamp / 86400)
SPECIFIC_DATE=19900  # example day number
cast call $CONTRACT_ADDRESS "getEnergyData(string,uint256)" "V2223" $SPECIFIC_DATE --rpc-url $SEPOLIA_URL
```

## Events Monitoring
```bash
# Watch device registrations
cast logs --address $CONTRACT_ADDRESS --sig "DeviceRegistered(string,address,uint256)" --rpc-url $SEPOLIA_URL

# Watch energy recordings
cast logs --address $CONTRACT_ADDRESS --sig "EnergyRecorded(string,uint32,uint64)" --rpc-url $SEPOLIA_URL
```

## Local Testing
```bash
# Start local node
anvil

# Deploy locally
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

# Test with local contract
cast send LOCAL_CONTRACT_ADDRESS "registerDevice(string)" "TEST123" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

## Build & Test
```bash
forge build
forge test
forge test --gas-report
```

## Troubleshooting
```bash
# 1. Check if contract exists at address
cast code $CONTRACT_ADDRESS --rpc-url $SEPOLIA_URL

# 2. Check if device already exists (should return 0x0 if not registered)
cast call $CONTRACT_ADDRESS "devices(string)" "V2223" --rpc-url $SEPOLIA_URL

# 3. Get your wallet address
cast wallet address --private-key $PRIVATE_KEY

# 4. Check your ETH balance (need gas for transactions)
cast balance $(cast wallet address --private-key $PRIVATE_KEY) --rpc-url $SEPOLIA_URL

# 5. Test with a simple call (should work if contract is deployed)
cast call $CONTRACT_ADDRESS "DATA_RETENTION_DAYS()" --rpc-url $SEPOLIA_URL

# 6. If contract doesn't exist, deploy it first
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY --broadcast
```

## Key Constants
- **DATA_RETENTION_DAYS**: 365 days
- **Day calculation**: `block.timestamp / 86400`
- **Gas cost**: ~100k gas per transaction