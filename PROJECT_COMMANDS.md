# EnergyTracker Project Commands

Specific commands for interacting with the EnergyTracker smart contract deployed at:
**Contract Address**: `0xe00f337C70089FC7fFB832E7C34B2e16dF20ad13`

## 📋 Environment Setup

```bash
# Load environment variables
source .env

# Set contract address as variable for easier use
export CONTRACT_ADDRESS=0xe00f337C70089FC7fFB832E7C34B2e16dF20ad13
```

## 🔧 Device Management Commands

### Register New Device
```bash
# Register a new solar panel device
cast send $CONTRACT_ADDRESS "registerDevice(string,string)" "V2223" "solar_panel" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY

# Register other device types
cast send $CONTRACT_ADDRESS "registerDevice(string,string)" "W3456" "wind_turbine" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY
cast send $CONTRACT_ADDRESS "registerDevice(string,string)" "B7890" "battery_storage" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY
cast send $CONTRACT_ADDRESS "registerDevice(string,string)" "H1234" "heat_pump" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY
```

### Get Device Information
```bash
# Get device info for V2223
cast call $CONTRACT_ADDRESS "getDeviceInfo(string)" "V2223" --rpc-url $SEPOLIA_URL

# Check if device exists and get owner
cast call $CONTRACT_ADDRESS "devices(string)" "V2223" --rpc-url $SEPOLIA_URL
```

## ⚡ Energy Usage Recording Commands

### Record Energy Usage for Your Device
```bash
# Record 2229 energy usage for device V2223 today
cast send $CONTRACT_ADDRESS "recordEnergyUsage(string,uint256,string,string)" "V2223" 2229 "smart_meter" "{'temperature': 25, 'timestamp': '2024-07-05'}" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY

# Record energy usage with different data sources
cast send $CONTRACT_ADDRESS "recordEnergyUsage(string,uint256,string,string)" "V2223" 1850 "iot_sensor" "{'voltage': 240, 'current': 8.5}" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY

# Record energy usage with minimal metadata
cast send $CONTRACT_ADDRESS "recordEnergyUsage(string,uint256,string,string)" "V2223" 2100 "manual_reading" "{}" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY
```

### Common Energy Usage Patterns
```bash
# Morning solar generation (lower)
cast send $CONTRACT_ADDRESS "recordEnergyUsage(string,uint256,string,string)" "V2223" 800 "smart_meter" "{'time': 'morning', 'weather': 'cloudy'}" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY

# Midday solar generation (peak)
cast send $CONTRACT_ADDRESS "recordEnergyUsage(string,uint256,string,string)" "V2223" 3500 "smart_meter" "{'time': 'midday', 'weather': 'sunny'}" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY

# Evening solar generation (lower)
cast send $CONTRACT_ADDRESS "recordEnergyUsage(string,uint256,string,string)" "V2223" 1200 "smart_meter" "{'time': 'evening', 'weather': 'clear'}" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY
```

## 📊 Data Retrieval Commands

### Get Today's Energy Data
```bash
# Get current timestamp (for reference)
cast call $CONTRACT_ADDRESS "getCurrentMonthTimestamp()" --rpc-url $SEPOLIA_URL

# Calculate today's timestamp (Unix timestamp at start of day)
# For July 5, 2024: 1720137600
TODAY=$(date -d "$(date +%Y-%m-%d) 00:00:00" +%s)
echo "Today's timestamp: $TODAY"

# Get energy data for today
cast call $CONTRACT_ADDRESS "getDeviceEnergyData(string,uint256,uint256)" "V2223" $TODAY $TODAY --rpc-url $SEPOLIA_URL
```

### Get Historical Energy Data
```bash
# Get data for last 7 days
WEEK_AGO=$(date -d "7 days ago" +%s)
WEEK_AGO_MIDNIGHT=$(date -d "$(date -d "7 days ago" +%Y-%m-%d) 00:00:00" +%s)
TODAY_MIDNIGHT=$(date -d "$(date +%Y-%m-%d) 00:00:00" +%s)

cast call $CONTRACT_ADDRESS "getDeviceEnergyData(string,uint256,uint256)" "V2223" $WEEK_AGO_MIDNIGHT $TODAY_MIDNIGHT --rpc-url $SEPOLIA_URL

# Get data for specific date range (January 1-7, 2024)
JAN_1_2024=1704067200  # Jan 1, 2024 00:00:00 UTC
JAN_7_2024=1704585600  # Jan 7, 2024 00:00:00 UTC
cast call $CONTRACT_ADDRESS "getDeviceEnergyData(string,uint256,uint256)" "V2223" $JAN_1_2024 $JAN_7_2024 --rpc-url $SEPOLIA_URL
```

### Get Monthly Aggregates
```bash
# Get current month's aggregate data
CURRENT_MONTH=$(cast call $CONTRACT_ADDRESS "getCurrentMonthTimestamp()" --rpc-url $SEPOLIA_URL)
cast call $CONTRACT_ADDRESS "getMonthlyAggregate(string,uint256)" "V2223" $CURRENT_MONTH --rpc-url $SEPOLIA_URL

# Get monthly aggregates for a range (requires month timestamps)
# July 2024: 1719792000, August 2024: 1722470400
JULY_2024=1719792000
AUGUST_2024=1722470400
cast call $CONTRACT_ADDRESS "getMonthlyAggregates(string,uint256,uint256)" "V2223" $JULY_2024 $AUGUST_2024 --rpc-url $SEPOLIA_URL
```

## 🧹 Data Management Commands

### Clean Up Old Data
```bash
# Clean up old data in small batches (gas efficient)
cast send $CONTRACT_ADDRESS "cleanupOldData(string,uint256)" "V2223" 10 --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY

# Clean up larger batches (more gas but fewer transactions)
cast send $CONTRACT_ADDRESS "cleanupOldData(string,uint256)" "V2223" 50 --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY
```

## 🔍 Monitoring and Events

### Watch for Events
```bash
# Watch for new device registrations
cast logs --address $CONTRACT_ADDRESS --sig "DeviceRegistered(string,string,address)" --rpc-url $SEPOLIA_URL

# Watch for energy data recordings
cast logs --address $CONTRACT_ADDRESS --sig "EnergyDataRecorded(string,uint256,uint256)" --rpc-url $SEPOLIA_URL

# Get past events (last 100 blocks)
cast logs --address $CONTRACT_ADDRESS --sig "EnergyDataRecorded(string,uint256,uint256)" --from-block -100 --rpc-url $SEPOLIA_URL
```

## 📈 Useful Calculations

### Convert Energy Units
```bash
# Convert kWh to Wh (multiply by 1000)
# If your device reports in kWh, convert to Wh for storage
echo "2.229 kWh = $((2229)) Wh"

# Convert between different time periods
# Daily usage: 2229 Wh
# Monthly estimate: 2229 * 30 = 66,870 Wh
# Yearly estimate: 2229 * 365 = 813,585 Wh
```

### Date/Time Utilities
```bash
# Convert human date to Unix timestamp
date -d "2024-07-05 00:00:00" +%s

# Convert Unix timestamp to human date
date -d @1720137600

# Get current Unix timestamp
date +%s

# Get start of current day
date -d "$(date +%Y-%m-%d) 00:00:00" +%s
```

## 🎯 Real-World Usage Examples

### Daily Energy Monitoring Script
```bash
#!/bin/bash
# daily_energy_log.sh

source .env
CONTRACT_ADDRESS=0xe00f337C70089FC7fFB832E7C34B2e16dF20ad13
DEVICE_ID="V2223"

# Get today's energy reading (replace with your actual reading)
ENERGY_READING=2229

# Record energy usage
echo "Recording $ENERGY_READING Wh for device $DEVICE_ID..."
cast send $CONTRACT_ADDRESS "recordEnergyUsage(string,uint256,string,string)" \
  "$DEVICE_ID" \
  $ENERGY_READING \
  "daily_script" \
  "{'automated': true, 'script_version': '1.0'}" \
  --rpc-url $SEPOLIA_URL \
  --private-key $PRIVATE_KEY

echo "Energy usage recorded successfully!"
```

### Monthly Report Script
```bash
#!/bin/bash
# monthly_report.sh

source .env
CONTRACT_ADDRESS=0xe00f337C70089FC7fFB832E7C34B2e16dF20ad13
DEVICE_ID="V2223"

# Get current month data
CURRENT_MONTH=$(cast call $CONTRACT_ADDRESS "getCurrentMonthTimestamp()" --rpc-url $SEPOLIA_URL)
MONTHLY_DATA=$(cast call $CONTRACT_ADDRESS "getMonthlyAggregate(string,uint256)" "$DEVICE_ID" $CURRENT_MONTH --rpc-url $SEPOLIA_URL)

echo "Monthly Report for Device $DEVICE_ID:"
echo "Raw data: $MONTHLY_DATA"
echo "Decode this data to get total energy usage and days recorded"
```

## 🔧 Testing Commands

### Local Testing Before Mainnet
```bash
# Test on local anvil before using real network
anvil

# In another terminal, test with local deployment
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

# Test interactions with local contract
cast send LOCAL_CONTRACT_ADDRESS "registerDevice(string,string)" "V2223" "solar_panel" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

## 📝 Common Workflows

### 1. New Device Setup
```bash
# Step 1: Register device
cast send $CONTRACT_ADDRESS "registerDevice(string,string)" "NEW_DEVICE_ID" "device_type" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY

# Step 2: Verify registration
cast call $CONTRACT_ADDRESS "getDeviceInfo(string)" "NEW_DEVICE_ID" --rpc-url $SEPOLIA_URL

# Step 3: Record first energy reading
cast send $CONTRACT_ADDRESS "recordEnergyUsage(string,uint256,string,string)" "NEW_DEVICE_ID" 1500 "initial_reading" "{}" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY
```

### 2. Daily Data Recording
```bash
# Record today's energy usage for V2223
cast send $CONTRACT_ADDRESS "recordEnergyUsage(string,uint256,string,string)" "V2223" 2229 "smart_meter" "{'date': '$(date +%Y-%m-%d)', 'source': 'automated'}" --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY
```

### 3. Monthly Review
```bash
# Get current month's aggregate
CURRENT_MONTH=$(cast call $CONTRACT_ADDRESS "getCurrentMonthTimestamp()" --rpc-url $SEPOLIA_URL)
cast call $CONTRACT_ADDRESS "getMonthlyAggregate(string,uint256)" "V2223" $CURRENT_MONTH --rpc-url $SEPOLIA_URL

# Clean up old data if needed
cast send $CONTRACT_ADDRESS "cleanupOldData(string,uint256)" "V2223" 30 --rpc-url $SEPOLIA_URL --private-key $PRIVATE_KEY
```

## 🚨 Important Notes

1. **Gas Costs**: Each transaction costs gas. Recording energy usage costs ~200k gas (~$5-10 USD on mainnet)
2. **Data Retention**: Contract automatically keeps 366 days of detailed data
3. **Ownership**: Only device owner can record energy usage
4. **Time Zones**: All timestamps are in UTC
5. **Data Format**: Energy usage is stored as uint256 (whole numbers only)

## 📞 Support

If you encounter issues:
1. Check your .env file has correct values
2. Ensure you have enough ETH for gas fees
3. Verify contract address is correct
4. Check if device is registered before recording data