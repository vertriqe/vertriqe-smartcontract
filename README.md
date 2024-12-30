# Vertriqe Energy Tracking Smart Contract

A Solidity smart contract for tracking energy usage data from IoT devices with aggregation capabilities.

## Features

- Device registration and management
- Energy usage data recording
- Daily and monthly data aggregation
- Data retention policy implementation
- Role-based access control for device owners

## Contract Overview

The EnergyTracker contract provides the following main functionalities:

- `registerDevice`: Register new energy monitoring devices
- `recordEnergyUsage`: Record energy consumption data
- `getDeviceEnergyData`: Retrieve historical energy data
- `getMonthlyAggregate`: Get monthly usage summaries
- `cleanupOldData`: Maintain data retention policy

## Development Setup

1. Install dependencies:
```bash
npm install
```

2. Run tests:
```bash
npx hardhat test
```

3. Deploy contract:
```bash
npx hardhat run scripts/deploy.ts
```

## Testing

The test suite covers:
- Device registration scenarios
- Energy usage recording
- Data retrieval operations
- Access control validation

## Technical Details

- Solidity Version: ^0.8.28
- Framework: Hardhat
- Testing: Chai & Hardhat Network Helpers

## License

UNLICENSED


## Hardhat Commands
```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.ts
```
