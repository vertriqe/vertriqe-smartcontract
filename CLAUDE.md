# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Solidity smart contract project for energy tracking from IoT devices, built with Foundry. The main contract `EnergyTracker.sol` enables device registration, energy usage recording, and data aggregation with a 30-day retention policy.

## Essential Commands

### Testing
```bash
forge test                         # Run all tests
forge test --match-contract EnergyTrackerTest  # Run specific test contract
forge test --gas-report          # Run tests with gas reporting
```

### Development
```bash
forge build                       # Compile contracts
forge install                     # Install dependencies
anvil                            # Start local blockchain node
```

### Deployment
```bash
forge script script/Deploy.s.sol --rpc-url sepolia --private-key $PRIVATE_KEY --broadcast  # Deploy to Sepolia
forge script script/Deploy.s.sol --rpc-url anvil --private-key $ANVIL_PRIVATE_KEY --broadcast  # Deploy locally
```

## Architecture

### Smart Contract Structure
- **EnergyTracker.sol**: Main contract with three key data structures:
  - `Device`: Device registration and ownership
  - `EnergyData`: Daily energy usage records
  - `MonthlyAggregate`: Aggregated monthly data

### Key Patterns
- **Access Control**: `onlyDeviceOwner` modifier restricts access to device data
- **Data Lifecycle**: Automatic monthly aggregation with 30-day detailed data retention
- **Mappings**: Nested mappings for efficient data retrieval (`deviceId => date => data`)
- **Events**: `DeviceRegistered` and `EnergyDataRecorded` for off-chain monitoring

### Testing Framework
- Uses Foundry's testing framework with vm cheatcodes
- Tests cover registration, usage recording, data retrieval, and access control
- Proper timestamp handling with vm.warp for consistent test environments

## Development Notes

- Solidity version: ^0.8.28
- Framework: Foundry
- No linting or formatting tools configured
- Gas optimization considerations for data structures using mappings over arrays